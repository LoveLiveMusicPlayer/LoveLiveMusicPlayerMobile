import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Album.dart';

@dao
abstract class AlbumDao {
  @Query('SELECT * FROM Album')
  Future<List<Album>> findAllAlbums();

  @Query('SELECT * FROM Album WHERE `group` = :group')
  Future<List<Album>> findAllAlbumsByGroup(String group);

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
