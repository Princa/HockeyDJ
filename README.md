# HockeyDJ

An iOS application for Hockey Game DJs to manage and play music during hockey games.

## Features

- 🎵 **Song Management**: Create and manage playlists of songs
- ⏱️ **Custom Start Times**: Configure where each song should start playing
- 🎬 **YouTube Music Integration**: Import songs directly from YouTube Music playlists
- ▶️ **Playback Controls**: Play, pause, and skip through songs
- 📱 **iPhone Optimized**: Designed primarily for iPhone use during hockey games

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Project Structure

```
HockeyDJ/
├── HockeyDJ/
│   ├── HockeyDJApp.swift          # Main app entry point
│   ├── ContentView.swift          # Root view
│   ├── Models/                    # Data models
│   │   ├── Song.swift            # Song data structure
│   │   └── Playlist.swift        # Playlist data structure
│   ├── Views/                     # SwiftUI views
│   │   ├── PlaylistView.swift    # Main playlist display
│   │   ├── SongDetailView.swift  # Song editing interface
│   │   └── YouTubeMusicImportView.swift  # Import interface
│   ├── Services/                  # Business logic
│   │   ├── AudioPlayerManager.swift      # Audio playback handler
│   │   └── YouTubeMusicService.swift     # YouTube Music API integration
│   ├── Persistence.swift          # Core Data stack
│   └── HockeyDJ.xcdatamodeld/    # Core Data model
└── HockeyDJ.xcodeproj/            # Xcode project file
```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Princa/HockeyDJ.git
   cd HockeyDJ
   ```

2. Open the project in Xcode:
   ```bash
   open HockeyDJ.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the project (⌘R)

## Usage

### Importing Songs from YouTube Music

1. Tap the "+" button in the top right corner
2. Enter a YouTube Music playlist URL or individual video URL
3. Tap "Import" to add the songs to your playlist

**Supported URL formats:**
- Playlist: `https://music.youtube.com/playlist?list=PLxxxxxx`
- Video: `https://www.youtube.com/watch?v=xxxxxx`
- Short: `https://youtu.be/xxxxxx`

### Customizing Songs

1. Tap on any song in the playlist
2. Adjust the start time using the minute and second pickers
3. Optionally set an end time for the song
4. Tap "Save" to apply changes

### Playing Songs

- Tap the play button next to any song to start playback
- Use the player controls at the bottom to:
  - Play/Pause the current song
  - Skip forward/backward 10 seconds
  - View current song information

### Managing Playlist

- **Reorder**: Long press and drag songs to rearrange
- **Delete**: Swipe left on any song to delete

## YouTube Music API Integration

> **Note**: The current implementation uses sample data for demonstration purposes.

To enable real YouTube Music integration:

1. **Get YouTube Data API Key**:
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable YouTube Data API v3
   - Create credentials (API key)

2. **Configure the API Key**:
   - Store the API key securely (use Keychain)
   - Update `YouTubeMusicService.swift` with actual API calls

3. **Implement OAuth** (for user library access):
   - Set up Google Sign-In
   - Request appropriate YouTube scopes
   - Handle authentication flow

## Technical Details

### Data Model

The app uses Core Data for local storage with two main entities:

- **SongEntity**: Stores song information including title, artist, YouTube ID, start/end times
- **PlaylistEntity**: Groups songs together (prepared for future multi-playlist support)

### Audio Playback

The `AudioPlayerManager` handles audio playback with:
- AVFoundation for audio playback
- Custom start time seeking
- Automatic stop at end time (if configured)

### Future Enhancements

- [ ] Real YouTube Music API integration
- [ ] Spotify integration
- [ ] Apple Music integration
- [ ] Multiple playlist support
- [ ] Offline playback
- [ ] Background playback
- [ ] Remote control support
- [ ] Game timer integration
- [ ] Quick play buttons for common game events

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is provided as-is for personal and educational use.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
