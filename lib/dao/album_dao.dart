import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/Album.dart';

@dao
abstract class AlbumDao {
  @Query('SELECT * FROM Album')
  Future<List<Album>> findAllAlbums();

  @Query('SELECT * FROM Album WHERE uid = :uid')
  Future<Album?> findAlbumByUId(String uid);

  @insert
  Future<void> insertAlbum(Album album);

  @insert
  Future<void> insertAllAlbums(List<Album> albums);

  @update
  Future<void> updateAlbum(Album album);

  @Query("Delete FROM Album")
  Future<void> deleteAllAlbums();
}
