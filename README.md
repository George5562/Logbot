# Logbot

A distributed data collection system for robot training, supporting synchronized capture of video, LiDAR, and motion data across multiple iOS devices.

## Current Status

The project is in active development. Current progress:

- ✅ Basic project structure and dependencies
- ✅ Core networking infrastructure using MultipeerConnectivity
- 🚧 Device communication and session management
- 📋 Planned: Data capture and synchronization

## System Components

### LogbotCore

Shared framework containing common functionality:

- Network communication (MultipeerConnectivity)
- Data models and protocols
- Session management
- Synchronization logic

### LogbotCapture (iOS)

iOS application for data capture:

- Video recording (using NextLevel)
- LiDAR depth capture (using ARKit)
- Motion data collection
- Real-time data streaming

### LogbotControl (macOS)

macOS application for system control:

- Session management
- Device coordination
- Data collection monitoring
- File organization

## Requirements

- iOS 16.0+ for capture devices
- macOS 13.0+ for control station
- Xcode 14.0+
- Swift 5.7+

## Setup

1. Clone the repository

```bash
git clone git@github.com:George5562/Logbot.git
```

2. Open Package.swift in Xcode
3. Build the desired target:
   - LogbotCapture for iOS devices
   - LogbotControl for macOS

## Development

The project uses Swift Package Manager for dependency management. Main dependencies:

- NextLevel: Advanced video capture
- swift-log: Logging infrastructure

### Current Focus

- Implementing session management
- Building basic UI for testing
- Setting up device communication

## Architecture

The system uses:

- MultipeerConnectivity for device discovery and communication
- ARKit for LiDAR depth capture
- NextLevel for video recording
- NTP for time synchronization

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

[Your chosen license]
