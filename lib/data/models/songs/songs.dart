import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';

class SongModel {
  String? title;
  String? artist;
  num? duration;
  String? releaseDate;
  String? imageUrl;
  String? audioUrl;
  String? videoUrl;
  bool? isFavorite;
  String? songId;

  SongModel.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    artist = data['artist'];
    duration = data['duration'];
    releaseDate = data['releaseDate']?.toString();
    imageUrl = data['imageUrl'];
    audioUrl = data['audioUrl'];
    videoUrl = data['videoUrl'];
    isFavorite = data['isFavorite'];
  }
}

extension SongModelX on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title!,
      artist: artist!,
      duration: duration!,
      releaseDate: releaseDate ?? '',
      imageUrl: imageUrl ?? '',
      audioUrl: audioUrl ?? '',
      videoUrl: videoUrl,
      isFavorite: isFavorite ?? false,
      songId: songId!,
    );
  }
}
