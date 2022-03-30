import 'dart:collection';
import 'dart:convert';
import 'package:get/get_core/src/get_main.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';

class DB{
  static String albumTabName = "album_tab";

  static DB? _db;
  static final Lock _lock = Lock();
  // static OnAudioRoom? _onAudioRoom;
  static OnAudioQuery? _audioQuery;
  DB._();
  static DB getInstance() {
    if (_db == null) {
      _lock.synchronized(() {
        if (_db == null) {
          var singleton = DB._();
          singleton._analysisJsonData();
          _db = singleton;
        }
      });
    }
    return _db!;
  }



  _analysisJsonData() async {
    _audioQuery = OnAudioQuery();
    await _audioQuery?.createPlaylist(albumTabName);
    await _audioQuery?.createPlaylist(albumTabName);


    // _onAudioRoom = OnAudioRoom();
    // _onAudioRoom?.initRoom(RoomType.PLAYLIST);
    rootBundle.loadString("assets/data.json").then((value){
      HashMap<String,dynamic> decode = json.decode(value);
      initAlbum(decode["album"]);
      // SongData songData = SongData.fromJson(json.decode(value));
      // initAlbum(songData.album!);
      // Future.delayed(Duration(seconds: 10));
      // var queryFavorites = _onAudioRoom?.queryFavorites(limit: 50,reverse: true,sortType: RoomSortType.TITLE);
    });
  }

  void initAlbum(HashMap<String,dynamic> map) async{
    List<AlbumData> list = [];
    map.forEach((key, value) {
      list.add(AlbumData.fromJson(value));
    });

    // OnAudioQuery().queryWithFilters(Get.arguments['albumName'], WithFiltersType.AUDIOS,
    //     args: Get.arguments['type']).then((value) {
    //   // listSong..clear()..addAll(value.map((e) => SongModel(e)).toList());
    // });
  }



}