# Atonement Alert

**Version:** 1.0.0  
**Author:** Zendrakk  
**Compatible With:** World of Warcraft Retail (Patch 12.1+)

---

## Overview

**Atonement Alert** is a World of Warcraft addon designed specifically for **Discipline Priests**. It provides a compact, movable tracker that displays the remaining duration of your personal **Atonement** buff, helping you maintain optimal healing coverage during combat.

The addon displays a visual countdown timer that changes color and flashes as the buff duration decreases, making it easy to see at a glance when your Atonement is about to expire. Optional sound alerts notify you when Atonement expires.

---

## Features

### Visual Tracking
- **Real-time Duration Display**: Shows the exact remaining time on your Atonement buff with a large, easy-to-read countdown timer
- **Dynamic Color Coding**:
  - **White** (10+ seconds): Normal duration
  - **Yellow** (5-10 seconds): Warning - buff is getting low
  - **Red Flash** (3 seconds or less): Critical - buff is about to expire
- **Animated Flashing**: Between 0-3 seconds remaining, the timer flashes red and white alternating to grab your attention

### Audio Alerts
- **Expiration Sound**: Optional audio alert that plays when Atonement expires
- **Customizable**: Enable/disable the sound alert as needed
- **Test Function**: Play the warning sound on demand to verify your audio settings

### Interface Customization
- **Movable Window**: Drag the tracker to position it anywhere on your screen
- **Lock/Unlock States**: Toggle between locked (prevents accidental movement) and unlocked (allows dragging)
- **Position Memory**: Your chosen position is automatically saved between sessions
- **Default Position**: Center screen with adjustable Y-offset (-220 pixels from center)

### Settings Management
- **Persistent Configuration**: All settings are saved to your WoW character-specific data
- **Quick Reset**: Restore the tracker to its default center position if needed

---

## Installation

1. Download the addon folder to your World of Warcraft AddOns directory:
   ```
   ...\World of Warcraft\_retail_\Interface\AddOns\AtonementAlert\
   ```
   (On macOS: `/Applications/World of Warcraft/_retail_/Interface/AddOns/AtonementAlert/`)

2. Restart World of Warcraft or use `/reload` in-game

3. The addon will load automatically on your Discipline Priest

---

## Usage

### Basic Commands

All commands use the slash command `/aat` or `/atonementalert`:

#### Movement Commands
- **`/aat unlock`** or **`/aat move`**
  - Enables dragging mode
  - Allows you to move the tracker by clicking and dragging it
  - Message: "Atonement Alert: unlocked. Drag the Atonement tracker to move it."

- **`/aat lock`**
  - Locks the tracker in place
  - Prevents accidental movement during gameplay
  - Saves the current position
  - Message: "Atonement Alert: locked."

- **`/aat reset`**
  - Restores the tracker to the default center screen position
  - Useful if the tracker gets stuck off-screen
  - Message: "Atonement Alert: position reset."

#### Status & Information
- **`/aat status`**
  - Displays current addon status including:
    - Lock state
    - Saved position coordinates
    - Tracked spell ID
    - Whether duration formatter is available
    - Whether color curve is available
    - Sound settings status

#### Sound Commands
All sound commands use the prefix `/aat sound`:

- **`/aat sound on`**
  - Enables the Atonement expiration alert sound
  - The sound will play when your Atonement buff expires
  - Message: "Atonement Alert: expiration sound ON."

- **`/aat sound off`**
  - Disables the Atonement expiration alert sound
  - Message: "Atonement Alert: expiration sound OFF."

- **`/aat sound test`**
  - Plays the warning sound immediately
  - Useful for testing if your audio is working correctly
  - Message: "Atonement Alert: test sound played."

- **`/aat sound status`**
  - Shows detailed sound configuration:
    - Enabled state
    - Registration status
    - Sound file path
    - Audio channel (SFX)

- **`/aat sound`** or **`/aat sound help`**
  - Displays all available sound commands

#### General Help
- **`/aat`** or **`/aat help`** (any unrecognized command)
  - Displays all available commands

---

## Visual Indicators

### Timer Colors & States

| Time Remaining | Appearance | Meaning |
|---|---|---|
| 10+ seconds | White text | Normal - Atonement is stable |
| 5-10 seconds | Yellow text | Warning - Buff is getting low |
| 3-5 seconds | Yellow text (static) | Alert - Prepare for reapplication |
| 0-3 seconds | Red & white flashing | Critical - Buff expiring very soon |
| Expired | No display | Atonement has ended |

### Size & Layout
- **Button Size**: 72x72 pixels
- **Icon**: Shows the Atonement spell icon (with adjusted texture coordinates for clarity)
- **Text Overlay**: Large 36pt countdown timer centered on the button with shadow for readability

---

## Configuration

### Saved Settings

Atonement Alert stores the following information in your SavedVariables:
- **Position Data**: Current X, Y coordinates and anchor points
- **Lock State**: Whether the tracker is locked or unlocked
- **Sound Settings**: Whether sound alerts are enabled

