import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';

class TmdbService {
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String _baseUrl = AppConstants.tmdbBaseUrl;
  static const Duration _requestTimeout = Duration(seconds: 12);

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final baseParams = <String, String>{
      'api_key': _apiKey,
      ...?queryParameters,
    };
    return Uri.parse('$_baseUrl$path').replace(queryParameters: baseParams);
  }

  Uri _buildLogUri(String path, {Map<String, String>? queryParameters}) {
    final logParams = <String, String>{
      'api_key': _apiKey.isEmpty ? '<missing>' : '<redacted>',
      ...?queryParameters,
    };
    return Uri.parse('$_baseUrl$path').replace(queryParameters: logParams);
  }

  Future<List<MovieModel>> _fetchMovies(
    String path, {
    Map<String, String>? queryParameters,
    int maxAttempts = 3,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('TMDB API key missing. Add TMDB_API_KEY to .env.');
    }

    late Exception lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final url = _buildUri(path, queryParameters: queryParameters);
      final safeLogUrl = _buildLogUri(path, queryParameters: queryParameters);
      print('[TMDB] GET $safeLogUrl (attempt $attempt/$maxAttempts)');

      try {
        final response = await http.get(url).timeout(_requestTimeout);
        print('[TMDB] ${response.statusCode} ${response.body.length} bytes');

        if (response.statusCode != 200) {
          final message = _mapHttpError(response.statusCode);
          print('[TMDB] Error body: ${response.body}');
          lastError = Exception(message);

          if (!_shouldRetryStatus(response.statusCode) || attempt == maxAttempts) {
            throw lastError;
          }
        } else {
          final dynamic data = json.decode(response.body);
          if (data is! Map<String, dynamic>) {
            throw Exception('Unexpected TMDB response format.');
          }

          final results = data['results'];
          if (results is! List) {
            throw Exception('TMDB response missing results list.');
          }

          final movies = results
              .whereType<Map<String, dynamic>>()
              .map(MovieModel.fromJson)
              .where((movie) => movie.id != 0)
              .toList();

          if (movies.isEmpty) {
            print('[TMDB] Empty movie list from $path');
          }
          return movies;
        }
      } catch (e) {
        lastError = e is Exception
            ? e
            : Exception('Network error while loading movies. Please try again.');
        print('[TMDB] Request failed for $path on attempt $attempt: $e');
        if (attempt == maxAttempts) break;
      }

      await Future.delayed(Duration(milliseconds: 350 * attempt));
    }

    throw lastError;
  }

  String _mapHttpError(int statusCode) {
    if (statusCode == 401) {
      return 'TMDB authentication failed (401). Check API key.';
    }
    if (statusCode == 404) {
      return 'TMDB endpoint not found (404).';
    }
    if (statusCode >= 500) {
      return 'TMDB server error ($statusCode). Try again shortly.';
    }
    if (statusCode == 429) {
      return 'TMDB rate limited (429). Retrying...';
    }
    return 'TMDB request failed ($statusCode).';
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  // Get popular movies
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    return _fetchMovies('/movie/popular', queryParameters: {
      'page': '$page',
    });
  }

  // Get top rated movies
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    return _fetchMovies('/movie/top_rated', queryParameters: {
      'page': '$page',
    });
  }

  // Get now playing movies
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    return _fetchMovies('/movie/now_playing', queryParameters: {
      'page': '$page',
    });
  }

  // Get upcoming movies
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    return _fetchMovies('/movie/upcoming', queryParameters: {
      'page': '$page',
    });
  }

  // Discover movies by genre
  Future<List<MovieModel>> discoverMoviesByGenre({
    required List<int> genreIds,
    int page = 1,
  }) async {
    final genres = genreIds.join(',');
    return _fetchMovies('/discover/movie', queryParameters: {
      'with_genres': genres,
      'page': '$page',
      'sort_by': 'popularity.desc',
    });
  }

  // Get mixed movies with discover/trending first, then fallback.
  Future<List<MovieModel>> getMixedMovies({int page = 1}) async {
    final discover = await _safeFetch('/discover/movie', queryParameters: {
      'page': '$page',
      'sort_by': 'popularity.desc',
      'include_adult': 'false',
    });
    final trending = await _safeFetch('/trending/movie/day', queryParameters: {
      'page': '$page',
    });
    final popular = await _safeFetch('/movie/popular', queryParameters: {
      'page': '$page',
    });
    final topRated = await _safeFetch('/movie/top_rated', queryParameters: {
      'page': '$page',
    });

    final List<MovieModel> allMovies = [
      ...discover,
      ...trending,
      ...popular,
      ...topRated,
    ];
    allMovies.shuffle();

    final uniqueMovies = <int, MovieModel>{};
    for (final movie in allMovies) {
      uniqueMovies[movie.id] = movie;
    }

    final mixed = uniqueMovies.values.toList();
    if (mixed.isEmpty) {
      throw Exception('No movies available from TMDB at the moment.');
    }
    return mixed;
  }

  Future<List<MovieModel>> _safeFetch(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      return await _fetchMovies(path, queryParameters: queryParameters);
    } catch (e) {
      print('[TMDB] Fallback source failed ($path): $e');
      return [];
    }
  }

  // Search movies
  Future<List<MovieModel>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    return _fetchMovies('/search/movie', queryParameters: {
      'query': query,
      'page': '$page',
    });
  }

  // Get movie details
  Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('TMDB API key missing. Add TMDB_API_KEY to .env.');
      }
      final url = _buildUri('/movie/$movieId');
      final safeLogUrl = _buildLogUri('/movie/$movieId');
      print('[TMDB] GET $safeLogUrl');
      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is! Map<String, dynamic>) return null;
        return MovieModel.fromJson(data);
      } else {
        throw Exception(_mapHttpError(response.statusCode));
      }
    } catch (e) {
      print('[TMDB] Error fetching movie details: $e');
      return null;
    }
  }
}
