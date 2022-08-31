import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';

@dao
abstract class MenuDao {
  @Query('SELECT * FROM Menu')
  Future<List<Menu>> findAllMenus();

  @Query('SELECT * FROM Menu WHERE `id` = :menuId')
  Future<Menu?> findMenuById(int menuId);

  @insert
  Future<void> insertMenu(Menu menu);

  @update
  Future<void> updateMenu(Menu menu);

  @Query("DELETE FROM Menu WHERE `id` = :menuId")
  Future<void> deleteMenuById(int menuId);

  @Query("DELETE FROM Menu")
  Future<void> deleteAllMenus();
}
