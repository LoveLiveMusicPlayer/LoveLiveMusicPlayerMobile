import 'dart:async';
import 'package:common_utils/common_utils.dart';
import 'package:floor/floor.dart';
import 'package:lovelivemusicplayer/dao/list_converter.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'album_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@TypeConverters([MusicListConverter, StringListConverter])
@Database(version: 1, entities: [Album])
abstract class MusicDatabase extends FloorDatabase {
  AlbumDao get albumDao;
}