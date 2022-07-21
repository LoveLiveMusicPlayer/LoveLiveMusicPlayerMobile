import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Music.dart';

@dao
abstract class MusicDao {
  @Query('SELECT * FROM Music')
  Future<List<Music>> findAllMusics();

  @Query('SELECT * FROM Music WHERE `group` = :group')
  Future<List<Music>> findAllMusicsByGroup(String group);

  @Query('SELECT * FROM Music WHERE name like "%ん%"')
  Future<List<Music>> findAllMusicsTest();

  @Query("SELECT * FROM Music WHERE albumId = :albumId")
  Future<List<Music>> findAllMusicsByAlbumId(String albumId);

  @Query('SELECT * FROM Music WHERE musicId = :musicId')
  Future<Music?> findMusicByUId(String musicId);

  @Query("SELECT * FROM Music WHERE isLove = true")
  Future<List<Music>> findLovedMusic();

  @Query("SELECT * FROM Music WHERE musicId IN (:musicIds)")
  Future<List<Music>> findMusicsByMusicIds(List<String> musicIds);

  @insert
  Future<void> insertMusic(Music music);

  @insert
  Future<void> insertAllMusics(List<Music> musics);

  @update
  Future<void> updateMusic(Music music);

  @Query("Delete FROM Music")
  Future<void> deleteAllMusics();
}
