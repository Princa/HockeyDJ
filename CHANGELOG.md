# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-16

### Added
- Initial release of HockeyDJ iOS application
- Core Data models for songs and playlists
- Main playlist view with song list display
- Song detail view for editing song information
- YouTube Music import view with URL parsing
- Audio player manager with playback controls
- Custom start time configuration for songs
- Optional end time configuration for songs
- Drag to reorder songs in playlist
- Swipe to delete songs from playlist
- Play/pause/skip controls
- Empty state view for new users
- Comprehensive README with setup instructions
- Implementation guide documentation

### Features
- 🎵 Create and manage song playlists
- ⏱️ Customize song start and end times
- 🎬 Import from YouTube Music URLs (placeholder implementation)
- ▶️ Playback controls (play, pause, skip forward/backward)
- 📱 iPhone-optimized interface
- 💾 Persistent local storage with Core Data
- 🎨 SwiftUI-based modern interface

### Technical Details
- iOS 16.0+ support
- Swift 5.0
- SwiftUI for all views
- Core Data for persistence
- AVFoundation for audio playback (ready for integration)
- MVVM architecture pattern

### Known Limitations
- YouTube Music integration uses sample data (requires API key for production)
- No real audio streaming yet (requires YouTube extraction library)
- Single playlist support only
- No background playback
- No remote control support

### Coming Soon
- Real YouTube Music API integration
- Spotify integration
- Apple Music integration
- Multiple playlist support
- Offline playback capability
- Background audio playback
- Remote control support

## [Unreleased]

### Planned for v1.1.0
- Real YouTube Music API integration with API key
- Audio streaming implementation
- Background playback support
- Remote control (lock screen controls)

### Planned for v1.2.0
- Spotify integration
- Apple Music integration
- Multiple playlist management
- Playlist templates

### Planned for v2.0.0
- Game timer integration
- Quick play buttons for game events
- Team branding customization
- iPad companion app
- Cloud sync between devices

---

## Version History

- **1.0.0** - Initial release with core functionality