### Database File
- **Variable Name**: `AtonementAlertDB`
- **Location**: Your WoW character-specific SavedVariables folder
- **Loaded First**: The addon uses `LoadSavedVariablesFirst` to ensure settings are available immediately

### Default Positions
- **Anchor Point**: CENTER (center of screen)
- **Relative Point**: CENTER (relative to center of screen)
- **X Offset**: 0
- **Y Offset**: -220 (positioned above center)

---

## Technical Details

### Requirements
- World of Warcraft Retail (Patch 12.1 or later)
- Available on Discipline Priests (Atonement spell)

### Tracked Spell
- **Spell ID**: 194384 (Atonement)
- **Category**: Helpful buff (HELPFUL)
- **Limit**: Displays only your personal Atonement buff

### Compatibility Features
- **Modern API**: Uses WoW's AuraContainer system (CustomAuraContainerTemplate)
- **Backwards Compatibility**: Includes fallback code for older WoW versions
- **Error Handling**: Safe error handling with pcall() for API calls that may not exist in all versions

### Audio System
- **Sound Format**: OGG Vorbis (.ogg)
- **Sound File**: `AtonementWarning.ogg`
- **Audio Channel**: SFX (Sound Effects)
- **Trigger**: Automatically plays when Atonement expires

### Display Features
- **Duration Formatter**: Uses WoW's built-in SecondsFormatter for optimal time display
- **Color Curve**: Advanced color interpolation system that smoothly transitions colors based on remaining duration
- **Anti-alias**: Text rendered with outline for maximum visibility in all UI themes

---

## Troubleshooting

### Addon Not Appearing
1. Verify the addon is enabled in your AddOns list at login
2. Type `/aat status` to check if it loaded successfully
3. Try `/reload` to reload all addons
4. Check that you're on a Discipline Priest character (Atonement is priest-only)

### Tracker Off-Screen
1. Use `/aat reset` to restore the default center position
2. If that doesn't work, use `/aat unlock` and try to drag it back
3. You can also manually edit the SavedVariables file in your WoW folder

### Sound Not Playing
1. Ensure sound is enabled with `/aat sound on`
2. Test the sound with `/aat sound test`
3. Check your Windows/Mac volume and in-game SFX volume
4. Verify the sound file exists: `AtonementAlert/Sounds/AtonementWarning.ogg`
5. Check your computer's default audio device

### Timer Not Updating
1. Verify Atonement is actually active on your character
2. Type `/aat status` and check that the duration formatter is available
3. Try `/reload` to reload the addon
4. Some older WoW versions may have limited compatibility - ensure you're on Patch 12.1+

---

## Performance & Optimization

- **Lightweight**: Minimal CPU and memory impact
- **Efficient Updates**: Only updates when Atonement duration changes
- **No Polling**: Uses native WoW event system for real-time accuracy
- **Optimized Rendering**: Custom initialization prevents performance overhead

---

## Settings Examples

### Combat-Friendly Setup
```
/aat lock
/aat sound on
```
Locks the tracker in place and enables audio alerts for when Atonement expires.

### Testing Configuration
```
/aat unlock
/aat sound on
/aat sound test
```
Unlock for positioning, enable sound, and test the audio alert.

### Quick Reset
```
/aat reset
/aat lock
```
Reset to default position and lock it back down.

---

## Support & Issues

### Bug Reports
If you encounter issues with the addon:
1. Check the chat window for any error messages
2. Type `/aat status` to verify the addon's state
3. Try `/reload` and test again
4. Ensure you're running the latest version of WoW and the addon

### Known Limitations
- Only tracks the player's personal Atonement buff (not party/raid members)
- Requires WoW Retail version (does not support Classic)
- Discipline Priest only (spell is class-restricted)

---

## Version History

### Version 1.0.0 (First Release)
- Initial release for WoW Patch 12.1+
- Full compatibility with modern AuraContainer system
- Dynamic color curves and visual indicators
- Atonement expiration sound alerts
- Customizable position tracking and lock system

---

## Credits

**Created by:** Zendrakk  
**Icon:** World of Warcraft spell icon  
**Sound Effect:** Atonement warning alert

---

## License

This addon is released under the **MIT License**. See the [LICENSE](LICENSE) file for full details.

You are free to:
- Use, modify, and distribute the addon
- Create derivative works
- Use for commercial purposes

Provided that you include the original copyright notice and license.

---

## Tips for Discipline Priests

- **Atonement is Essential**: Keep this tracker visible at all times to maintain optimal healing coverage
- **Proactive Reapplication**: Use the yellow warning phase (5-10 seconds) to prepare your next Atonement cast
- **Sound Alerts**: Enable sound alerts if you frequently tunnel on damage during raids
- **Strategic Positioning**: Place the tracker in an unobtrusive location where you can still see it clearly
- **Check Status**: Use `/aat status` after major patches to ensure the addon is functioning correctly

Happy healing, and may your Atonements never expire!
