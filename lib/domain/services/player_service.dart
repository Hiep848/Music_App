import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/api_service.dart';


enum RepeatMode { off, all, one }

class PlayerService extends ChangeNotifier {
  // --- Singleton Setup ---
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;

  PlayerService._internal(){
    _loadSettings();
    _setupAudioPlayerListeners();
    _setupCrossfadeListeners();
  }

  @override
  void dispose() {
    cancelSleepTimer(); 
    _sleepTimerDurationSubject.close(); 
    _fadeTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  // --- State ---
  final AudioPlayer audioPlayer = AudioPlayer();
  late SharedPreferences _prefs;
  Song? _currentSong;
  RepeatMode _repeatMode = RepeatMode.off; 

  Timer? _sleepTimer;
  Duration? _sleepTimerDuration;
  final BehaviorSubject<Duration?> _sleepTimerDurationSubject = BehaviorSubject<Duration?>();
  bool _isShuffleModeEnabled = false; 

   // --- Crossfade State ---
  Duration _crossfadeDuration = Duration.zero;
  Timer? _fadeTimer;
  bool _isManuallyFading = false; 

  // --- Getters ---
  Song? get currentSong => _currentSong;
  bool get isPlaying => audioPlayer.playing;
  Stream<PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  RepeatMode get repeatMode => _repeatMode;
  Duration get crossfadeDuration => _crossfadeDuration;

  bool get canGoNext => audioPlayer.hasNext;
  bool get canGoPrevious => audioPlayer.hasPrevious;
  bool get isShuffleModeEnabled => _isShuffleModeEnabled;

  Stream<Duration?> get sleepTimerDurationStream => _sleepTimerDurationSubject.stream;

  // --- Methods ---
  Future<void> play(Song song, {List<Song>? queue}) async {
    var logger = Logger();
    logger.i("Đang cố gắng tải URL: $song");
    await audioPlayer.stop(); 
    final aQueue = queue ?? [song];

    final audioSources = aQueue.map((s) {
      final proxyUrl = '${ApiService.baseUrl}/proxy/${s.videoId}';
      logger.d("Using proxy URL: $proxyUrl");
      return AudioSource.uri(
        Uri.parse(proxyUrl), 
        tag: s);
    }).toList();
    

    logger.i("Tải URL thành công, bắt đầu phát nhạc.");
    final initialIndex = aQueue.indexWhere((s) => s.videoId == song.videoId);
    if (initialIndex == -1) {
      logger.w("Warning: Initial song not found in queue, using index 0");
    }
    try {
      await audioPlayer.setAudioSources(
        audioSources,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      ).timeout(const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Failed to load audio sources within 10 seconds");
        },
    );
      
      await audioPlayer.play();
      audioPlayer.playerStateStream.firstWhere((state) => state.playing).then((_) {
        logger.i("Playback started successfully");
    }).catchError((e) {
      logger.e("Failed to confirm playback: $e");
    });
  }catch (e) {
      logger.e("Error setting audio source: $e");
      if (e is PlayerException) {
        logger.e("Player error code: ${e.code}, message: ${e.message}");
      } else if (e is TimeoutException) {
        logger.e("Timeout error: ${e.message}");
      } else if (e is Exception) {
        logger.e("Exception details: ${e.toString()}");
      }
    }
  }
  Future<void> next() async => await audioPlayer.seekToNext();
  Future<void> previous() async => await audioPlayer.seekToPrevious();
  void resume() => audioPlayer.play();
  void pause() => audioPlayer.pause();
  Future<void> replay() async {
    await audioPlayer.seek(Duration.zero);
    resume();
  }
  void seek(Duration position) => audioPlayer.seek(position);
  Future<void> toggleShuffleMode() async {
    _isShuffleModeEnabled = !_isShuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(_isShuffleModeEnabled);
    notifyListeners();
  }
  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }
  void _setupAudioPlayerListeners() {
    audioPlayer.sequenceStateStream.listen((state) {
      if (state.currentSource?.tag != null) {
        _currentSong = state.currentSource!.tag as Song;
        notifyListeners();
      }
    });

    audioPlayer.playingStream.listen((playing) {
      notifyListeners();
    });
  }
  Future<void> reset() async {
    cancelSleepTimer(); 
    await audioPlayer.stop();
    _currentSong = null;
    notifyListeners();
  }
  void setSleepTimer(Duration duration, {bool enableFadeOut = false}) {
    cancelSleepTimer(); 

    _sleepTimerDuration = duration;
    _sleepTimerDurationSubject.add(_sleepTimerDuration);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimerDuration == null || _sleepTimerDuration! <= Duration.zero) {
        // Hết giờ
        if (enableFadeOut) {
          _startFadeOut();
        } else {
          pause();
        }
        cancelSleepTimer();
      } else {
        // Đếm ngược
        _sleepTimerDuration = _sleepTimerDuration! - const Duration(seconds: 1);
        _sleepTimerDurationSubject.add(_sleepTimerDuration);
      }
    });
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final crossfadeSeconds = _prefs.getInt('crossfadeSeconds') ?? 0;
    _crossfadeDuration = Duration(seconds: crossfadeSeconds);
    notifyListeners();
  }

  Future<void> setCrossfade(Duration duration) async {
    _crossfadeDuration = duration;
    await _prefs.setInt('crossfadeSeconds', duration.inSeconds);
    notifyListeners();
  }

  void _setupCrossfadeListeners() {
    int? previousIndex;
    audioPlayer.sequenceStateStream.listen((state) {
      if (state.currentSource == null || _crossfadeDuration == Duration.zero) return;

      final currentIndex = state.currentIndex;
      if (previousIndex != null && previousIndex != currentIndex) {
        _fadeIn();
      }
      previousIndex = currentIndex;
    });
    audioPlayer.positionStream.listen((position) {
      final duration = audioPlayer.duration;
      if (duration == null || _crossfadeDuration == Duration.zero || _isManuallyFading) return;
      if (duration - position <= _crossfadeDuration) {
        _fadeOut();
      }
    });
  }

  void _fadeOut() {
    if (_isManuallyFading) return;
    _isManuallyFading = true;

    final initialVolume = audioPlayer.volume;
    final fadeSteps = 20;
    final stepInterval = Duration(milliseconds: _crossfadeDuration.inMilliseconds ~/ fadeSteps);
    final volumeStep = initialVolume / fadeSteps;

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(stepInterval, (timer) {
      final newVolume = audioPlayer.volume - volumeStep;
      if (newVolume > 0) {
        audioPlayer.setVolume(newVolume);
      } else {
        audioPlayer.setVolume(0);
        timer.cancel();
      }
    });
  }

  void _fadeIn() {
    _fadeTimer?.cancel();
    audioPlayer.setVolume(0);

    final targetVolume = 1.0;
    final fadeSteps = 20;
    final stepInterval = Duration(milliseconds: _crossfadeDuration.inMilliseconds ~/ fadeSteps);
    final volumeStep = targetVolume / fadeSteps;

    _fadeTimer = Timer.periodic(stepInterval, (timer) {
      final newVolume = audioPlayer.volume + volumeStep;
      if (newVolume < targetVolume) {
        audioPlayer.setVolume(newVolume);
      } else {
        audioPlayer.setVolume(targetVolume); 
        _isManuallyFading = false; 
        timer.cancel();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = null;
    _sleepTimerDurationSubject.add(null);
    notifyListeners();
  }

  Future<void> _startFadeOut() async {
    const fadeDuration = Duration(seconds: 10);
    const fadeSteps = 20;
    final stepInterval = Duration(milliseconds: fadeDuration.inMilliseconds ~/ fadeSteps);
    final initialVolume = audioPlayer.volume;
    final volumeStep = initialVolume / fadeSteps;

    Timer.periodic(stepInterval, (timer) {
      final newVolume = audioPlayer.volume - volumeStep;
      if (newVolume > 0) {
        audioPlayer.setVolume(newVolume);
      } else {
        audioPlayer.pause();
        audioPlayer.setVolume(initialVolume); 
        timer.cancel();
      }
    });
  }
}