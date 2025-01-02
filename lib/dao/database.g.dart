// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $MusicDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $MusicDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $MusicDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<MusicDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorMusicDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MusicDatabaseBuilderContract databaseBuilder(String name) =>
      _$MusicDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MusicDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$MusicDatabaseBuilder(null);
}

class _$MusicDatabaseBuilder implements $MusicDatabaseBuilderContract {
  _$MusicDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $MusicDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $MusicDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<MusicDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MusicDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MusicDatabase extends MusicDatabase {
  _$MusicDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AlbumDao? _albumDaoInstance;

  LyricDao? _lyricDaoInstance;

  MusicDao? _musicDaoInstance;

  PlayListMusicDao? _playListMusicDaoInstance;

  MenuDao? _menuDaoInstance;

  ArtistDao? _artistDaoInstance;

  LoveDao? _loveDaoInstance;

  HistoryDao? _historyDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 9,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Album` (`albumId` TEXT, `albumName` TEXT, `date` TEXT, `coverPath` TEXT, `category` TEXT, `group` TEXT, `existFile` INTEGER, PRIMARY KEY (`albumId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Lyric` (`uid` TEXT, `jp` TEXT, `zh` TEXT, `roma` TEXT, PRIMARY KEY (`uid`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Music` (`musicId` TEXT, `musicName` TEXT, `artist` TEXT, `artistBin` TEXT, `albumId` TEXT, `albumName` TEXT, `coverPath` TEXT, `musicPath` TEXT, `time` TEXT, `baseUrl` TEXT, `category` TEXT, `group` TEXT, `isLove` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL, `neteaseId` TEXT, `date` TEXT, `existFile` INTEGER, PRIMARY KEY (`musicId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PlayListMusic` (`musicId` TEXT NOT NULL, `musicName` TEXT NOT NULL, `artist` TEXT NOT NULL, `isPlaying` INTEGER NOT NULL, PRIMARY KEY (`musicId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Menu` (`id` INTEGER NOT NULL, `isPhone` INTEGER NOT NULL, `music` TEXT NOT NULL, `date` TEXT NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Artist` (`id` INTEGER, `uid` TEXT NOT NULL, `name` TEXT NOT NULL, `photo` TEXT NOT NULL, `group` TEXT NOT NULL, `music` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Love` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `musicId` TEXT NOT NULL, `timestamp` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `History` (`musicId` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, PRIMARY KEY (`musicId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AlbumDao get albumDao {
    return _albumDaoInstance ??= _$AlbumDao(database, changeListener);
  }

  @override
  LyricDao get lyricDao {
    return _lyricDaoInstance ??= _$LyricDao(database, changeListener);
  }

  @override
  MusicDao get musicDao {
    return _musicDaoInstance ??= _$MusicDao(database, changeListener);
  }

  @override
  PlayListMusicDao get playListMusicDao {
    return _playListMusicDaoInstance ??=
        _$PlayListMusicDao(database, changeListener);
  }

  @override
  MenuDao get menuDao {
    return _menuDaoInstance ??= _$MenuDao(database, changeListener);
  }

  @override
  ArtistDao get artistDao {
    return _artistDaoInstance ??= _$ArtistDao(database, changeListener);
  }

  @override
  LoveDao get loveDao {
    return _loveDaoInstance ??= _$LoveDao(database, changeListener);
  }

  @override
  HistoryDao get historyDao {
    return _historyDaoInstance ??= _$HistoryDao(database, changeListener);
  }
}

class _$AlbumDao extends AlbumDao {
  _$AlbumDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _albumInsertionAdapter = InsertionAdapter(
            database,
            'Album',
            (Album item) => <String, Object?>{
                  'albumId': item.albumId,
                  'albumName': item.albumName,
                  'date': item.date,
                  'coverPath': item.coverPath,
                  'category': item.category,
                  'group': item.group,
                  'existFile':
                      item.existFile == null ? null : (item.existFile! ? 1 : 0)
                }),
        _albumUpdateAdapter = UpdateAdapter(
            database,
            'Album',
            ['albumId'],
            (Album item) => <String, Object?>{
                  'albumId': item.albumId,
                  'albumName': item.albumName,
                  'date': item.date,
                  'coverPath': item.coverPath,
                  'category': item.category,
                  'group': item.group,
                  'existFile':
                      item.existFile == null ? null : (item.existFile! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Album> _albumInsertionAdapter;

  final UpdateAdapter<Album> _albumUpdateAdapter;

  @override
  Future<List<Album>> findAllAlbumsASC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            date: row['date'] as String?,
            coverPath: row['coverPath'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Album>> findAllAlbumsByCategoryASC(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `category` = ?1 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [category]);
  }

  @override
  Future<List<Album>> findAllAlbumsDESC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            date: row['date'] as String?,
            coverPath: row['coverPath'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Album>> findAllAlbumsByCategoryDESC(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `category` = ?1 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [category]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsASC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `existFile` = 1 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            date: row['date'] as String?,
            coverPath: row['coverPath'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Album>> findAllExistAlbumsByCategoryASC(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `existFile` = 1 AND `category` = ?1 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [category]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsDESC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `existFile` = 1 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            date: row['date'] as String?,
            coverPath: row['coverPath'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Album>> findAllExistAlbumsByCategoryDESC(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `existFile` = 1 AND `category` = ?1 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [category]);
  }

  @override
  Future<List<Album>> findAllAlbumsByGroupASC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Album>> findAllAlbumsByGroupDESC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsByGroupASC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsByGroupDESC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Album>> findAllAlbumsByGroupAndCategoryASC(
    String group,
    String category,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 AND `category` = ?2 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group, category]);
  }

  @override
  Future<List<Album>> findAllAlbumsByGroupAndCategoryDESC(
    String group,
    String category,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 AND `category` = ?2 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group, category]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsByGroupAndCategoryASC(
    String group,
    String category,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 AND `category` = ?2 ORDER BY `date` ASC, `albumId` ASC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group, category]);
  }

  @override
  Future<List<Album>> findAllExistAlbumsByGroupAndCategoryDESC(
    String group,
    String category,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Album WHERE `group` = ?1 AND `existFile` = 1 AND `category` = ?2 ORDER BY `date` DESC, `albumId` DESC',
        mapper: (Map<String, Object?> row) => Album(albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, date: row['date'] as String?, coverPath: row['coverPath'] as String?, category: row['category'] as String?, group: row['group'] as String?, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group, category]);
  }

  @override
  Future<Album?> findAlbumByUId(String albumId) async {
    return _queryAdapter.query('SELECT * FROM Album WHERE albumId = ?1',
        mapper: (Map<String, Object?> row) => Album(
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            date: row['date'] as String?,
            coverPath: row['coverPath'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0),
        arguments: [albumId]);
  }

  @override
  Future<void> deleteAllAlbums() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Album');
  }

  @override
  Future<void> insertAlbum(Album album) async {
    await _albumInsertionAdapter.insert(album, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllAlbums(List<Album> albums) async {
    await _albumInsertionAdapter.insertList(albums, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAlbum(Album album) async {
    await _albumUpdateAdapter.update(album, OnConflictStrategy.abort);
  }
}

class _$LyricDao extends LyricDao {
  _$LyricDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _lyricInsertionAdapter = InsertionAdapter(
            database,
            'Lyric',
            (Lyric item) => <String, Object?>{
                  'uid': item.uid,
                  'jp': item.jp,
                  'zh': item.zh,
                  'roma': item.roma
                }),
        _lyricUpdateAdapter = UpdateAdapter(
            database,
            'Lyric',
            ['uid'],
            (Lyric item) => <String, Object?>{
                  'uid': item.uid,
                  'jp': item.jp,
                  'zh': item.zh,
                  'roma': item.roma
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Lyric> _lyricInsertionAdapter;

  final UpdateAdapter<Lyric> _lyricUpdateAdapter;

  @override
  Future<Lyric?> findLyricById(String uid) async {
    return _queryAdapter.query('SELECT * FROM Lyric WHERE uid = ?1',
        mapper: (Map<String, Object?> row) => Lyric(
            uid: row['uid'] as String?,
            jp: row['jp'] as String?,
            zh: row['zh'] as String?,
            roma: row['roma'] as String?),
        arguments: [uid]);
  }

  @override
  Future<void> deleteAllLyrics() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Lyric');
  }

  @override
  Future<void> insertLyric(Lyric lyric) async {
    await _lyricInsertionAdapter.insert(lyric, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLrc(Lyric lyric) async {
    await _lyricUpdateAdapter.update(lyric, OnConflictStrategy.abort);
  }
}

class _$MusicDao extends MusicDao {
  _$MusicDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _musicInsertionAdapter = InsertionAdapter(
            database,
            'Music',
            (Music item) => <String, Object?>{
                  'musicId': item.musicId,
                  'musicName': item.musicName,
                  'artist': item.artist,
                  'artistBin': item.artistBin,
                  'albumId': item.albumId,
                  'albumName': item.albumName,
                  'coverPath': item.coverPath,
                  'musicPath': item.musicPath,
                  'time': item.time,
                  'baseUrl': item.baseUrl,
                  'category': item.category,
                  'group': item.group,
                  'isLove': item.isLove ? 1 : 0,
                  'timestamp': item.timestamp,
                  'neteaseId': item.neteaseId,
                  'date': item.date,
                  'existFile':
                      item.existFile == null ? null : (item.existFile! ? 1 : 0)
                }),
        _musicUpdateAdapter = UpdateAdapter(
            database,
            'Music',
            ['musicId'],
            (Music item) => <String, Object?>{
                  'musicId': item.musicId,
                  'musicName': item.musicName,
                  'artist': item.artist,
                  'artistBin': item.artistBin,
                  'albumId': item.albumId,
                  'albumName': item.albumName,
                  'coverPath': item.coverPath,
                  'musicPath': item.musicPath,
                  'time': item.time,
                  'baseUrl': item.baseUrl,
                  'category': item.category,
                  'group': item.group,
                  'isLove': item.isLove ? 1 : 0,
                  'timestamp': item.timestamp,
                  'neteaseId': item.neteaseId,
                  'date': item.date,
                  'existFile':
                      item.existFile == null ? null : (item.existFile! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Music> _musicInsertionAdapter;

  final UpdateAdapter<Music> _musicUpdateAdapter;

  @override
  Future<List<Music>> findAllMusicsASC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music ORDER BY `date` ASC, `musicId` ASC',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Music>> findAllMusicsDESC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music ORDER BY `date` DESC, `musicId` DESC',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Music>> findAllExistMusicsASC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `existFile` = 1 ORDER BY `date` ASC, `musicId` ASC',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Music>> findAllExistMusicsDESC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `existFile` = 1 ORDER BY `date` DESC, `musicId` DESC',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Music>> findAllMusicsByGroupASC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `group` = ?1 ORDER BY `date` ASC, `musicId` ASC',
        mapper: (Map<String, Object?> row) => Music(musicId: row['musicId'] as String?, musicName: row['musicName'] as String?, artist: row['artist'] as String?, artistBin: row['artistBin'] as String?, albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, coverPath: row['coverPath'] as String?, musicPath: row['musicPath'] as String?, time: row['time'] as String?, category: row['category'] as String?, group: row['group'] as String?, baseUrl: row['baseUrl'] as String?, date: row['date'] as String?, timestamp: row['timestamp'] as int, neteaseId: row['neteaseId'] as String?, isLove: (row['isLove'] as int) != 0, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Music>> findAllMusicsByGroupDESC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `group` = ?1 ORDER BY `date` DESC, `musicId` DESC',
        mapper: (Map<String, Object?> row) => Music(musicId: row['musicId'] as String?, musicName: row['musicName'] as String?, artist: row['artist'] as String?, artistBin: row['artistBin'] as String?, albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, coverPath: row['coverPath'] as String?, musicPath: row['musicPath'] as String?, time: row['time'] as String?, category: row['category'] as String?, group: row['group'] as String?, baseUrl: row['baseUrl'] as String?, date: row['date'] as String?, timestamp: row['timestamp'] as int, neteaseId: row['neteaseId'] as String?, isLove: (row['isLove'] as int) != 0, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Music>> findAllExistMusicsByGroupASC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `group` = ?1 AND `existFile` = 1 ORDER BY `date` ASC, `musicId` ASC',
        mapper: (Map<String, Object?> row) => Music(musicId: row['musicId'] as String?, musicName: row['musicName'] as String?, artist: row['artist'] as String?, artistBin: row['artistBin'] as String?, albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, coverPath: row['coverPath'] as String?, musicPath: row['musicPath'] as String?, time: row['time'] as String?, category: row['category'] as String?, group: row['group'] as String?, baseUrl: row['baseUrl'] as String?, date: row['date'] as String?, timestamp: row['timestamp'] as int, neteaseId: row['neteaseId'] as String?, isLove: (row['isLove'] as int) != 0, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Music>> findAllExistMusicsByGroupDESC(String group) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `group` = ?1 AND `existFile` = 1 ORDER BY `date` DESC, `musicId` DESC',
        mapper: (Map<String, Object?> row) => Music(musicId: row['musicId'] as String?, musicName: row['musicName'] as String?, artist: row['artist'] as String?, artistBin: row['artistBin'] as String?, albumId: row['albumId'] as String?, albumName: row['albumName'] as String?, coverPath: row['coverPath'] as String?, musicPath: row['musicPath'] as String?, time: row['time'] as String?, category: row['category'] as String?, group: row['group'] as String?, baseUrl: row['baseUrl'] as String?, date: row['date'] as String?, timestamp: row['timestamp'] as int, neteaseId: row['neteaseId'] as String?, isLove: (row['isLove'] as int) != 0, existFile: row['existFile'] == null ? null : (row['existFile'] as int) != 0),
        arguments: [group]);
  }

  @override
  Future<List<Music>> findAllMusicsTest() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE name like \"%ん%\"',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<List<Music>> findAllMusicsByAlbumId(String albumId) async {
    return _queryAdapter.queryList('SELECT * FROM Music WHERE albumId = ?1',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0),
        arguments: [albumId]);
  }

  @override
  Future<List<Music>> findAllExistMusicsByAlbumId(String albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE albumId = ?1 AND `existFile` = 1',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0),
        arguments: [albumId]);
  }

  @override
  Future<Music?> findMusicByUId(String musicId) async {
    return _queryAdapter.query('SELECT * FROM Music WHERE musicId = ?1',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0),
        arguments: [musicId]);
  }

  @override
  Future<List<Music>> findRecentMusics() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Music WHERE `timestamp` > 0 ORDER BY `timestamp` DESC LIMIT 100',
        mapper: (Map<String, Object?> row) => Music(
            musicId: row['musicId'] as String?,
            musicName: row['musicName'] as String?,
            artist: row['artist'] as String?,
            artistBin: row['artistBin'] as String?,
            albumId: row['albumId'] as String?,
            albumName: row['albumName'] as String?,
            coverPath: row['coverPath'] as String?,
            musicPath: row['musicPath'] as String?,
            time: row['time'] as String?,
            category: row['category'] as String?,
            group: row['group'] as String?,
            baseUrl: row['baseUrl'] as String?,
            date: row['date'] as String?,
            timestamp: row['timestamp'] as int,
            neteaseId: row['neteaseId'] as String?,
            isLove: (row['isLove'] as int) != 0,
            existFile: row['existFile'] == null
                ? null
                : (row['existFile'] as int) != 0));
  }

  @override
  Future<void> deleteAllMusics() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Music');
  }

  @override
  Future<void> deleteAllLove() async {
    await _queryAdapter
        .queryNoReturn('UPDATE Music SET isLove = REPLACE(isLove, 1, 0)');
  }

  @override
  Future<void> insertMusic(Music music) async {
    await _musicInsertionAdapter.insert(music, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllMusics(List<Music> musics) async {
    await _musicInsertionAdapter.insertList(musics, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMusic(Music music) async {
    await _musicUpdateAdapter.update(music, OnConflictStrategy.abort);
  }
}

class _$PlayListMusicDao extends PlayListMusicDao {
  _$PlayListMusicDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _playListMusicInsertionAdapter = InsertionAdapter(
            database,
            'PlayListMusic',
            (PlayListMusic item) => <String, Object?>{
                  'musicId': item.musicId,
                  'musicName': item.musicName,
                  'artist': item.artist,
                  'isPlaying': item.isPlaying ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlayListMusic> _playListMusicInsertionAdapter;

  @override
  Future<List<PlayListMusic>> findAllPlayListMusics() async {
    return _queryAdapter.queryList('SELECT * FROM PlayListMusic',
        mapper: (Map<String, Object?> row) => PlayListMusic(
            musicId: row['musicId'] as String,
            musicName: row['musicName'] as String,
            artist: row['artist'] as String,
            isPlaying: (row['isPlaying'] as int) != 0));
  }

  @override
  Future<void> deleteAllPlayListMusics() async {
    await _queryAdapter.queryNoReturn('DELETE FROM PlayListMusic');
  }

  @override
  Future<void> insertAllPlayListMusics(
      List<PlayListMusic> playListMusic) async {
    await _playListMusicInsertionAdapter.insertList(
        playListMusic, OnConflictStrategy.abort);
  }
}

class _$MenuDao extends MenuDao {
  _$MenuDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _menuInsertionAdapter = InsertionAdapter(
            database,
            'Menu',
            (Menu item) => <String, Object?>{
                  'id': item.id,
                  'isPhone': item.isPhone ? 1 : 0,
                  'music': _stringListConverter.encode(item.music),
                  'date': item.date,
                  'name': item.name
                }),
        _menuUpdateAdapter = UpdateAdapter(
            database,
            'Menu',
            ['id'],
            (Menu item) => <String, Object?>{
                  'id': item.id,
                  'isPhone': item.isPhone ? 1 : 0,
                  'music': _stringListConverter.encode(item.music),
                  'date': item.date,
                  'name': item.name
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Menu> _menuInsertionAdapter;

  final UpdateAdapter<Menu> _menuUpdateAdapter;

  @override
  Future<List<Menu>> findAllMenus() async {
    return _queryAdapter.queryList('SELECT * FROM Menu ORDER BY `date`',
        mapper: (Map<String, Object?> row) => Menu(
            id: row['id'] as int,
            isPhone: (row['isPhone'] as int) != 0,
            music: _stringListConverter.decode(row['music'] as String),
            date: row['date'] as String,
            name: row['name'] as String));
  }

  @override
  Future<Menu?> findMenuById(int menuId) async {
    return _queryAdapter.query('SELECT * FROM Menu WHERE `id` = ?1',
        mapper: (Map<String, Object?> row) => Menu(
            id: row['id'] as int,
            isPhone: (row['isPhone'] as int) != 0,
            music: _stringListConverter.decode(row['music'] as String),
            date: row['date'] as String,
            name: row['name'] as String),
        arguments: [menuId]);
  }

  @override
  Future<void> deleteMenuById(int menuId) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Menu WHERE `id` = ?1', arguments: [menuId]);
  }

  @override
  Future<void> deletePcMenu() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Menu WHERE `id` <= 100');
  }

  @override
  Future<void> deleteAllMenus() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Menu');
  }

  @override
  Future<void> insertMenu(Menu menu) async {
    await _menuInsertionAdapter.insert(menu, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMenu(Menu menu) async {
    await _menuUpdateAdapter.update(menu, OnConflictStrategy.abort);
  }
}

class _$ArtistDao extends ArtistDao {
  _$ArtistDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _artistInsertionAdapter = InsertionAdapter(
            database,
            'Artist',
            (Artist item) => <String, Object?>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'photo': item.photo,
                  'group': item.group,
                  'music': _stringListConverter.encode(item.music)
                }),
        _artistUpdateAdapter = UpdateAdapter(
            database,
            'Artist',
            ['id'],
            (Artist item) => <String, Object?>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'photo': item.photo,
                  'group': item.group,
                  'music': _stringListConverter.encode(item.music)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Artist> _artistInsertionAdapter;

  final UpdateAdapter<Artist> _artistUpdateAdapter;

  @override
  Future<List<Artist>> findAllArtists() async {
    return _queryAdapter.queryList('SELECT * FROM Artist',
        mapper: (Map<String, Object?> row) => Artist(
            id: row['id'] as int?,
            uid: row['uid'] as String,
            name: row['name'] as String,
            photo: row['photo'] as String,
            music: _stringListConverter.decode(row['music'] as String),
            group: row['group'] as String));
  }

  @override
  Future<List<Artist>> findAllArtistsByGroup(String group) async {
    return _queryAdapter.queryList('SELECT * FROM Artist WHERE `group` = ?1',
        mapper: (Map<String, Object?> row) => Artist(
            id: row['id'] as int?,
            uid: row['uid'] as String,
            name: row['name'] as String,
            photo: row['photo'] as String,
            music: _stringListConverter.decode(row['music'] as String),
            group: row['group'] as String),
        arguments: [group]);
  }

  @override
  Future<Artist?> findArtistByArtistBinAndGroup(
    String artistBin,
    String group,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM Artist WHERE uid = ?1 AND `group` = ?2',
        mapper: (Map<String, Object?> row) => Artist(
            id: row['id'] as int?,
            uid: row['uid'] as String,
            name: row['name'] as String,
            photo: row['photo'] as String,
            music: _stringListConverter.decode(row['music'] as String),
            group: row['group'] as String),
        arguments: [artistBin, group]);
  }

  @override
  Future<List<Artist?>> findArtistByArtistBin(String artistBin) async {
    return _queryAdapter.queryList('SELECT * FROM Artist WHERE uid = ?1',
        mapper: (Map<String, Object?> row) => Artist(
            id: row['id'] as int?,
            uid: row['uid'] as String,
            name: row['name'] as String,
            photo: row['photo'] as String,
            music: _stringListConverter.decode(row['music'] as String),
            group: row['group'] as String),
        arguments: [artistBin]);
  }

  @override
  Future<void> deleteAllArtists() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Artist');
  }

  @override
  Future<int> insertArtist(Artist artist) {
    return _artistInsertionAdapter.insertAndReturnId(
        artist, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllArtists(List<Artist> artist) async {
    await _artistInsertionAdapter.insertList(artist, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateArtist(Artist artist) async {
    await _artistUpdateAdapter.update(artist, OnConflictStrategy.abort);
  }
}

class _$LoveDao extends LoveDao {
  _$LoveDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _loveInsertionAdapter = InsertionAdapter(
            database,
            'Love',
            (Love item) => <String, Object?>{
                  'id': item.id,
                  'musicId': item.musicId,
                  'timestamp': item.timestamp
                }),
        _loveUpdateAdapter = UpdateAdapter(
            database,
            'Love',
            ['id'],
            (Love item) => <String, Object?>{
                  'id': item.id,
                  'musicId': item.musicId,
                  'timestamp': item.timestamp
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Love> _loveInsertionAdapter;

  final UpdateAdapter<Love> _loveUpdateAdapter;

  @override
  Future<List<Love>> findAllLovesASC() async {
    return _queryAdapter.queryList('SELECT * FROM Love ORDER BY `id` ASC',
        mapper: (Map<String, Object?> row) => Love(
            timestamp: row['timestamp'] as int,
            musicId: row['musicId'] as String,
            id: row['id'] as int?));
  }

  @override
  Future<List<Love>> findAllLovesDESC() async {
    return _queryAdapter.queryList('SELECT * FROM Love ORDER BY `id` DESC',
        mapper: (Map<String, Object?> row) => Love(
            timestamp: row['timestamp'] as int,
            musicId: row['musicId'] as String,
            id: row['id'] as int?));
  }

  @override
  Future<Love?> findLoveById(String musicId) async {
    return _queryAdapter.query('SELECT * FROM Love WHERE musicId = ?1',
        mapper: (Map<String, Object?> row) => Love(
            timestamp: row['timestamp'] as int,
            musicId: row['musicId'] as String,
            id: row['id'] as int?),
        arguments: [musicId]);
  }

  @override
  Future<void> deleteLoveById(String musicId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Love WHERE musicId = ?1',
        arguments: [musicId]);
  }

  @override
  Future<void> deleteAllLoves() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Love');
  }

  @override
  Future<void> insertLove(Love love) async {
    await _loveInsertionAdapter.insert(love, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllLoves(List<Love> loves) async {
    await _loveInsertionAdapter.insertList(loves, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLove(Love love) async {
    await _loveUpdateAdapter.update(love, OnConflictStrategy.abort);
  }
}

class _$HistoryDao extends HistoryDao {
  _$HistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _historyInsertionAdapter = InsertionAdapter(
            database,
            'History',
            (History item) => <String, Object?>{
                  'musicId': item.musicId,
                  'timestamp': item.timestamp
                }),
        _historyUpdateAdapter = UpdateAdapter(
            database,
            'History',
            ['musicId'],
            (History item) => <String, Object?>{
                  'musicId': item.musicId,
                  'timestamp': item.timestamp
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<History> _historyInsertionAdapter;

  final UpdateAdapter<History> _historyUpdateAdapter;

  @override
  Future<List<History>> findAllHistorysASC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM History ORDER BY `timestamp` ASC LIMIT 100',
        mapper: (Map<String, Object?> row) => History(
            musicId: row['musicId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<List<History>> findAllHistorysDESC() async {
    return _queryAdapter.queryList(
        'SELECT * FROM History ORDER BY `timestamp` DESC LIMIT 100',
        mapper: (Map<String, Object?> row) => History(
            musicId: row['musicId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<History?> findHistoryById(String musicId) async {
    return _queryAdapter.query('SELECT * FROM History WHERE musicId = ?1',
        mapper: (Map<String, Object?> row) => History(
            musicId: row['musicId'] as String,
            timestamp: row['timestamp'] as int),
        arguments: [musicId]);
  }

  @override
  Future<void> deleteHistoryById(String musicId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM History WHERE musicId = ?1',
        arguments: [musicId]);
  }

  @override
  Future<void> deleteAllHistorys() async {
    await _queryAdapter.queryNoReturn('DELETE FROM History');
  }

  @override
  Future<void> insertHistory(History history) async {
    await _historyInsertionAdapter.insert(history, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateHistory(History history) async {
    await _historyUpdateAdapter.update(history, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _stringListConverter = StringListConverter();
