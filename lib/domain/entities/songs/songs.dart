class SongEntity {
  final String title;
  final String artist;
  final num duration;
  final String releaseDate;
  final String imageUrl;
  final String audioUrl;
  final String? videoUrl;
  bool isFavorite;
  final String songId;

  SongEntity({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.imageUrl,
    required this.audioUrl,
    this.videoUrl,
    required this.isFavorite,
    required this.songId,
  });
}
