import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';

@dao
abstract class PlayListMusicDao {
  @Query('SELECT * FROM PlayListMusic')
  Future<List<PlayListMusic>> findAllPlayListMusics();

  @insert
  Future<void> insertAllPlayListMusics(List<PlayListMusic> playListMusic);

  @Query("DELETE FROM PlayListMusic")
  Future<void> deleteAllPlayListMusics();
}
