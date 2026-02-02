# iOS Widget Deployment Workflow: VS Code + Claude Code → Xcode

## Why This Works

**Yes, you can absolutely do all your coding in VS Code!** Here's the key insight:

- **Xcode project** = just configuration files (.xcodeproj) that tell iOS how to build your app
- **Your Swift code** = regular .swift files that live in regular folders
- **Xcode doesn't care** where you edit the .swift files - VS Code, Vim, Notepad, whatever!

**The workflow:**
1. Use Xcode ONCE to create the project structure and configure build settings
2. Close Xcode, never touch it for coding
3. Do ALL your development in VS Code with Claude Code
4. Open Xcode ONLY when you want to build/deploy to your iPhone
5. Xcode auto-detects all the .swift files you created in VS Code

It's like using a Makefile in C++ - you edit code in your preferred editor, then run the build tool separately.

---

## Overview
Use VS Code as your primary development environment with Claude Code for writing all Swift code, then open the project in Xcode **only** when you need to build and deploy. You don't need to edit anything in Xcode directly.

## Recommended Workflow: VS Code First

### The Complete Process
This is the cleanest approach - do all your coding in VS Code, use Xcode as a build tool.

#### Step 1: Create Xcode Project Structure (One-Time Setup)
```bash
# 1. Open Xcode (just this once to create the project structure)
# 2. File → New → Project
# 3. Choose "App" template
# 4. Product Name: "SportsWidget"
# 5. Interface: SwiftUI
# 6. Language: Swift
# 7. Save to: ~/Projects/ios-sports-scores-widget
```

#### Step 2: Add Widget Extension (Still in Xcode)
```bash
# In Xcode:
# 1. File → New → Target
# 2. Choose "Widget Extension"
# 3. Product Name: "SportsWidgetExtension"
# 4. Click Finish
# 5. Activate the scheme when prompted
```

#### Step 3: Configure App Group (Required for Widgets - Still in Xcode)
```bash
# In Xcode (last thing you'll do in Xcode for now):
# 1. Select your project in the navigator
# 2. Select the main app target
# 3. Signing & Capabilities tab
# 4. Click "+ Capability"
# 5. Add "App Groups"
# 6. Click "+" and create: group.com.yourname.sportswidget
# 7. Repeat for the widget extension target
# 8. Use the SAME app group identifier
```

#### Step 4: Close Xcode, Open in VS Code
```bash
# Close Xcode, you're done with it for now!

# Open the project folder in VS Code
cd ~/Projects/ios-sports-scores-widget
code .

# Your project structure in VS Code will look like:
# ios-sports-scores-widget/
# ├── SportsWidget/              # Main app folder
# ├── SportsWidgetExtension/     # Widget folder
# └── SportsWidget.xcodeproj/    # Xcode project (don't touch)
```

#### Step 5: Use Claude Code in VS Code
```bash
# In VS Code, open the integrated terminal (Ctrl + `)
# Make sure you're in the project directory
cd ~/Projects/ios-sports-scores-widget

# Start Claude Code (it works great in VS Code!)
claude-code

# Give Claude Code the spec file:
# "Using the sports_widget_spec.md, create all the Swift files.
# Put main app files in SportsWidget/ 
# Put widget files in SportsWidgetExtension/"

# Claude Code will create all the .swift files in the right folders
```

#### Step 6: Build and Deploy (Back to Xcode Only When Ready)
```bash
# When you're ready to test on your iPhone:
# 1. Open SportsWidget.xcodeproj in Xcode (double-click it in Finder)
# 2. Xcode will detect all the new .swift files automatically
# 3. Select your device in the toolbar
# 4. Cmd + R to build and run
# 5. Close Xcode, go back to VS Code for more coding

