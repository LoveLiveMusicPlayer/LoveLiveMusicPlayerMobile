import 'dart:convert';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:flutter/services.dart';
import 'package:lovelivemusicplayer/models/song_data.dart';
import 'package:synchronized/synchronized.dart';

class DB{
  static DB? _db;
  static final Lock _lock = Lock();
  static OnAudioRoom? _onAudioRoom;
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



  _analysisJsonData(){
    _onAudioRoom = OnAudioRoom();
    _onAudioRoom?.initRoom(RoomType.PLAYLIST);
    rootBundle.loadString("assets/data.json").then((value){
      SongData songData = SongData.fromJson(json.decode(value));
      initAlbum(songData.album!);
      Future.delayed(Duration(seconds: 10));
      var queryFavorites = _onAudioRoom?.queryFavorites(limit: 50,reverse: true,sortType: RoomSortType.TITLE);
      _onAudioRoom?.queryFromFavorites();
    });
  }

  void initAlbum(Album album) async{
    List<AlbumAqour> list = [];
    list.addAll(album.aqours);
    list.addAll(album.combine);
    list.addAll(album.liella);
    list.addAll(album.nijigasaki);
    list.addAll(album.s);
    List<int>? listKey = await _onAudioRoom?.addAllTo(RoomType.PLAYLIST, list);
  }
  void initMusic(Music music){

  }



}