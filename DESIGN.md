# HockeyDJ App Screens and Features

## App Icon Design Concept

The app icon should feature:
- 🏒 Hockey stick or puck element
- 🎵 Music note or waveform
- Colors: Ice blue (#4A90E2) and white, with accent of red (#E74C3C)
- Modern, flat design style
- Clear and recognizable at small sizes

## Main Screens

### 1. Playlist View (Main Screen)

**Empty State:**
```
┌────────────────────────────────┐
│  HockeyDJ                    + │
├────────────────────────────────┤
│                                │
│         🎵                     │
│                                │
│      No Songs Yet              │
│                                │
│  Import songs from YouTube     │
│  Music to get started          │
│                                │
│                                │
└────────────────────────────────┘
```

**With Songs:**
```
┌────────────────────────────────┐
│  HockeyDJ                    + │
├────────────────────────────────┤
│  ┌──────────────────────────┐ │
│  │ ▶️  Rock You              │ │
│  │     Queen                 │ │
│  │     Start: 0:15  End: 1:45│ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ ▶️  Eye of the Tiger      │ │
│  │     Survivor              │ │
│  │     Start: 0:30           │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ ▶️  Seven Nation Army     │ │
│  │     The White Stripes     │ │
│  │     Start: 0:00           │ │
│  └──────────────────────────┘ │
├────────────────────────────────┤
│  🎵 Rock You - Queen          │
│  ⏮  ⏸  ⏭                     │
└────────────────────────────────┘
```

**Features:**
- Song list with play buttons
- Swipe left to delete
- Long press and drag to reorder
- Player controls at bottom when playing
- Empty state with helpful instructions

### 2. Import View

```
┌────────────────────────────────┐
│  ✕  Import Songs               │
├────────────────────────────────┤
│                                │
│         🎵                     │
│                                │
│  Import from YouTube Music     │
│                                │
│  Enter a YouTube Music         │
│  playlist URL or video URL     │
│  to import songs               │
│                                │
│  ┌──────────────────────────┐ │
│  │ Playlist or Video URL    │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │        Import            │ │
│  └──────────────────────────┘ │
│                                │
│  ╔════════════════════════╗   │
│  ║ How to Import:         ║   │
│  ║ 1. Copy YouTube URL    ║   │
│  ║ 2. Paste it above      ║   │
│  ║ 3. Tap Import          ║   │
│  ╚════════════════════════╝   │
│                                │
└────────────────────────────────┘
```

**Features:**
- Clear instructions
- URL input field
- Import button (disabled when empty)
- Loading state during import
- Error alerts for invalid URLs

### 3. Song Detail View

```
┌────────────────────────────────┐
│  Cancel  Edit Song       Save  │
├────────────────────────────────┤
│  Song Information              │
│  ┌──────────────────────────┐ │
│  │ Rock You                 │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ Queen                    │ │
│  └──────────────────────────┘ │
│                                │
│  Start Time                    │
│  ┌──────────┬──────────────┐  │
│  │   0m  ▲  │   15s  ▲     │  │
│  │       ▼  │        ▼     │  │
│  └──────────┴──────────────┘  │
│                                │
│  End Time (Optional)           │
│  ┌──────────────────────────┐ │
│  │ ☐ Set End Time           │ │
│  └──────────────────────────┘ │
│                                │
│  Duration                      │
│  3:45                          │
│                                │
│  YouTube Video ID              │
│  dQw4w9WgXcQ                   │
│                                │
└────────────────────────────────┘
```

**Features:**
- Editable title and artist
- Wheel pickers for time selection
- Toggle for optional end time
- Display video duration
- Show YouTube video ID

### 4. Player Controls (Bottom Sheet)

```
┌────────────────────────────────┐
│  Rock You                      │
│  Queen                         │
│                                │
│    ⏮      ⏸      ⏭           │
└────────────────────────────────┘
```

**Features:**
- Current song title and artist
- Skip backward (10s)
- Play/Pause toggle
- Skip forward (10s)
- Visible when song is playing

## Color Scheme

### Primary Colors
- **Primary Blue**: #4A90E2 (Ice blue)
- **Accent Red**: #E74C3C (Hockey red)
- **White**: #FFFFFF
- **Dark**: #2C3E50

### System Colors (iOS)
- Background: System Background
- Secondary Background: System Grouped Background
- Labels: System Label Colors
- Tints: Blue (default iOS blue)

## Typography

- **Large Title**: System Bold, 34pt (Navigation titles)
- **Title**: System Semibold, 28pt (Screen titles)
- **Headline**: System Semibold, 17pt (Song titles)
- **Body**: System Regular, 17pt (Artist names)
- **Subheadline**: System Regular, 15pt (Time stamps)
- **Caption**: System Regular, 12pt (Video IDs)

## Animations

1. **Song Row Tap**: Scale down slightly on press
2. **Play Button**: Smooth transition between play/pause icons
3. **Import**: Loading spinner during import
4. **Delete**: Swipe animation with red background
5. **Reorder**: Lift and shadow effect during drag
6. **Sheet Present**: Slide up from bottom

## Accessibility

- **VoiceOver**: All buttons and controls labeled
- **Dynamic Type**: All text supports dynamic sizing
- **Contrast**: Meets WCAG AA standards
- **Reduce Motion**: Respects system preference
- **Color Blind**: Icons don't rely solely on color

## User Flows

### Flow 1: First Time User
1. Launch app → Empty state
2. Tap + button → Import screen
3. Paste URL → Tap Import
4. Songs appear → Success message
5. Tap song → Edit details
6. Save → Return to playlist
7. Tap play → Music starts

### Flow 2: Game Day Setup
1. Launch app → Playlist visible
2. Review songs → Check times
3. Reorder as needed → Drag and drop
4. Test play → Verify audio
5. Ready for game!

### Flow 3: Adding More Songs
1. From playlist → Tap +
2. Import screen → Paste URL
3. New songs added to bottom
4. Reorder if needed
5. Done!

## Future UI Enhancements

### Version 1.1
- [ ] Search bar in playlist
- [ ] Filter by recently played
- [ ] Waveform visualization
- [ ] Volume slider

### Version 1.2
- [ ] Multiple playlists
- [ ] Playlist switcher
- [ ] Quick play buttons
- [ ] Timer display

### Version 2.0
- [ ] Dark mode optimization
- [ ] iPad split view
- [ ] Widgets
- [ ] Apple Watch controls

## Icon Assets Needed

- App Icon (1024x1024)
- Tab bar icons (various sizes)
- Navigation icons:
  - Plus (add)
  - Play/Pause
  - Skip forward/backward
  - Delete
  - Edit
  - Music note
  - Hockey puck

## Sample Content for Screenshots

### App Store Screenshots Should Show:
1. Playlist with popular hockey songs
2. Song editing with clear time selection
3. Import screen with instructions
4. Playing with player controls
5. Empty state with clear call-to-action

### Suggested Sample Songs:
- "Rock You" by Queen
- "Eye of the Tiger" by Survivor
- "Seven Nation Army" by The White Stripes
- "We Will Rock You" by Queen
- "Thunderstruck" by AC/DC