# How Xcode auto-detection works:
# - Xcode scans the SportsWidget/ and SportsWidgetExtension/ folders
# - Any .swift files in these folders are automatically compiled
# - You DON'T need to "Add Files to Project" manually
# - The .xcodeproj just references the folders, not individual files
# - This is why VS Code → Xcode workflow is seamless!
```

**Important Note:** Xcode automatically includes .swift files from your target folders. You don't need to manually add files in Xcode's navigator. Just create files in VS Code in the right folders (SportsWidget/ or SportsWidgetExtension/) and Xcode will find them when you build.

---

## Development Iteration Workflow (The Daily Process)

This is what your day-to-day development will look like:

### Daily Coding in VS Code with Claude Code
```bash
# 1. Open your project in VS Code
cd ~/Projects/ios-sports-scores-widget
code .

# 2. Open integrated terminal (Ctrl + `)
# 3. Start Claude Code
claude-code

# 4. Request changes:
# "Update the MediumWidgetView.swift to show team logos"
# "Add error handling to ESPNAPIClient.swift"
# "Create a new SettingsView.swift in the SportsWidget folder"

# 5. Claude Code creates/modifies files directly in your VS Code workspace
# 6. You can see changes in VS Code in real-time
# 7. Use VS Code's Git integration to track changes
```

### When Ready to Test: Quick Xcode Build
```bash
# From VS Code or Finder:
# 1. Double-click SportsWidget.xcodeproj (opens in Xcode)
# 2. Select your iPhone/simulator
# 3. Cmd + R to build and run
# 4. Widget appears on your device
# 5. Close Xcode, continue coding in VS Code

# That's it! Xcode auto-detects all file changes from VS Code
```

---

## VS Code Setup for Swift Development

### Recommended VS Code Extensions
```bash
# Install these for a better Swift experience in VS Code:

1. Swift Language (by Swift Server Work Group)
   - Syntax highlighting for Swift
   - Code completion
   - Error detection

2. GitLens (by GitKraken)
   - See file history and changes
   - Great for tracking what Claude Code changes

3. Better Comments (by Aaron Bond)
   - Makes comments more readable
   - Helpful for code Claude Code generates

# Install via VS Code Extensions panel (Cmd + Shift + X)
```

### VS Code Workspace Tips
```bash
# .vscode/settings.json - Add this to your project:
{
  "files.exclude": {
    "**/.git": true,
    "**/DerivedData": true,
    "**/.DS_Store": true,
    "**/*.xcworkspace": true
  },
  "files.watcherExclude": {
    "**/DerivedData/**": true
  },
  "search.exclude": {
    "**/DerivedData": true
  }
}

# This keeps VS Code focused on your Swift source files
# and ignores Xcode's build artifacts
```

### Using Git in VS Code
```bash
# Initialize git if you haven't:
git init
git add .
git commit -m "Initial project setup"

# VS Code's Source Control panel (Cmd + Shift + G) shows:
# - All files Claude Code created/modified
# - Diffs of changes
# - Easy commit/revert options

