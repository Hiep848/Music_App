import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:test_flutter/presentation/widget/favorite_button.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  void _showTimerSettings(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => TimerSettingsSheet(playerService: playerService),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.timer_outlined, color: Colors.white),
              onPressed: () => _showTimerSettings(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SafeArea(
          // Dùng Consumer để lấy bài hát hiện tại và build lại UI khi nó thay đổi
          child: Selector<PlayerService, Song?>(
            selector: (context, service) => service.currentSong,
            builder: (context, song, child) {
              if (song == null) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              return Column(
                children: [
                  const Spacer(flex: 2),
                  AlbumArt(imageUrl: song.thumbnailUrl),
                  const SizedBox(height: 48),
                  SongInfo(title: song.title, artist: song.artist),
                  const SleepTimerDisplay(),
                  FavoriteButton(song: song),
                  const Spacer(flex: 1),
                  const OptimizedProgressBar(),
                  const SizedBox(height: 16),
                  const OptimizedPlayerControls(),
                  const Spacer(flex: 2),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
  
class AlbumArt extends StatelessWidget {
  final String imageUrl;
  
  const AlbumArt({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey.shade700,
          child: const Icon(Icons.music_note, color: Colors.white, size: 100),
        ),
      ),
    );
  }
} 

// Widget chỉ để hiển thị tên bài hát, nghệ sĩ
class SongInfo extends StatelessWidget {
  final String title;
  final String artist;
  const SongInfo({super.key, required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

class OptimizedProgressBar extends StatelessWidget {
  const OptimizedProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context, listen: false);
    return StreamBuilder<PositionData>(
      stream: Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          playerService.positionStream,
          playerService.audioPlayer.bufferedPositionStream,
          playerService.durationStream,
          (p, b, d) => PositionData(p, b, d ?? Duration.zero)),
      builder: (context, snapshot) {
        final positionData = snapshot.data ?? PositionData(Duration.zero, Duration.zero, Duration.zero);
        return ProgressBar(
          progress: positionData.position,
          buffered: positionData.bufferedPosition,
          total: positionData.duration,
          onSeek: playerService.seek,
          progressBarColor: Colors.white,
          baseBarColor: Colors.white.withOpacity(0.24),
          bufferedBarColor: Colors.white.withOpacity(0.24),
          thumbColor: Colors.white,
          barHeight: 3.0,
          thumbRadius: 5.0,
          timeLabelTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        );
      },
    );
  }
}

// Widget chỉ để quản lý các nút điều khiển
class OptimizedPlayerControls  extends StatelessWidget {
  const OptimizedPlayerControls ({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Selector<PlayerService, bool>(
          selector: (context, service) => service.isShuffleModeEnabled,
          builder: (context, isShuffleOn, child) {
            return IconButton(
              icon: const Icon(Icons.shuffle),
              color: isShuffleOn ? Colors.white : Colors.white70,
              onPressed: playerService.toggleShuffleMode,
            );
          },
        ),
        Selector<PlayerService, bool>(
          selector: (context, service) => service.canGoPrevious,
          builder: (context, canGoPrevious, child) {
            return IconButton(
              icon: Icon(Icons.skip_previous, size: 42),
              color: canGoPrevious ? Colors.white : Colors.white38,
              onPressed: canGoPrevious ? playerService.previous : null,
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: playerService.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return const SizedBox(width: 64, height: 64, child: CircularProgressIndicator(color: Colors.white));
            } else if (playing != true) {
              return IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64), onPressed: playerService.resume);
            } else if (processingState != ProcessingState.completed) {
              return IconButton(icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 64), onPressed: playerService.pause);
            } else {
              return IconButton(
                icon: const Icon(Icons.replay_circle_filled, 
                color: Colors.white, size: 64), 
                onPressed: playerService.replay,
              );
            }
          },
        ),
        Selector<PlayerService, bool>(
          selector: (context, service) => service.canGoNext,
          builder: (context, canGoNext, child) {
            return IconButton(
              icon: Icon(Icons.skip_next, size: 42),
              color: canGoNext ? Colors.white : Colors.white38,
              onPressed: canGoNext ? playerService.next : null,
            );
          },
        ),
        Selector<PlayerService, RepeatMode>(
          selector: (context, service) => service.repeatMode,
          builder: (context, repeatMode, child) {
            IconData icon;
            Color color = Colors.white;
            switch (repeatMode) {
              case RepeatMode.off:
                icon = Icons.repeat;
                color = Colors.white70; // Màu mờ khi tắt
                break;
              case RepeatMode.all:
                icon = Icons.repeat; // Màu sáng khi bật lặp lại tất cả
                break;
              case RepeatMode.one:
                icon = Icons.repeat_one; // Icon khác khi lặp lại một bài
                break;
            }
            return IconButton(
              icon: Icon(icon, color: color),
              onPressed: playerService.toggleRepeatMode,
            );
          },
        ),
      ],
    );
  }
}

class SleepTimerDisplay extends StatelessWidget {
  const SleepTimerDisplay({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context, listen: false);
    return StreamBuilder<Duration?>(
      stream: playerService.sleepTimerDurationStream,
      builder: (context, snapshot) {
        final duration = snapshot.data;
        if (duration == null || duration.inSeconds <= 0) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              "Stop after: ${_formatDuration(duration)}",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        );
      },
    );
  }
}

class TimerSettingsSheet extends StatefulWidget {
  final PlayerService playerService;
  const TimerSettingsSheet({super.key, required this.playerService});

  @override
  State<TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<TimerSettingsSheet> {
  bool _isFadeOutEnabled = false;

  void _setTimer(Duration duration) {
    widget.playerService.setSleepTimer(duration, enableFadeOut: _isFadeOutEnabled);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      children: [
          const Text(
            'Hẹn giờ tắt nhạc',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Các lựa chọn thời gian
          ListTile(
            leading: const Icon(Icons.timer_sharp, color: Colors.white70),
            title: const Text('5 minutes', style: TextStyle(color: Colors.white)),
            onTap: () => _setTimer(const Duration(minutes: 5)),
          ),
          ListTile(
            leading: const Icon(Icons.timer_sharp, color: Colors.white70),
            title: const Text('15 minutes', style: TextStyle(color: Colors.white)),
            onTap: () => _setTimer(const Duration(minutes: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.timer_sharp, color: Colors.white70),
            title: const Text('30 minutes', style: TextStyle(color: Colors.white)),
            onTap: () => _setTimer(const Duration(minutes: 30)),
          ),
          ListTile(
            leading: const Icon(Icons.timer_sharp, color: Colors.white70),
            title: const Text('60 minutes', style: TextStyle(color: Colors.white)),
            onTap: () => _setTimer(const Duration(minutes: 60)),
          ),
          const Divider(color: Colors.white24),
          // Lựa chọn Fade Out
          SwitchListTile(
            title: const Text('Fade out while ending', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Volume will lower gradually in the last 10 seconds', style: TextStyle(color: Colors.white70)),
            value: _isFadeOutEnabled,
            onChanged: (bool value) {
              setState(() {
                _isFadeOutEnabled = value;
              });
            },
            activeColor: Colors.deepPurpleAccent,
          ),
          const Divider(color: Colors.white24),
          // Nút hủy hẹn giờ
          StreamBuilder<Duration?>(
            stream: widget.playerService.sleepTimerDurationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  title: const Text('Cancel timer', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    widget.playerService.cancelSleepTimer();
                    Navigator.of(context).pop();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
         ],
    );
  }
}
