import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/love.dart';

@dao
abstract class LoveDao {
  @Query('SELECT * FROM Love')
  Future<List<Love>> findAllLoves();

  @Query('SELECT * FROM Love WHERE musicId = :musicId')
  Future<Love?> findLoveById(String musicId);

  @insert
  Future<void> insertLove(Love love);

  @insert
  Future<void> insertAllLoves(List<Love> loves);

  @update
  Future<void> updateLove(Love love);

  @Query("DELETE FROM Love WHERE musicId = :musicId")
  Future<void> deleteLoveById(String musicId);

  @Query("DELETE FROM Love")
  Future<void> deleteAllLoves();
}
