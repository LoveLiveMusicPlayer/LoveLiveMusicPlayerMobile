import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/artist.dart';

@dao
abstract class ArtistDao {
  @Query('SELECT * FROM Artist')
  Future<List<Artist>> findAllArtists();

  @Query('SELECT * FROM Artist WHERE `group` = :group')
  Future<List<Artist>> findAllArtistsByGroup(String group);

  @Query('SELECT * FROM Artist WHERE uid = :artistBin')
  Future<Artist?> findArtistByArtistBin(String artistBin);

  @insert
  Future<void> insertArtist(Artist artist);

  @insert
  Future<void> insertAllArtists(List<Artist> artist);

  @update
  Future<void> updateArtist(Artist artist);

  @Query("DELETE FROM Artist")
  Future<void> deleteAllArtists();
}
