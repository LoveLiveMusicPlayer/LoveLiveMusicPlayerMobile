import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/music.dart';

@dao
abstract class MusicDao {
  @Query('SELECT * FROM Music ORDER BY `date`')
  Future<List<Music>> findAllMusics();

  @Query('SELECT * FROM Music WHERE `group` = :group ORDER BY `date`')
  Future<List<Music>> findAllMusicsByGroup(String group);

  @Query(
      'SELECT * FROM Music WHERE `group` = :group AND `existFile` = 1 ORDER BY `date`')
  Future<List<Music>> findAllExistMusicsByGroup(String group);

  @Query('SELECT * FROM Music WHERE name like "%ん%"')
  Future<List<Music>> findAllMusicsTest();

  @Query("SELECT * FROM Music WHERE albumId = :albumId")
  Future<List<Music>> findAllMusicsByAlbumId(String albumId);

  @Query("SELECT * FROM Music WHERE albumId = :albumId AND `existFile` = 1")
  Future<List<Music>> findAllExistMusicsByAlbumId(String albumId);

  @Query('SELECT * FROM Music WHERE musicId = :musicId')
  Future<Music?> findMusicByUId(String musicId);

  @Query(
      "SELECT * FROM Music WHERE `timestamp` > 0 ORDER BY `timestamp` DESC LIMIT 100")
  Future<List<Music>> findRecentMusics();

  @insert
  Future<void> insertMusic(Music music);

  @insert
  Future<void> insertAllMusics(List<Music> musics);

  @update
  Future<void> updateMusic(Music music);

  @Query("DELETE FROM Music")
  Future<void> deleteAllMusics();

  @Query("UPDATE Music SET isLove = REPLACE(isLove, 1, 0)")
  Future<void> deleteAllLove();
}
