import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/data/models/artist/artist.dart';


class DatabaseService {
  final String uid; 

  DatabaseService({required this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('Users');

  DocumentReference<Map<String, dynamic>> get _userDocument => _usersCollection.doc(uid);

  CollectionReference<Map<String, dynamic>> get _favoriteSongsCollection => _userDocument.collection('favorite_songs');

  CollectionReference<Map<String, dynamic>> get _favoriteArtistsCollection => _userDocument.collection('favorite_artists');

  CollectionReference<Map<String, dynamic>> get _favoriteplaylistsCollection => _userDocument.collection('favorite_playlists');

  Future<void> addFavoriteSong(Song song) async {
    final docData = song.toJson();
    docData['addedAt'] = FieldValue.serverTimestamp(); 
    docData['type'] = 'song'; 
    await _favoriteSongsCollection.doc(song.videoId).set(docData);
  }

  Future<void> removeFavoriteSong(String songId) async {
    await _favoriteSongsCollection.doc(songId).delete();
  }

  Stream<bool> isFavoriteSongStream(String songId) {
    return _favoriteSongsCollection.doc(songId).snapshots().map((snapshot) {
      return snapshot.exists;
    });
  }

  Stream<List<Song>> getFavoriteSongsStream() {
    return _favoriteSongsCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Song.fromJson(doc.data())).toList();
        });
  }

  Future<void> addFavoriteArtist(Artist artist) async {
    final docData = artist.toJson();
    docData['addedAt'] = FieldValue.serverTimestamp();
    docData['type'] = 'artist';
    await _favoriteArtistsCollection.doc(artist.channelId).set(docData);
  }

  Future<void> removeFavoriteArtist(String artistId) async {
    await _favoriteArtistsCollection.doc(artistId).delete();
  }
  
  Stream<bool> isFavoriteArtistStream(String artistId) {
    return _favoriteArtistsCollection.doc(artistId).snapshots().map((snapshot) => snapshot.exists);
  }

  Stream<List<Artist>> getFavoriteArtistsStream() {
    return _favoriteArtistsCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Artist.fromJson(doc.data())).toList();
        });
  }

  Future<void> addFavoritePlaylist(String playlistId, Map<String, dynamic> playlistData) async {
    playlistData['addedAt'] = FieldValue.serverTimestamp();
    playlistData['type'] = 'playlist'; 
    await _favoriteplaylistsCollection.doc(playlistId).set(playlistData);
  }

  Future<void> removeFavoritePlaylist(String playlistId) async {
    await _favoriteplaylistsCollection.doc(playlistId).delete();
  }

  Stream<bool> isFavoritePlaylistStream(String playlistId) {
    return _favoriteplaylistsCollection.doc(playlistId).snapshots().map((snapshot) => snapshot.exists);
  }

  Stream<List<Playlist>> getFavoritePlaylistsStream() {
    return _favoriteplaylistsCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Playlist.fromJson(doc.data())).toList();
        });
  }
}