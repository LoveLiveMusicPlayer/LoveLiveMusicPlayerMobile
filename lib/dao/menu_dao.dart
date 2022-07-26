import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';

@dao
abstract class MenuDao {
  @Query('SELECT * FROM Menu')
  Future<List<Menu>> findAllMenus();

  @insert
  Future<void> insertMenu(Menu menu);

  @update
  Future<void> updateMenu(Menu menu);

  @Query("Delete FROM Menu")
  Future<void> deleteAllMenus();
}
