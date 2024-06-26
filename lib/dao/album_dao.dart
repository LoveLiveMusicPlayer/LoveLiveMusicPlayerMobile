import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/album.dart';

@dao
abstract class AlbumDao {
  @Query('SELECT * FROM Album ORDER BY `date`')
  Future<List<Album>> findAllAlbums();

  @Query('SELECT * FROM Album WHERE `existFile` = 1 ORDER BY `date`')
  Future<List<Album>> findAllExistAlbums();

  @Query('SELECT * FROM Album WHERE `group` = :group ORDER BY `date`')
  Future<List<Album>> findAllAlbumsByGroup(String group);

  @Query(
      'SELECT * FROM Album WHERE `group` = :group AND `existFile` = 1 ORDER BY `date`')
  Future<List<Album>> findAllExistAlbumsByGroup(String group);

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
