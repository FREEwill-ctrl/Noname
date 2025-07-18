import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationSound {
  bell('bell_notification.wav', 'Bell'),
  chime('chime_notification.wav', 'Chime'),
  ding('ding_notification.wav', 'Ding'),
  alarm('alarm.mp3', 'Alarm'),
  gentle('gentle_notification.wav', 'Gentle'),
  success('success_notification.wav', 'Success');

  const NotificationSound(this.fileName, this.displayName);
  final String fileName;
  final String displayName;
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0.8;
  bool _isEnabled = true;
  NotificationSound _currentSound = NotificationSound.bell;
  bool _vibrationEnabled = true;

  // Getters
  double get volume => _volume;
  bool get isEnabled => _isEnabled;
  NotificationSound get currentSound => _currentSound;
  bool get vibrationEnabled => _vibrationEnabled;

  // Initialize audio service
  Future<void> initialize() async {
    await _loadSettings();
    await _audioPlayer.setVolume(_volume);
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble('audio_volume') ?? 0.8;
      _isEnabled = prefs.getBool('audio_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      
      final soundIndex = prefs.getInt('notification_sound') ?? 0;
      if (soundIndex < NotificationSound.values.length) {
        _currentSound = NotificationSound.values[soundIndex];
      }
    } catch (e) {
      // Use default values if loading fails
      _volume = 0.8;
      _isEnabled = true;
      _vibrationEnabled = true;
      _currentSound = NotificationSound.bell;
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('audio_volume', _volume);
      await prefs.setBool('audio_enabled', _isEnabled);
      await prefs.setBool('vibration_enabled', _vibrationEnabled);
      await prefs.setInt('notification_sound', _currentSound.index);
    } catch (e) {
      // Ignore save errors
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    await _saveSettings();
  }

  // Enable/disable audio
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _saveSettings();
  }

  // Set notification sound
  Future<void> setNotificationSound(NotificationSound sound) async {
    _currentSound = sound;
    await _saveSettings();
  }

  // Enable/disable vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
  }

  // Play notification sound
  Future<void> playNotification({
    NotificationSound? sound,
    double? volume,
    bool? withVibration,
  }) async {
    if (!_isEnabled) return;

    try {
      final soundToPlay = sound ?? _currentSound;
      final volumeToUse = volume ?? _volume;
      final shouldVibrate = withVibration ?? _vibrationEnabled;

      // Set volume for this playback
      await _audioPlayer.setVolume(volumeToUse);

      // Play sound
      await _audioPlayer.play(AssetSource(soundToPlay.fileName));

      // Trigger vibration if enabled
      if (shouldVibrate) {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Fallback to system sound if asset fails
      await HapticFeedback.heavyImpact();
    }
  }

  // Play success sound
  Future<void> playSuccess() async {
    await playNotification(
      sound: NotificationSound.success,
      withVibration: true,
    );
  }

  // Play alarm sound
  Future<void> playAlarm() async {
    await playNotification(
      sound: NotificationSound.alarm,
      withVibration: true,
    );
  }

  // Play gentle notification
  Future<void> playGentle() async {
    await playNotification(
      sound: NotificationSound.gentle,
      withVibration: false,
    );
  }

  // Test current sound
  Future<void> testCurrentSound() async {
    await playNotification();
  }

  // Stop any playing sound
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

// Audio settings widget for UI
class AudioSettings {
  static const List<double> volumeLevels = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
  
  static String getVolumeLabel(double volume) {
    if (volume == 0.0) return 'Mute';
    if (volume <= 0.2) return 'Low';
    if (volume <= 0.6) return 'Medium';
    return 'High';
  }
  
  static String getVolumeIcon(double volume) {
    if (volume == 0.0) return '🔇';
    if (volume <= 0.3) return '🔈';
    if (volume <= 0.7) return '🔉';
    return '🔊';
  }
}

