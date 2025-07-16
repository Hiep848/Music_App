import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';
import '../../../domain/services/api_service.dart';
import '../../../data/models/song/song.dart';

class TrendingSongsScreen extends StatefulWidget {
  const TrendingSongsScreen({super.key, required this.databaseService});
  final DatabaseService databaseService; 

  @override
  State<TrendingSongsScreen> createState() => _TrendingSongsScreenState();
}

class _TrendingSongsScreenState extends State<TrendingSongsScreen> {
  late Future<List<Song>> _trendingSongsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _trendingSongsFuture = _apiService.fetchTrendingSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thịnh Hành YouTube Music'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: FutureBuilder<List<Song>>(
        future: _trendingSongsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lỗi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hãy đảm bảo Flask server của bạn đang chạy và có thể truy cập được tại ${ApiService.baseUrl}.\n'
                      '- Nếu dùng Android Emulator: ${ApiService.baseUrl} nên là http://10.0.2.2:5000.\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                     const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Thử lại'),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không tìm thấy bài hát thịnh hành nào.'));
          } else {
            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  elevation: 3,
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: song.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              song.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.music_note_rounded, size: 30, color: Colors.grey);
                              },
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : const Icon(Icons.music_note_outlined, size: 30, color: Colors.grey),
                    ),
                    title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text(song.artist, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    trailing: (song.duration != "N/A" && song.duration != null)
                        ? Text(song.duration!, style: const TextStyle(fontSize: 12, color: Colors.black54))
                        : null,
                    onTap: () {
                      final playerService = Provider.of<PlayerService>(context, listen: false);
                      final db = widget.databaseService;
                      playerService.play(song, queue: songs);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          fullscreenDialog: true, 
                          builder: (context) => Provider<DatabaseService>.value(
                            value: db,
                            child: const MusicPlayerScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}