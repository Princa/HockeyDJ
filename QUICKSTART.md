# HockeyDJ - Quick Start Guide

## Getting Started in 5 Minutes

### 1. Open the Project
```bash
git clone https://github.com/Princa/HockeyDJ.git
cd HockeyDJ
open HockeyDJ.xcodeproj
```

### 2. Build and Run
- Select your target device (iPhone simulator or physical device)
- Press `⌘R` to build and run
- The app will launch with an empty playlist

### 3. Import Your First Song

#### Option A: Import from YouTube Music Playlist
1. Open YouTube Music in your browser
2. Navigate to a playlist
3. Copy the URL (e.g., `https://music.youtube.com/playlist?list=PLxxxxx`)
4. In HockeyDJ, tap the **+** button
5. Paste the URL and tap **Import**

#### Option B: Import a Single YouTube Video
1. Find a video on YouTube
2. Copy the URL (e.g., `https://www.youtube.com/watch?v=xxxxx`)
3. In HockeyDJ, tap the **+** button
4. Paste the URL and tap **Import**

### 4. Customize Song Times
1. Tap on any song in your playlist
2. Use the pickers to set the **Start Time**
3. Toggle **Set End Time** if you want the song to stop at a specific time
4. Tap **Save**

### 5. Play Your Songs
- Tap the play button (▶️) next to any song
- Use the player controls at the bottom:
  - **⏸** Pause/Play
  - **⏪** Skip backward 10 seconds
  - **⏩** Skip forward 10 seconds

### 6. Manage Your Playlist
- **Reorder**: Press and hold a song, then drag to rearrange
- **Delete**: Swipe left on a song and tap delete

## Common Use Cases

### Hockey Game Warmup
```
1. Import high-energy songs
2. Set start times to skip intros
3. Set end times to avoid awkward endings
4. Reorder for perfect flow
```

### Goal Celebration
```
1. Import celebration songs
2. Set start time to the chorus/best part
3. Set end time for quick 15-30 second clips
4. Keep them at the top of your playlist for quick access
```

### Intermission Music
```
1. Import longer, varied songs
2. Don't set end times (let them play fully)
3. Organize by energy level
```

## Keyboard Shortcuts (Future)

The following shortcuts are planned for future versions:

- `Space` - Play/Pause
- `→` - Skip forward
- `←` - Skip backward
- `⌘N` - New playlist
- `⌘I` - Import songs

## Tips & Tricks

### Best Practices for Game Day
1. **Test Before Game**: Always test your playlist before the game starts
2. **Know Your Songs**: Familiarize yourself with start/end times
3. **Keep Backup**: Have a backup playlist ready
4. **Volume Check**: Test audio levels beforehand

### Optimizing Performance
1. **Limit Playlists**: Keep playlists under 100 songs for best performance
2. **Pre-load**: Import songs before game day, not during
3. **Clear Cache**: Restart app if playback becomes sluggish

### Song Time Configuration
- **Start Time**: Set this to skip intros and get straight to the action
- **End Time**: Use this to create perfect 15-30 second clips for goals
- **No End Time**: Leave blank for full songs during warmup/intermission

## Troubleshooting

### Problem: Import Doesn't Work
**Solution**: 
- Verify the URL is correct
- Check your internet connection
- Ensure URL is from YouTube/YouTube Music
- Note: Current version uses sample data (see README for API setup)

### Problem: Songs Won't Play
**Solution**:
- Check device volume
- Restart the app
- Verify audio isn't playing from another app
- Note: Current version simulates playback (see README for streaming setup)

### Problem: App Crashes
**Solution**:
- Update to latest iOS version
- Clear app data (delete and reinstall)
- Check Xcode console for errors
- Report issue on GitHub

### Problem: Songs Disappear
**Solution**:
- Check Core Data isn't corrupted
- Avoid force-closing app during saves
- Back up by exporting playlist (future feature)

## Next Steps

### For Users
- Read the full [README](README.md) for detailed features
- Check [CHANGELOG](CHANGELOG.md) for latest updates
- Submit feature requests on GitHub Issues

### For Developers
- Read [IMPLEMENTATION.md](IMPLEMENTATION.md) for technical details
- Configure YouTube API key in `Config.swift`
- Contribute via Pull Requests

## Support

- **GitHub Issues**: Report bugs and request features
- **Email**: support@hockeydj.app (future)
- **Documentation**: All docs are in the repository

## Quick Reference Commands

### Git Commands
```bash
# Update to latest version
git pull origin main

# Check current version
git log -1 --oneline
```

### Xcode Commands
```bash
# Clean build folder
⌘ + Shift + K

# Run on simulator
⌘ + R

# Stop running
⌘ + .

# Show debug console
⌘ + Shift + Y
```

## Version Info

- **Current Version**: 1.0.0
- **Last Updated**: 2026-02-16
- **Platform**: iOS 16.0+
- **License**: MIT

---

**Enjoy using HockeyDJ! 🏒🎵**
