import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../analytics/providers/time_tracking_provider.dart';
import '../../../main.dart';
import '../../../shared/audio_service.dart';

enum PomodoroState { initial, running, paused, stopped }

enum SessionType { pomodoro, shortBreak, longBreak }

class PomodoroProvider with ChangeNotifier {
  PomodoroState _state = PomodoroState.initial;
  PomodoroState get state => _state;
  
  int _pomodoroCount = 0;
  int get pomodoroCount => _pomodoroCount;
  
  int _secondsRemaining = 25 * 60;
  int get secondsRemaining => _secondsRemaining;
  
  SessionType _sessionType = SessionType.pomodoro;
  SessionType get sessionType => _sessionType;
  
  int _cycle = 0;
  int get cycle => _cycle;
  
  Timer? _timer;
  final AudioService _audioService = AudioService();

  // Customizable durations
  int _pomodoroMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int get pomodoroMinutes => _pomodoroMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;

  // Statistics
  int _todayPomodoro = 0;
  int _weekPomodoro = 0;
  int _totalPomodoro = 0;
  DateTime? _lastPomodoroDate;
  int get todayPomodoro => _todayPomodoro;
  int get weekPomodoro => _weekPomodoro;
  int get totalPomodoro => _totalPomodoro;

  // Task linking
  String? _linkedTaskId;
  String? get linkedTaskId => _linkedTaskId;

  // Auto-start settings
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;

  // Progress tracking
  double get progress {
    final totalDuration = _getCurrentSessionDuration();
    if (totalDuration == 0) return 0.0;
    return (totalDuration - _secondsRemaining) / totalDuration;
  }

  PomodoroProvider() {
    _loadSettings();
    _loadStats();
    _audioService.initialize();
  }

  // Duration getters
  int get _pomodoroDuration => _pomodoroMinutes * 60;
  int get _shortBreakDuration => _shortBreakMinutes * 60;
  int get _longBreakDuration => _longBreakMinutes * 60;

  int _getCurrentSessionDuration() {
    switch (_sessionType) {
      case SessionType.pomodoro:
        return _pomodoroDuration;
      case SessionType.shortBreak:
        return _shortBreakDuration;
      case SessionType.longBreak:
        return _longBreakDuration;
    }
  }

  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeDisplayName {
    switch (_sessionType) {
      case SessionType.pomodoro:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color get sessionTypeColor {
    switch (_sessionType) {
      case SessionType.pomodoro:
        return Colors.red.shade400;
      case SessionType.shortBreak:
        return Colors.green.shade400;
      case SessionType.longBreak:
        return Colors.blue.shade400;
    }
  }

  // Settings management
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pomodoroMinutes = prefs.getInt('pomodoro_minutes') ?? 25;
      _shortBreakMinutes = prefs.getInt('short_break_minutes') ?? 5;
      _longBreakMinutes = prefs.getInt('long_break_minutes') ?? 15;
      _autoStartBreaks = prefs.getBool('auto_start_breaks') ?? false;
      _autoStartPomodoros = prefs.getBool('auto_start_pomodoros') ?? false;
      reset();
    } catch (e) {
      // Use default values
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pomodoro_minutes', _pomodoroMinutes);
      await prefs.setInt('short_break_minutes', _shortBreakMinutes);
      await prefs.setInt('long_break_minutes', _longBreakMinutes);
      await prefs.setBool('auto_start_breaks', _autoStartBreaks);
      await prefs.setBool('auto_start_pomodoros', _autoStartPomodoros);
    } catch (e) {
      // Ignore save errors
    }
  }

  // Configuration methods
  void setDurations(int pomodoro, int shortBreak, int longBreak) {
    _pomodoroMinutes = pomodoro.clamp(1, 60);
    _shortBreakMinutes = shortBreak.clamp(1, 30);
    _longBreakMinutes = longBreak.clamp(1, 60);
    reset();
    _saveSettings();
    notifyListeners();
  }

  void setAutoStart({bool? breaks, bool? pomodoros}) {
    if (breaks != null) _autoStartBreaks = breaks;
    if (pomodoros != null) _autoStartPomodoros = pomodoros;
    _saveSettings();
    notifyListeners();
  }

  void linkToTask(String taskId) {
    _linkedTaskId = taskId;
    notifyListeners();
  }

  void unlinkTask() {
    _linkedTaskId = null;
    notifyListeners();
  }

