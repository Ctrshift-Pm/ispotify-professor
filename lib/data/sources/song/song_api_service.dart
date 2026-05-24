import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_with_flutter/data/models/playlist/playlist.dart';
import 'package:spotify_with_flutter/data/models/songs/songs.dart';
import 'package:spotify_with_flutter/domain/entities/playlist/playlist.dart';
import 'package:spotify_with_flutter/domain/entities/songs/songs.dart';

abstract class SongApiService {
  Future<List<SongEntity>> getNewsSongs();
  Future<List<SongEntity>> getPlayList();
  Future<List<PlaylistEntity>> getPlaylists();
  Future<List<PlaylistEntity>> getPlaylistsByCategory(String category);
  Future<PlaylistEntity> getPlaylistDetails(String playlistId);
  Future<bool> addOrRemoveFavoriteSong(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<List<SongEntity>> getUserFavoriteSong();
  Future<String> getPrivateNotes(String songId);
  Future<bool> savePrivateNotes(String songId, String notes);
}

class SongApiServiceImpl extends SongApiService {
  SongApiServiceImpl();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const String _favoritesKey = "user_favorites_songs";
  static const String _notesPrefix = "class_note_";
  static const String _playlistId = "PLlqZM4covn1Hqp7LaICvTomOliPy4wZHp";
  static const String _playlistPageUrl =
      "https://www.youtube.com/playlist?list=$_playlistId";
  static const String _meteoraCoverUrl =
      "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/13/44/05/134405bd-9e27-a678-8953-b5f724201f95/093624948988.jpg/600x600bb.jpg";

  static String _playlistVideoUrl(String videoId, int index) {
    return "https://www.youtube.com/watch?v=$videoId&list=$_playlistId&index=$index";
  }

  static final List<Map<String, dynamic>> _meteora20TracksJson = [
    {
      "songId": "song_01",
      "title": "Foreword",
      "artist": "LINKIN PARK",
      "duration": 15,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("9dDXtllCa_A", 1),
    },
    {
      "songId": "song_02",
      "title": "Don't Stay",
      "artist": "LINKIN PARK",
      "duration": 190,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("qq1UEeS1a7c", 2),
    },
    {
      "songId": "song_03",
      "title": "Somewhere I Belong",
      "artist": "LINKIN PARK",
      "duration": 226,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("zsCD5XCu6CM", 3),
    },
    {
      "songId": "song_04",
      "title": "Lying From You",
      "artist": "LINKIN PARK",
      "duration": 175,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("_c3XfcyQ45w", 4),
    },
    {
      "songId": "song_05",
      "title": "Hit the Floor",
      "artist": "LINKIN PARK",
      "duration": 165,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("iYUK2-AMHlg", 5),
    },
    {
      "songId": "song_06",
      "title": "Easier to Run",
      "artist": "LINKIN PARK",
      "duration": 206,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("Br91hWUrmII", 6),
    },
    {
      "songId": "song_07",
      "title": "Faint",
      "artist": "LINKIN PARK",
      "duration": 168,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("LYU-8IFcDPw", 7),
    },
    {
      "songId": "song_08",
      "title": "Figure.09",
      "artist": "LINKIN PARK",
      "duration": 200,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("6dEAeCHQrBs", 8),
    },
    {
      "songId": "song_09",
      "title": "Breaking the Habit",
      "artist": "LINKIN PARK",
      "duration": 198,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("v2H4l9RpkwM", 9),
    },
    {
      "songId": "song_10",
      "title": "From The Inside",
      "artist": "LINKIN PARK",
      "duration": 177,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("YLHpvjrFpe0", 10),
    },
    {
      "songId": "song_11",
      "title": "Nobody's Listening",
      "artist": "LINKIN PARK",
      "duration": 181,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("raKxf5M30Qc", 11),
    },
    {
      "songId": "song_12",
      "title": "Session",
      "artist": "LINKIN PARK",
      "duration": 146,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("VWztwocVnZM", 12),
    },
    {
      "songId": "song_13",
      "title": "Numb",
      "artist": "LINKIN PARK",
      "duration": 187,
      "releaseDate": "25/03/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("kXYiU_JCYtU", 13),
    },
    {
      "songId": "song_14",
      "title": "Lost",
      "artist": "LINKIN PARK",
      "duration": 198,
      "releaseDate": "10/02/2023",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("7NK_JOkuSVY", 14),
    },
    {
      "songId": "song_15",
      "title": "Fighting Myself",
      "artist": "LINKIN PARK",
      "duration": 200,
      "releaseDate": "24/03/2023",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("iKBCVZqqooY", 15),
    },
    {
      "songId": "song_16",
      "title": "More the Victim",
      "artist": "LINKIN PARK",
      "duration": 163,
      "releaseDate": "07/04/2023",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("Ysb4Md4XYsc", 16),
    },
    {
      "songId": "song_17",
      "title": "Don't Stay (Live In Texas)",
      "artist": "LINKIN PARK",
      "duration": 274,
      "releaseDate": "18/11/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("ZKFHcxaRAkg", 17),
    },
    {
      "songId": "song_18",
      "title": "Somewhere I Belong (Live In Texas)",
      "artist": "LINKIN PARK",
      "duration": 215,
      "releaseDate": "18/11/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("bQOba9CC2KI", 18),
    },
    {
      "songId": "song_19",
      "title": "Lying from You (Live In Texas)",
      "artist": "LINKIN PARK",
      "duration": 216,
      "releaseDate": "18/11/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("4TwQa4lpYCg", 19),
    },
    {
      "songId": "song_20",
      "title": "Papercut (Live In Texas)",
      "artist": "LINKIN PARK",
      "duration": 188,
      "releaseDate": "18/11/2003",
      "imageUrl": _meteoraCoverUrl,
      "audioUrl": "",
      "videoUrl": _playlistVideoUrl("GoTGia2xPw8", 20),
    },
  ];

