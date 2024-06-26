import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/history.dart';

@dao
abstract class HistoryDao {
  @Query('SELECT * FROM History ORDER BY `timestamp` ASC LIMIT 100')
  Future<List<History>> findAllHistorysASC();

  @Query('SELECT * FROM History ORDER BY `timestamp` DESC LIMIT 100')
  Future<List<History>> findAllHistorysDESC();

  @Query('SELECT * FROM History WHERE musicId = :musicId')
  Future<History?> findHistoryById(String musicId);

  @insert
  Future<void> insertHistory(History history);

  @update
  Future<void> updateHistory(History history);

  @Query("DELETE FROM History WHERE musicId = :musicId")
  Future<void> deleteHistoryById(String musicId);

  @Query("DELETE FROM History")
  Future<void> deleteAllHistorys();
}
