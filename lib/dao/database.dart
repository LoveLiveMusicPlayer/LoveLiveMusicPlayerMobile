import 'dart:async';

import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/dao/list_converter.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'album_dao.dart';

part 'database.g.dart';

@TypeConverters([StringListConverter])
@Database(version: 1, entities: [Album, Lyric, Music])
abstract class MusicDatabase extends FloorDatabase {
  AlbumDao get albumDao;

  LyricDao get lyricDao;

  MusicDao get musicDao;
}

// final migration1to2 = Migration(1, 2, (database) async {
//   const createTableSql_relation = '''
//     CREATE TABLE IF NOT EXISTS Lyric (
//     uid TEXT PRIMARY KEY UNIQUE,
//     jp TEXT,
//     zh TEXT,
//     roma TEXT);
//     ''';
//   await database.execute(createTableSql_relation);
// });
