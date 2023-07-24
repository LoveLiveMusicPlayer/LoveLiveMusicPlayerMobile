import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/models/artist.dart';

@dao
abstract class ArtistDao {
  @Query('SELECT * FROM Artist')
  Future<List<Artist>> findAllArtists();

  @Query('SELECT * FROM Artist WHERE `group` = :group')
  Future<List<Artist>> findAllArtistsByGroup(String group);

  @Query('SELECT * FROM Artist WHERE uid = :artistBin AND `group` = :group')
  Future<Artist?> findArtistByArtistBinAndGroup(String artistBin, String group);

  @Query('SELECT * FROM Artist WHERE uid = :artistBin')
  Future<List<Artist?>> findArtistByArtistBin(String artistBin);

  @insert
  Future<int> insertArtist(Artist artist);

  Future<void> insertArtistWithId(Artist object) async {
    object.id = await insertArtist(object);
  }

  @insert
  Future<void> insertAllArtists(List<Artist> artist);

  @update
  Future<void> updateArtist(Artist artist);

  @Query("DELETE FROM Artist")
  Future<void> deleteAllArtists();
}
