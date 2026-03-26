import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

// TMDB service provider
final tmdbServiceProvider = Provider<TmdbService>((ref) {
  return TmdbService();
});

// Current movie page state
final currentMoviePageProvider = StateProvider<int>((ref) => 1);

// Movies list state provider
final moviesListProvider = StateNotifierProvider<MoviesNotifier, AsyncValue<List<MovieModel>>>(
  (ref) => MoviesNotifier(ref),
);

class MoviesNotifier extends StateNotifier<AsyncValue<List<MovieModel>>> {
  final Ref ref;
  final List<MovieModel> _allMovies = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  MoviesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadMovies();
  }

  // Load initial movies
  Future<void> loadMovies() async {
    final hasExisting = _allMovies.isNotEmpty;
    if (!hasExisting) {
      state = const AsyncValue.loading();
    }

    try {
      final movies = await _loadWithRetry(_currentPage);
      _allMovies
        ..clear()
        ..addAll(_dedupeById(movies));
      state = AsyncValue.data(List<MovieModel>.from(_allMovies));
    } catch (e, stack) {
      print('[MoviesNotifier] loadMovies failed after retries: $e');
      if (hasExisting) {
        // Keep existing data visible if refresh fails.
        state = AsyncValue.data(List<MovieModel>.from(_allMovies));
      } else {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  // Load more movies
  Future<void> loadMoreMovies() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final tmdbService = ref.read(tmdbServiceProvider);
      final movies = await tmdbService.getMixedMovies(page: nextPage);
      _currentPage = nextPage;
      _allMovies.addAll(_dedupeById(movies));
      state = AsyncValue.data(List<MovieModel>.from(_allMovies));
    } catch (e) {
      print('[MoviesNotifier] loadMoreMovies failed: $e');
      // Keep current state on error
    } finally {
      _isLoadingMore = false;
    }
  }

  // Remove movie from list (after swipe)
  void removeMovie(int movieId) {
    _allMovies.removeWhere((movie) => movie.id == movieId);
    state = AsyncValue.data(List<MovieModel>.from(_allMovies));

    // Load more if running low
    if (_allMovies.length < 5) {
      loadMoreMovies();
    }
  }

  // Refresh movies
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _allMovies.clear();
    _currentPage = 1;
    try {
      await loadMovies();
    } finally {
      _isRefreshing = false;
    }
  }

  List<MovieModel> _dedupeById(List<MovieModel> movies) {
    final uniqueById = <int, MovieModel>{};
    for (final movie in movies) {
      if (movie.id == 0) continue;
      uniqueById[movie.id] = movie;
    }
    return uniqueById.values.toList();
  }

  Future<List<MovieModel>> _loadWithRetry(int page) async {
    final tmdbService = ref.read(tmdbServiceProvider);
    Exception? lastError;

    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final movies = await tmdbService.getMixedMovies(page: page);
        if (movies.isNotEmpty) return movies;
        lastError = Exception('No movies returned from TMDB.');
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
      }

      if (attempt < 3) {
        final delay = Duration(milliseconds: 400 * attempt);
        print('[MoviesNotifier] retrying loadMovies in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Failed to load movies.');
  }
}

// Popular movies provider
final popularMoviesProvider = FutureProvider.autoDispose<List<MovieModel>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getPopularMovies();
});

// Top rated movies provider
final topRatedMoviesProvider = FutureProvider.autoDispose<List<MovieModel>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getTopRatedMovies();
});

// Now playing movies provider
final nowPlayingMoviesProvider = FutureProvider.autoDispose<List<MovieModel>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getNowPlayingMovies();
});
