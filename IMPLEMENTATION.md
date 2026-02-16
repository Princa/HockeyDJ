# HockeyDJ - Implementation Guide

## Overview

HockeyDJ is an iOS application designed for Hockey Game DJs to manage music during games. The app allows importing songs from YouTube Music, customizing start/stop times, and playing songs with precise control.

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel pattern with SwiftUI:

- **Models**: Plain Swift structs (`Song`, `Playlist`)
- **Views**: SwiftUI views (`PlaylistView`, `SongDetailView`, etc.)
- **ViewModels**: Observable objects (`AudioPlayerManager`, `YouTubeMusicService`)

### Data Layer
- **Core Data**: Used for persistent storage
- **Entities**: `SongEntity`, `PlaylistEntity`
- **PersistenceController**: Manages Core Data stack

## Key Components

### 1. Audio Player Manager

```swift
class AudioPlayerManager: ObservableObject
```

**Responsibilities:**
- Manage audio playback state
- Handle play/pause/stop operations
- Seek to custom start times
- Monitor playback progress
- Stop at custom end times

**Future Enhancements:**
- Integrate with real audio streaming (YouTube Music)
- Add audio session interruption handling
- Implement background playback
- Add remote control support

### 2. YouTube Music Service

```swift
class YouTubeMusicService: ObservableObject
```

**Responsibilities:**
- Parse YouTube URLs (playlists and videos)
- Fetch song metadata from YouTube API
- Convert YouTube data to Song objects

**Current State:**
- Uses sample data for demonstration
- URL parsing is implemented
- Ready for YouTube Data API v3 integration

**Required for Production:**
```swift
// 1. Add API key
let apiKey = "YOUR_YOUTUBE_API_KEY"

// 2. Implement API calls
func fetchPlaylistSongs(playlistId: String) async throws -> [Song] {
    let url = "https://www.googleapis.com/youtube/v3/playlistItems"
    // ... implement API call
}

// 3. Add OAuth for user libraries
// Use Google Sign-In SDK
```

### 3. Views

#### PlaylistView
- Displays all songs in the current playlist
- Shows empty state when no songs exist
- Provides song management (delete, reorder)
- Displays player controls when a song is playing

#### SongDetailView
- Allows editing song metadata
- Provides time pickers for start/end times
- Saves changes to Core Data

#### YouTubeMusicImportView
- Accepts YouTube URLs
- Shows import instructions
- Handles import process
- Displays error messages

## Data Flow

```
User Action → View → Service/Manager → Core Data → View Update
```

Example: Importing a playlist
1. User enters URL in `YouTubeMusicImportView`
2. `YouTubeMusicService` parses URL and fetches songs
3. Songs are saved to Core Data via `PersistenceController`
4. `PlaylistView` automatically updates (SwiftUI + FetchRequest)

## Testing Strategy

### Unit Tests
- Test Song and Playlist model conversions
- Test URL parsing in YouTubeMusicService
- Test time formatting functions

### Integration Tests
- Test Core Data operations
- Test view model state changes
- Test navigation flow

### UI Tests
- Test import flow
- Test song editing flow
- Test playback controls

## Deployment Considerations

### App Store Requirements
1. **Privacy Policy**: Required for YouTube data usage
2. **Permissions**: Audio playback doesn't require special permissions
3. **API Keys**: Secure storage of YouTube API key
4. **Third-party SDKs**: If using YouTube extraction libraries

### Performance Optimization
- Lazy loading of thumbnails
- Pagination for large playlists
- Background task for imports
- Audio stream caching

### Error Handling
- Network connectivity issues
- Invalid YouTube URLs
- API rate limiting
- Core Data errors

## Future Features

### Phase 2: Enhanced Integration
- [ ] Real YouTube Music streaming
- [ ] Spotify integration
- [ ] Apple Music integration
- [ ] Download for offline playback

### Phase 3: Game Features
- [ ] Game timer integration
- [ ] Quick play buttons for events (goal, penalty, timeout)
- [ ] Multiple playlists (warmup, intermission, post-game)
- [ ] Playlist templates

### Phase 4: Advanced Features
- [ ] Remote control via iPad/Mac
- [ ] Team branding customization
- [ ] Audio effects (fade in/out, volume control)
- [ ] Statistics and history
- [ ] Cloud sync between devices

## Development Setup

### Prerequisites
```bash
# Install Xcode from App Store
# Requires macOS 13.0 or later

# Install CocoaPods (if using pods)
sudo gem install cocoapods
```

### Running the Project
```bash
git clone https://github.com/Princa/HockeyDJ.git
cd HockeyDJ
open HockeyDJ.xcodeproj
# Select target device and press Cmd+R
```

### Project Settings
- **Bundle Identifier**: com.hockeydj.HockeyDJ
- **Deployment Target**: iOS 16.0
- **Swift Version**: 5.0
- **Supported Devices**: iPhone, iPad

## Troubleshooting

### Common Issues

**Build Errors:**
- Ensure Xcode Command Line Tools are installed
- Clean build folder (Cmd+Shift+K)
- Reset package dependencies

**Core Data Issues:**
- Delete app from simulator to reset database
- Check entity names match in code and xcdatamodel
- Verify relationship configurations

**Preview Issues:**
- Use `PersistenceController.preview` for SwiftUI previews
- Ensure preview content is properly configured

## Contributing

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- Add comments for complex logic
- Write descriptive commit messages

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit PR with description
5. Address review comments

## Resources

- [YouTube Data API Documentation](https://developers.google.com/youtube/v3)
- [Apple Music API](https://developer.apple.com/documentation/applemusicapi)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [AVFoundation Documentation](https://developer.apple.com/av-foundation/)
- [Core Data Documentation](https://developer.apple.com/documentation/coredata)