# Before asking Claude Code to make big changes:
git commit -m "Before adding team logo feature"
# Then you can always revert if needed
```

---

## Essential Xcode Configuration

### Code Signing (Required for Device Deployment)
```bash
# For each target (app + widget extension):
# 1. Select target → Signing & Capabilities
# 2. Check "Automatically manage signing"
# 3. Select your Team (Apple Developer account)
# 4. Xcode will create provisioning profiles automatically
```

### Widget-Specific Settings
```bash
# In Info.plist for widget extension:
# These are usually auto-generated, but verify:
# - NSExtension point: com.apple.widgetkit-extension
# - Widget configuration: Defined in your widget code
```

### Testing on Physical Device
```bash
# 1. Connect iPhone via USB
# 2. Select your iPhone in Xcode (top toolbar)
# 3. Xcode → Settings → Accounts
# 4. Add your Apple ID if not already added
# 5. Trust the certificate on your iPhone:
#    Settings → General → VPN & Device Management
#    → Trust your developer certificate
# 6. Build and run (Cmd + R)
```

---

## File Organization in VS Code

### Your Project Structure (What You'll See in VS Code)
```
ios-sports-scores-widget/        # Your project root folder
├── SportsWidget/               # Main app target folder
│   ├── SportsWidgetApp.swift  # App entry point (Xcode created)
│   ├── ContentView.swift      # Claude Code creates
│   ├── TeamSelectionView.swift # Claude Code creates
│   ├── SettingsView.swift     # Claude Code creates
│   └── Assets.xcassets        # Asset catalog (Xcode created)
├── SportsWidgetExtension/      # Widget target folder
│   ├── SportsWidget.swift     # Widget entry point (Xcode created)
│   ├── TimelineProvider.swift # Claude Code creates
│   ├── Views/                 # Claude Code creates this folder
│   │   ├── SmallWidgetView.swift
│   │   └── MediumWidgetView.swift
│   ├── Models/                # Claude Code creates this folder
│   │   ├── Team.swift
│   │   ├── Game.swift
│   │   └── ScheduleEntry.swift
│   ├── Services/              # Claude Code creates this folder
│   │   ├── ESPNAPIClient.swift
│   │   └── DataCache.swift
│   └── Assets.xcassets        # Asset catalog (Xcode created)
├── SportsWidget.xcodeproj/     # Xcode project - don't edit manually
├── .git/                       # Git repository (if initialized)
└── .gitignore                  # Create this (see below)
```

### Recommended .gitignore
```bash
# Create this file in VS Code at project root:
# ~/Projects/ios-sports-scores-widget/.gitignore

# Xcode build files (don't commit these)
DerivedData/
build/
*.xcworkspace/
xcuserdata/

# macOS
.DS_Store

# Swift Package Manager (if you use it later)
.swiftpm/
*.xcodeproj/project.xcworkspace/
*.xcodeproj/xcuserdata/

# Your API keys if you add any
*.plist
!Info.plist

# Commit this .gitignore to keep your repo clean
```

### How Claude Code Creates Files in VS Code
```bash
# When you ask Claude Code to create a file, it will:
# 1. Create the file in the correct folder
# 2. Show up immediately in VS Code's Explorer
# 3. Automatically be detected by Xcode when you build

# Example conversation with Claude Code:
You: "Create ESPNAPIClient.swift in the Services folder"
Claude Code: [Creates SportsWidgetExtension/Services/ESPNAPIClient.swift]

# The file appears in VS Code Explorer instantly
# Next time you open Xcode, it's automatically included
```

---

## Common Issues & Solutions

### Issue: "File not found" when building
```bash
# Solution: Check target membership
# 1. Select the file in Xcode navigator
# 2. Open File Inspector (right sidebar)
# 3. Ensure correct target is checked under "Target Membership"
```

### Issue: Widget not appearing in gallery
```bash
# Solution 1: Clean build folder
# Xcode → Product → Clean Build Folder (Shift + Cmd + K)
# Then rebuild

# Solution 2: Restart simulator/device
# Sometimes widgets cache aggressively
```

### Issue: App Group not sharing data
```bash
# Solution: Verify App Group setup
# 1. Both targets must have SAME App Group ID
# 2. Format: group.com.yourcompany.appname
# 3. Both targets must have App Groups capability enabled
```

### Issue: Code signing errors
```bash
# Solution: Reset automatic signing
# 1. Uncheck "Automatically manage signing"
# 2. Check it again
# 3. Xcode will regenerate profiles
```

---

## Deployment Checklist

### Before First Build
- [ ] Xcode project created with app + widget targets
- [ ] App Groups capability added to both targets
- [ ] Same App Group ID used for both targets
- [ ] Team selected for code signing
- [ ] Device trusted (if deploying to physical iPhone)

### Before Each Claude Code Session
- [ ] Navigate to Xcode project directory in terminal
- [ ] Know which files you want Claude Code to create/modify
- [ ] Have the spec file available for reference

### After Claude Code Generates/Modifies Files
- [ ] Files added to Xcode (if new files)
- [ ] Target membership verified for each file
- [ ] Build in Xcode (Cmd + B) to check for errors
- [ ] Run on simulator/device to test (Cmd + R)

### For App Store Submission (Future)
- [ ] Paid Apple Developer account ($99/year)
- [ ] App Store Connect account set up
- [ ] App icons created (multiple sizes)
- [ ] Privacy policy URL (if collecting data)
- [ ] Screenshots for App Store listing

---

## Pro Tips

### Use Xcode's Live Preview
```swift
// Add to bottom of your SwiftUI views:
#Preview {
    SmallWidgetView(entry: ScheduleEntry(
        date: Date(),
        games: [/* sample data */],
        lastUpdated: Date()
    ))
}

