import 'dart:async';

import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/dao/artist_dao.dart';
import 'package:lovelivemusicplayer/dao/history_dao.dart';
import 'package:lovelivemusicplayer/dao/list_converter.dart';
import 'package:lovelivemusicplayer/dao/love_dao.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/menu_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/dao/playlist_dao.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/history.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/lyric.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/play_list_music.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'album_dao.dart';

part 'database.g.dart';

@TypeConverters([StringListConverter])
@Database(
    version: 8,
    entities: [Album, Lyric, Music, PlayListMusic, Menu, Artist, Love, History])
abstract class MusicDatabase extends FloorDatabase {
  AlbumDao get albumDao;

  LyricDao get lyricDao;

  MusicDao get musicDao;

  PlayListMusicDao get playListMusicDao;

  MenuDao get menuDao;

  ArtistDao get artistDao;

  LoveDao get loveDao;

  HistoryDao get historyDao;
}

final migration1to2 = Migration(1, 2, (database) async {
  const alterMusicTableSql = '''ALTER TABLE Music ADD COLUMN `date` TEXT''';
  await database.execute(alterMusicTableSql);
});

final migration2to3 = Migration(2, 3, (database) async {
  const insertLoveTableSql =
      '''CREATE TABLE Love (musicId TEXT PRIMARY KEY, timestamp INTEGER)''';
  const insertHistoryTableSql =
      '''CREATE TABLE History (musicId TEXT PRIMARY KEY, timestamp INTEGER)''';
  await database.execute(insertLoveTableSql);
  await database.execute(insertHistoryTableSql);
});

final migration3to4 = Migration(3, 4, (database) async {
  const insertSplashTableSql = '''CREATE TABLE Splash (url TEXT PRIMARY KEY)''';
  await database.execute(insertSplashTableSql);
});

final migration4to5 = Migration(4, 5, (database) async {
  const alterMusicTableSql =
      '''ALTER TABLE Music ADD COLUMN `neteaseId` TEXT''';
  await database.execute(alterMusicTableSql);
});

final migration5to6 = Migration(5, 6, (database) async {
  const alterAlbumTableSql =
      '''ALTER TABLE Album ADD COLUMN `existFile` BOOLEAN''';
  const alterMusicTableSql =
      '''ALTER TABLE Music ADD COLUMN `existFile` BOOLEAN''';
  await database.execute(alterAlbumTableSql);
  await database.execute(alterMusicTableSql);
});

final migration6to7 = Migration(6, 7, (database) async {
  const alterArtistTableSql1 = '''ALTER TABLE Artist RENAME TO Artist_old''';
  const alterArtistTableSql2 = '''
  CREATE TABLE Artist (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "uid" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "photo" TEXT NOT NULL,
    "group" TEXT NOT NULL,
    "music" TEXT NOT NULL
  )
  ''';
  const alterArtistTableSql3 =
      '''INSERT INTO Artist ("uid", "name", "photo", "group", "music") SELECT "uid", "name", "photo", "group", "music" FROM Artist_old''';
  const alterArtistTableSql4 = '''DROP TABLE Artist_old''';
  await database.execute(alterArtistTableSql1);
  await database.execute(alterArtistTableSql2);
  await database.execute(alterArtistTableSql3);
  await database.execute(alterArtistTableSql4);
});

final migration7to8 = Migration(7, 8, (database) async {
  const dropTableSql = '''DROP TABLE IF EXISTS Splash''';
  await database.execute(dropTableSql);
});
