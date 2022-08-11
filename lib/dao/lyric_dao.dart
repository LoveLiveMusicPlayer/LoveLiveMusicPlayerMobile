import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';

@dao
abstract class LyricDao {
  @Query('SELECT * FROM Lyric WHERE uid = :uid')
  Future<Lyric?> findLyricById(String uid);

  @insert
  Future<void> insertLyric(Lyric lyric);

  @update
  Future<void> updateLrc(Lyric lyric);

  @Query("DELETE FROM Lyric")
  Future<void> deleteAllLyrics();
}
