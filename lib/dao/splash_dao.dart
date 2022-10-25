import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Splash.dart';

@dao
abstract class SplashDao {
  @Query('SELECT * FROM Splash')
  Future<List<Splash>> findAllSplashUrls();

  @Query("SELECT * FROM Splash WHERE `url` = :url")
  Future<Splash?> findSplashByUrl(String url);

  @insert
  Future<void> insertSplashUrl(Splash splash);

  @Query("DELETE FROM Splash")
  Future<void> deleteAllSplashUrls();
}
