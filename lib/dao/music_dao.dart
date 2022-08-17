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

  @Query("SELECT * FROM Music WHERE artistBin = :artistBin")
  Future<List<Music>> findAllMusicsByArtistBin(String artistBin);

  @insert
  Future<void> insertMusic(Music music);

  @insert
  Future<void> insertAllMusics(List<Music> musics);

  @update
  Future<void> updateMusic(Music music);

  @Query("UPDATE Music SET isLove = :isLove WHERE musicId IN (:musicIds)")
  Future<void> updateLoveStatus(bool isLove, List<String> musicIds);

  @Query("DELETE FROM Music")
  Future<void> deleteAllMusics();
}