  // Timer control methods
  void start() {
    if (_state == PomodoroState.running) return;
    
    _state = PomodoroState.running;
    HapticFeedback.lightImpact();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _onSessionComplete();
      }
    });
    notifyListeners();
  }

  void pause() {
    if (_state != PomodoroState.running) return;
    
    _state = PomodoroState.paused;
    _timer?.cancel();
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = PomodoroState.initial;
    _secondsRemaining = _getCurrentSessionDuration();
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    _onSessionComplete();
  }

  void switchToPomodoro() {
    _timer?.cancel();
    _sessionType = SessionType.pomodoro;
    _state = PomodoroState.initial;
    _secondsRemaining = _pomodoroDuration;
    notifyListeners();
  }

  void switchToShortBreak() {
    _timer?.cancel();
    _sessionType = SessionType.shortBreak;
    _state = PomodoroState.initial;
    _secondsRemaining = _shortBreakDuration;
    notifyListeners();
  }

  void switchToLongBreak() {
    _timer?.cancel();
    _sessionType = SessionType.longBreak;
    _state = PomodoroState.initial;
    _secondsRemaining = _longBreakDuration;
    notifyListeners();
  }

  // Session completion handling
  Future<void> _onSessionComplete() async {
    // Play completion sound
    if (_sessionType == SessionType.pomodoro) {
      await _audioService.playSuccess();
    } else {
      await _audioService.playGentle();
    }

    // Handle analytics integration
    if (_sessionType == SessionType.pomodoro && _linkedTaskId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final timeTracking = Provider.of<TimeTrackingProvider>(context, listen: false);
        timeTracking.linkTaskWithPomodoro(_linkedTaskId!);
        timeTracking.syncPomodoroTaskTime(Duration(seconds: _pomodoroDuration));
        timeTracking.notifyPomodoroCompleted(context);
      }
    }

    // Update statistics and cycle
    if (_sessionType == SessionType.pomodoro) {
      _pomodoroCount++;
      _cycle++;
      _updateStats();
      
      // Determine next session
      if (_cycle % 4 == 0) {
        _sessionType = SessionType.longBreak;
        _secondsRemaining = _longBreakDuration;
      } else {
        _sessionType = SessionType.shortBreak;
        _secondsRemaining = _shortBreakDuration;
      }
      
      // Auto-start break if enabled
      if (_autoStartBreaks) {
        _startAutoTimer();
      }
    } else {
      // Break completed, switch to pomodoro
      _sessionType = SessionType.pomodoro;
      _secondsRemaining = _pomodoroDuration;
      
      // Auto-start pomodoro if enabled
      if (_autoStartPomodoros) {
        _startAutoTimer();
      }
    }

    _state = PomodoroState.stopped;
    notifyListeners();
  }

  void _startAutoTimer() {
    // Add a small delay before auto-starting
    Timer(const Duration(seconds: 2), () {
      if (_state == PomodoroState.stopped) {
        start();
      }
    });
  }

  // Statistics management
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _todayPomodoro = prefs.getInt('todayPomodoro') ?? 0;
      _weekPomodoro = prefs.getInt('weekPomodoro') ?? 0;
      _totalPomodoro = prefs.getInt('totalPomodoro') ?? 0;
      final lastDateStr = prefs.getString('lastPomodoroDate');
      if (lastDateStr != null) {
        _lastPomodoroDate = DateTime.tryParse(lastDateStr);
      }
      _checkStatsReset();
      notifyListeners();
    } catch (e) {
      // Use default values
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('todayPomodoro', _todayPomodoro);
      await prefs.setInt('weekPomodoro', _weekPomodoro);
      await prefs.setInt('totalPomodoro', _totalPomodoro);
      await prefs.setString('lastPomodoroDate', DateTime.now().toIso8601String());
    } catch (e) {
      // Ignore save errors
    }
  }

  void _checkStatsReset() {
    final now = DateTime.now();
    if (_lastPomodoroDate == null) return;
    
    // Reset daily stats
    if (_lastPomodoroDate!.day != now.day || 
        _lastPomodoroDate!.month != now.month || 
        _lastPomodoroDate!.year != now.year) {
      _todayPomodoro = 0;
    }
    
    // Reset weekly stats (Monday)
    if (now.weekday == DateTime.monday && 
        _lastPomodoroDate!.weekday != DateTime.monday) {
      _weekPomodoro = 0;
    }
  }

  void _updateStats() {
    final now = DateTime.now();
    
    // Check if we need to reset daily/weekly stats
    if (_lastPomodoroDate == null || 
        _lastPomodoroDate!.day != now.day || 
        _lastPomodoroDate!.month != now.month || 
        _lastPomodoroDate!.year != now.year) {
      _todayPomodoro = 0;
    }
    
    if (_lastPomodoroDate == null || 
        (now.weekday == DateTime.monday && _lastPomodoroDate!.weekday != DateTime.monday)) {
      _weekPomodoro = 0;
    }
    
    _todayPomodoro++;
    _weekPomodoro++;
    _totalPomodoro++;
    _lastPomodoroDate = now;
    _saveStats();
  }

  // Utility methods
  String getTimeRemaining() {
    return formattedTime;
  }

  bool get isRunning => _state == PomodoroState.running;
  bool get isPaused => _state == PomodoroState.paused;
  bool get isStopped => _state == PomodoroState.stopped;
  bool get isInitial => _state == PomodoroState.initial;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

