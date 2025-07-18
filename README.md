# BuildFork Optimized - Advanced Todo & Pomodoro App

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI/CD](https://github.com/FREEwill-ctrl/Noname/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/FREEwill-ctrl/Noname/actions)

An advanced productivity application built with Flutter that combines todo management, Pomodoro technique, and comprehensive analytics to boost your productivity.

## 🚀 Features

### 📝 Advanced Todo Management
- **Eisenhower Matrix**: Categorize tasks by urgency and importance
- **Time Estimation**: Set estimated time for each task
- **Time Tracking**: Track actual time spent on tasks
- **Deadline Management**: Set due dates with smart notifications
- **Priority Filtering**: Filter tasks by priority levels
- **Calendar Integration**: View tasks in calendar format

### ⏱️ Enhanced Pomodoro Timer
- **Customizable Sessions**: Configure work, short break, and long break durations
- **Audio Notifications**: Multiple notification sounds to choose from
- **Session Analytics**: Track completed sessions and productivity patterns
- **Auto-cycle Management**: Automatic transition between work and break sessions
- **Background Operation**: Continue timing even when app is minimized

### 📊 Comprehensive Analytics
- **Time Distribution Charts**: Visualize how you spend your time
- **Productivity Heatmap**: See your most productive days and hours
- **Efficiency Tracking**: Compare estimated vs actual time spent
- **Deadline Performance**: Track your deadline adherence
- **Daily Summary**: Get insights into your daily productivity
- **Progress Trends**: Monitor your productivity improvements over time

### 🎨 Modern User Experience
- **Material Design 3**: Clean, modern interface
- **Dark/Light Themes**: Comfortable viewing in any lighting
- **Responsive Design**: Optimized for phones and tablets
- **Smooth Animations**: Fluid transitions and interactions
- **Accessibility Support**: Screen reader and keyboard navigation support

## 📱 Screenshots

*Screenshots will be added after the first release*

## 🏗️ Architecture

This application follows a modular architecture with clean separation of concerns:

```
lib/
├── features/
│   ├── todo/              # Todo management
│   ├── pomodoro/          # Pomodoro timer
│   └── analytics/         # Analytics and insights
├── shared/                # Shared components and services
└── main.dart             # Application entry point
```

### Key Technologies
- **Flutter 3.16+**: Cross-platform UI framework
- **Provider**: State management
- **SQLite**: Local data persistence
- **FL Chart**: Beautiful charts and graphs
- **Shared Preferences**: Settings storage
- **Audio Players**: Sound notifications

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK 3.16 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FREEwill-ctrl/Noname.git
   cd Noname
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Building for Release

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test files
flutter test test/features/analytics/
```

## 📈 Analytics Features

### Time Tracking
- Automatic time tracking for tasks
- Manual time entry support
- Break time tracking
- Productivity scoring

### Visual Analytics
- **Daily Summary Cards**: Quick overview of daily productivity
- **Time Distribution Pie Chart**: See where your time goes
- **Efficiency Line Chart**: Track productivity trends over time
- **Productivity Heatmap**: Identify your most productive patterns
- **Deadline Performance**: Scatter plot of deadline adherence
- **Estimated vs Actual**: Bar chart comparing time estimates

### Insights
- Productivity patterns identification
- Time estimation accuracy
- Peak productivity hours
- Task completion rates
- Break frequency analysis

## 🔧 Configuration

### Audio Settings
The app includes multiple notification sounds:
- Bell notification
- Chime notification
- Ding notification
- Gentle notification
- Success notification

Configure your preferred sounds in the Pomodoro settings.

### Data Storage
- All data is stored locally using SQLite
- Settings are persisted using SharedPreferences
- No data is sent to external servers

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for inspiration and libraries
- Contributors who help improve this project

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/FREEwill-ctrl/Noname/issues) page
2. Create a new issue if your problem isn't already reported
3. Provide detailed information about your environment and the issue

## 🗺️ Roadmap

- [ ] Cloud synchronization
- [ ] Team collaboration features
- [ ] Advanced reporting
- [ ] Integration with calendar apps
- [ ] Wear OS support
- [ ] Web version
- [ ] AI-powered productivity insights

---

**Built with ❤️ using Flutter**

