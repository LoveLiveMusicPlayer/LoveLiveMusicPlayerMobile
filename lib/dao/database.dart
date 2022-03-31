import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/dao/list_converter.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import '../models/Music.dart';
import 'album_dao.dart';
import 'music_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@TypeConverters([StringListConverter])
@Database(version: 1, entities: [Music, Album])
abstract class MusicDatabase extends FloorDatabase {
  MusicDao get musicDao;
  AlbumDao get albumDao;
}