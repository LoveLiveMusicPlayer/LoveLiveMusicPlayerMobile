import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';

@dao
abstract class MenuDao {
  @Query('SELECT * FROM Menu')
  Future<List<Menu>> findAllMenus();

  @Query('SELECT * FROM Menu where `id` = :menuId')
  Future<Menu?> findMenuById(int menuId);
  
  @Query('SELECT `id` From Menu')
  Future<List<int>?> findMenuIds();

  @insert
  Future<void> insertMenu(Menu menu);

  @update
  Future<void> updateMenu(Menu menu);

  @Query("Delete FROM Menu")
  Future<void> deleteAllMenus();
}
