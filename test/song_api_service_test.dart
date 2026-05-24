import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_with_flutter/data/sources/song/song_api_service.dart';

void main() {
  late SongApiService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = SongApiServiceImpl();
  });

  test('returns all playlists when category is ALL', () async {
    final playlists = await service.getPlaylistsByCategory('ALL');
    expect(playlists.length, 1);
    expect(playlists.first.title, 'Meteora 20');
    expect(playlists.first.tracks.length, 20);
    expect(
      playlists.first.tracks.take(4).map((song) => song.title).toList(),
      ['Foreword', "Don't Stay", 'Somewhere I Belong', 'Lying From You'],
    );
  });

  test('toggles favorite songs and returns them in favorites list', () async {
    final firstToggle = await service.addOrRemoveFavoriteSong('song_01');
    final secondToggle = await service.addOrRemoveFavoriteSong('song_02');
    final favoriteSongs = await service.getUserFavoriteSong();

    expect(firstToggle, isTrue);
    expect(secondToggle, isTrue);
    expect(
      favoriteSongs.map((song) => song.songId),
      containsAll(['song_01', 'song_02']),
    );
  });

  test('saves and reloads private notes by song id', () async {
    const notes = 'Resumo da musica para a prova.';

    final saveResult = await service.savePrivateNotes('song_03', notes);
    final savedNotes = await service.getPrivateNotes('song_03');

    expect(saveResult, isTrue);
    expect(savedNotes, notes);
  });
}
