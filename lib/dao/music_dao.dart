import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/music.dart';

@dao
abstract class MusicDao {
  @Query('SELECT * FROM Music ORDER BY `date` ASC, `musicId` ASC')
  Future<List<Music>> findAllMusicsASC();

  @Query('SELECT * FROM Music ORDER BY `date` DESC, `musicId` DESC')
  Future<List<Music>> findAllMusicsDESC();

  @Query(
      'SELECT * FROM Music WHERE `existFile` = 1 ORDER BY `date` ASC, `musicId` ASC')
  Future<List<Music>> findAllExistMusicsASC();

  @Query(
      'SELECT * FROM Music WHERE `existFile` = 1 ORDER BY `date` DESC, `musicId` DESC')
  Future<List<Music>> findAllExistMusicsDESC();

  @Query(
      'SELECT * FROM Music WHERE `group` = :group ORDER BY `date` ASC, `musicId` ASC')
  Future<List<Music>> findAllMusicsByGroupASC(String group);

  @Query(
      'SELECT * FROM Music WHERE `group` = :group ORDER BY `date` DESC, `musicId` DESC')
  Future<List<Music>> findAllMusicsByGroupDESC(String group);

  @Query(
      'SELECT * FROM Music WHERE `group` = :group AND `existFile` = 1 ORDER BY `date` ASC, `musicId` ASC')
  Future<List<Music>> findAllExistMusicsByGroupASC(String group);

  @Query(
      'SELECT * FROM Music WHERE `group` = :group AND `existFile` = 1 ORDER BY `date` DESC, `musicId` DESC')
  Future<List<Music>> findAllExistMusicsByGroupDESC(String group);

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
