import 'package:floor/floor.dart';
import '../models/Music.dart';

@dao
abstract class MusicDao {
  @Query('SELECT * FROM Music')
  Future<List<Music>> findAllMusics();

  @Query('SELECT * FROM Music WHERE id = :id')
  Stream<Music?> findMusicById(int id);

  @insert
  Future<void> insertMusic(Music music);

  @insert
  Future<void> insertAllMusics(List<Music> musics);

  @Query("Delete FROM Music")
  Future<void> deleteAllMusics();
}