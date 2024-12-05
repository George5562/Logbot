# Logbot

A distributed data collection system for robot training, supporting synchronized capture of video, LiDAR, and motion data across multiple iOS devices.

## System Components

### LogbotCore

Shared framework containing common functionality:

- Data models
- Network protocols
- Utility functions
- Synchronization logic

### LogbotCapture (iOS)

iOS application for data capture:

- Video recording
- LiDAR depth capture
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
2. Open Package.swift in Xcode
3. Build the desired target:
   - LogbotCapture for iOS devices
   - LogbotControl for macOS

## Development

The project uses Swift Package Manager for dependency management. Main dependencies:

- NextLevel: Advanced video capture
- swift-log: Logging infrastructure

## Architecture

The system uses:

- MultipeerConnectivity for device discovery and communication
- ARKit for LiDAR depth capture
- NextLevel for video recording
- NTP for time synchronization

## License

[Your chosen license]
