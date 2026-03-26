class MovieModel {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String? originalLanguage;

  MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.popularity,
    this.originalLanguage,
  });

  // Get full poster URL
  String? getPosterUrl({String size = '/w500'}) {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p$size$posterPath';
  }

  // Get full backdrop URL
  String? getBackdropUrl({String size = '/w780'}) {
    if (backdropPath == null) return null;
    return 'https://image.tmdb.org/t/p$size$backdropPath';
  }

  // Format release year
  String? get releaseYear {
    if (releaseDate == null) return null;
    return releaseDate!.split('-').first;
  }

  // Get rating out of 10
  String get ratingString {
    return voteAverage.toStringAsFixed(1);
  }

  // Create from TMDB API response
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      originalLanguage: json['original_language'],
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'releaseDate': releaseDate,
      'genreIds': genreIds,
      'popularity': popularity,
      'originalLanguage': originalLanguage,
    };
  }

  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    List<int>? genreIds,
    double? popularity,
    String? originalLanguage,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds,
      popularity: popularity ?? this.popularity,
      originalLanguage: originalLanguage ?? this.originalLanguage,
    );
  }
}

// Genre mapping for display
class MovieGenres {
  static const Map<int, String> genres = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static String getGenreName(int id) {
    return genres[id] ?? 'Unknown';
  }

  static List<String> getGenreNames(List<int> ids) {
    return ids.map((id) => getGenreName(id)).toList();
  }
}