// Xcode will show live preview while you code
```

### Version Control
```bash
# Initialize git in your project directory
cd ~/Projects/ios-sports-scores-widget
git init
git add .
git commit -m "Initial commit"

# This helps track changes Claude Code makes
# You can always revert if needed
```

### Simulator Shortcuts
```bash
# Xcode → Open Developer Tool → Simulator
# Cmd + Shift + H: Home button
# Cmd + K: Toggle keyboard
# Long press home screen to add widgets
```

### Debug Widget Updates
```swift
// Add to your TimelineProvider for debugging
print("Widget refreshed at: \(Date())")
print("Next refresh scheduled for: \(timeline.policy)")

// View logs: Xcode → View → Debug Area → Show Console
```

---

## Quick Reference Commands

### In VS Code Terminal
```bash
# Navigate to project and open VS Code
cd ~/Projects/ios-sports-scores-widget
code .

# Start Claude Code (in VS Code integrated terminal)
claude-code

# Common Claude Code requests:
"Create ESPNAPIClient.swift in SportsWidgetExtension/Services/ for fetching NBA games"
"Update TimelineProvider.swift to refresh at 6 AM daily"
"Add error handling to the API client"
"Create SmallWidgetView.swift with a preview using sample data"
"Fix the syntax error in MediumWidgetView.swift"

# Git commands (in VS Code terminal)
git status                    # See what Claude Code changed
git diff                      # View detailed changes
git add .                     # Stage all changes
git commit -m "Added team logos"  # Commit changes
```

### In Xcode (When Testing)
```bash
# Open project from Finder or terminal
open SportsWidget.xcodeproj

# Or double-click SportsWidget.xcodeproj in VS Code Explorer

# Keyboard shortcuts in Xcode:
Cmd + B        # Build project
Cmd + R        # Build and run on selected device
Shift + Cmd + K # Clean build folder
Cmd + Q        # Quit Xcode (go back to VS Code!)
```

### VS Code Shortcuts
```bash
Ctrl + `       # Toggle integrated terminal
Cmd + P        # Quick open file
Cmd + Shift + F # Search across all files
Cmd + Shift + G # Source control panel
Cmd + B        # Toggle sidebar
Cmd + K, Z     # Enter Zen mode (distraction-free)
```

---

## Workflow Summary

**The Complete VS Code + Xcode Workflow:**

1. **One-Time Setup (Xcode):**
   - Create Xcode project with app + widget extension
   - Configure App Groups capability
   - Set up code signing
   - Close Xcode

2. **Daily Development (VS Code):**
   - Open project folder in VS Code
   - Use Claude Code to write/edit Swift files
   - Review changes in VS Code
   - Commit with Git when ready

3. **Testing (Xcode):**
   - Open .xcodeproj file
   - Build and run on device (Cmd + R)
   - Close Xcode
   - Return to VS Code for more coding

4. **Iterate:**
   - VS Code for code → Xcode for testing → repeat

**Key Benefits:**
- ✅ Work in your familiar VS Code environment
- ✅ Claude Code CLI works natively in VS Code
- ✅ Full Git integration and diff viewing
- ✅ Xcode only for building/deploying (no manual editing)
- ✅ Files automatically detected by Xcode
