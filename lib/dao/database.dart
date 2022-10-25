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
import 'package:lovelivemusicplayer/dao/splash_dao.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/History.dart';
import 'package:lovelivemusicplayer/models/Splash.dart';
import 'package:lovelivemusicplayer/models/Love.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'album_dao.dart';

part 'database.g.dart';

@TypeConverters([StringListConverter])
@Database(
    version: 4,
    entities: [Album, Lyric, Music, PlayListMusic, Menu, Artist, Love, History, Splash])
abstract class MusicDatabase extends FloorDatabase {
  AlbumDao get albumDao;

  LyricDao get lyricDao;

  MusicDao get musicDao;

  PlayListMusicDao get playListMusicDao;

  MenuDao get menuDao;

  ArtistDao get artistDao;

  LoveDao get loveDao;

  HistoryDao get historyDao;

  SplashDao get splashDao;
}

final migration1to2 = Migration(1, 2, (database) async {
  const alterMusicTableSql = '''
    ALTER TABLE Music ADD COLUMN `date` TEXT
    ''';
  await database.execute(alterMusicTableSql);
});

final migration2to3 = Migration(2, 3, (database) async {
  const insertLoveTableSql = '''
    CREATE TABLE Love (musicId TEXT PRIMARY KEY, timestamp INTEGER)
  ''';
  const insertHistoryTableSql = '''
    CREATE TABLE History (musicId TEXT PRIMARY KEY, timestamp INTEGER)
  ''';
  await database.execute(insertLoveTableSql);
  await database.execute(insertHistoryTableSql);
});

final migration3to4 = Migration(3, 4, (database) async {
  const insertSplashTableSql = '''
    CREATE TABLE Splash (url TEXT PRIMARY KEY)
  ''';
  await database.execute(insertSplashTableSql);
});