  static final List<Map<String, dynamic>> _playlistsJson = [
    {
      "id": "playlist_meteora_20",
      "title": "Meteora 20",
      "description": "20 videos oficiais do YouTube em ordem de playlist.",
      "coverUrl": _meteoraCoverUrl,
      "category": "Meteora 20",
    },
  ];

  @override
  Future<List<SongEntity>> getNewsSongs() async {
    try {
      await _dio.get(_playlistPageUrl);
    } catch (_) {}

    return _songsWithFavoriteState(_meteora20TracksJson.take(4).toList());
  }

  @override
  Future<List<SongEntity>> getPlayList() async {
    try {
      await _dio.get(_playlistPageUrl);
    } catch (_) {}

    return _songsWithFavoriteState(_meteora20TracksJson);
  }

  @override
  Future<List<PlaylistEntity>> getPlaylists() async {
    return _parsePlaylistList(_playlistsJson);
  }

  @override
  Future<List<PlaylistEntity>> getPlaylistsByCategory(String category) async {
    return _parsePlaylistList(_playlistsJson);
  }

  @override
  Future<PlaylistEntity> getPlaylistDetails(String playlistId) async {
    final playlists = await _parsePlaylistList(_playlistsJson);
    return playlists.firstWhere((playlist) => playlist.id == playlistId);
  }

  @override
  Future<bool> addOrRemoveFavoriteSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? <String>[];

    final isFavorite = !favorites.contains(songId);
    if (isFavorite) {
      favorites.add(songId);
    } else {
      favorites.remove(songId);
    }

    await prefs.setStringList(_favoritesKey, favorites);
    return isFavorite;
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? <String>[];
      return favorites.contains(songId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<SongEntity>> getUserFavoriteSong() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? <String>[];
    final favoriteTracks = _meteora20TracksJson
        .where((track) => favorites.contains(track['songId']))
        .toList();

    for (final track in favoriteTracks) {
      track['isFavorite'] = true;
    }

    return _parseSongList(favoriteTracks);
  }

  @override
  Future<String> getPrivateNotes(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("$_notesPrefix$songId") ?? "";
  }

  @override
  Future<bool> savePrivateNotes(String songId, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("$_notesPrefix$songId", notes);
    return true;
  }

  Future<List<SongEntity>> _songsWithFavoriteState(
    List<Map<String, dynamic>> rawSongs,
  ) async {
    final songs = _parseSongList(rawSongs);
    for (var song in songs) {
      song = song..isFavorite = await isFavoriteSong(song.songId);
    }
    return songs;
  }

  List<SongEntity> _parseSongList(List<Map<String, dynamic>> rawSongs) {
    return rawSongs.map((data) {
      final model = SongModel.fromJson(data);
      model.songId = data['songId'] as String?;
      return model.toEntity();
    }).toList();
  }

  Future<List<PlaylistEntity>> _parsePlaylistList(
    List<Map<String, dynamic>> rawPlaylists,
  ) async {
    final playlists = <PlaylistEntity>[];
    for (final playlistData in rawPlaylists) {
      final playlistTracks = _meteora20TracksJson.map((track) {
        return Map<String, dynamic>.from(track);
      }).toList();

      for (final track in playlistTracks) {
        track['isFavorite'] = await isFavoriteSong(track['songId'] as String);
      }

      final playlistModel = PlaylistModel(
        id: playlistData['id'] as String,
        title: playlistData['title'] as String,
        description: playlistData['description'] as String,
        coverUrl: playlistData['coverUrl'] as String,
        category: playlistData['category'] as String,
        tracks: playlistTracks.map((track) {
          final model = SongModel.fromJson(track);
          model.songId = track['songId'] as String?;
          return model;
        }).toList(),
      );

      playlists.add(playlistModel.toEntity());
    }
    return playlists;
  }
}
