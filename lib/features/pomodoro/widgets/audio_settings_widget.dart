import 'package:flutter/material.dart';
import '../../../shared/audio_service.dart';

class AudioSettingsWidget extends StatefulWidget {
  const AudioSettingsWidget({super.key});

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget> {
  final AudioService _audioService = AudioService();
  late bool _isEnabled;
  late double _volume;
  late NotificationSound _selectedSound;
  late bool _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _isEnabled = _audioService.isEnabled;
    _volume = _audioService.volume;
    _selectedSound = _audioService.currentSound;
    _vibrationEnabled = _audioService.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio Settings',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Enable/Disable Audio
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Play sound when sessions complete'),
              value: _isEnabled,
              onChanged: (value) async {
                setState(() {
                  _isEnabled = value;
                });
                await _audioService.setEnabled(value);
              },
            ),
            
            if (_isEnabled) ...[
              const Divider(),
              
              // Volume Control
              ListTile(
                title: const Text('Volume'),
                subtitle: Text(AudioSettings.getVolumeLabel(_volume)),
                trailing: Text(AudioSettings.getVolumeIcon(_volume)),
              ),
              Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(_volume * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                },
                onChangeEnd: (value) async {
                  await _audioService.setVolume(value);
                },
              ),
              
              const SizedBox(height: 8),
              
              // Sound Selection
              ListTile(
                title: const Text('Notification Sound'),
                subtitle: Text(_selectedSound.displayName),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    await _audioService.testCurrentSound();
                  },
                ),
              ),
              
              // Sound Options
              Wrap(
                spacing: 8,
                children: NotificationSound.values.map((sound) {
                  return ChoiceChip(
                    label: Text(sound.displayName),
                    selected: _selectedSound == sound,
                    onSelected: (selected) async {
                      if (selected) {
                        setState(() {
                          _selectedSound = sound;
                        });
                        await _audioService.setNotificationSound(sound);
                        await _audioService.testCurrentSound();
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Vibration Setting
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate when notifications play'),
                value: _vibrationEnabled,
                onChanged: (value) async {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                  await _audioService.setVibrationEnabled(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

