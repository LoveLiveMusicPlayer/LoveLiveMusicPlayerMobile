import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/album.dart';

@dao
abstract class AlbumDao {
  @Query('SELECT * FROM Album ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllAlbumsASC();

  @Query(
      'SELECT * FROM Album WHERE `category` = :category ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllAlbumsByCategoryASC(String category);

  @Query('SELECT * FROM Album ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllAlbumsDESC();

  @Query(
      'SELECT * FROM Album WHERE `category` = :category ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllAlbumsByCategoryDESC(String category);

  @Query(
      'SELECT * FROM Album WHERE `existFile` = 1 ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllExistAlbumsASC();

  @Query(
      'SELECT * FROM Album WHERE `existFile` = 1 AND `category` = :category ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllExistAlbumsByCategoryASC(String category);

  @Query(
      'SELECT * FROM Album WHERE `existFile` = 1 ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllExistAlbumsDESC();

  @Query(
      'SELECT * FROM Album WHERE `existFile` = 1 AND `category` = :category ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllExistAlbumsByCategoryDESC(String category);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllAlbumsByGroupASC(String group);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllAlbumsByGroupDESC(String group);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllExistAlbumsByGroupASC(String group);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllExistAlbumsByGroupDESC(String group);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 AND `category` = :category ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllAlbumsByGroupAndCategoryASC(
      String group, String category);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 AND `category` = :category ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllAlbumsByGroupAndCategoryDESC(
      String group, String category);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 AND `category` = :category ORDER BY `date` ASC, `albumId` ASC')
  Future<List<Album>> findAllExistAlbumsByGroupAndCategoryASC(
      String group, String category);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 AND `category` = :category ORDER BY `date` DESC, `albumId` DESC')
  Future<List<Album>> findAllExistAlbumsByGroupAndCategoryDESC(
      String group, String category);

  @Query('SELECT * FROM Album WHERE albumId = :albumId')
  Future<Album?> findAlbumByUId(String albumId);

  @insert
  Future<void> insertAlbum(Album album);

  @insert
  Future<void> insertAllAlbums(List<Album> albums);

  @update
  Future<void> updateAlbum(Album album);

  @Query("DELETE FROM Album")
  Future<void> deleteAllAlbums();
}
