# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS SwiftUI application for testing OAuth flow using the Discogs API. The app serves as a testing harness for OAuth 1.0a authentication flow with custom OAuth libraries.

## Key Dependencies

The project uses Swift Package Manager with these main dependencies:
- **VLOAuthFlowCoordinator** (VLOAuthProvider): Custom OAuth provider library for handling OAuth 1.0a flows
- **VLNetworkingClient**: Custom networking client for API requests
- **swift-collections**: Apple's collections library

## Architecture

### Core Components

- **oauth_testerApp.swift**: Main app entry point using SwiftUI App lifecycle
- **ContentView.swift**: Primary view containing OAuth test functionality and UI
- **Info.plist**: Contains URL scheme configuration for OAuth callback handling

### OAuth Configuration

The app is configured for Discogs API OAuth with:
- URL scheme: `com.corporatelangdon.oauth-tester`
- Callback URL configured for OAuth redirect handling
- Test credentials embedded for Discogs API access

### Key Implementation Details

- Uses `AuthRequester` from VLOAuthFlowCoordinator for OAuth flow management
- Implements async/await networking with the custom VLNetworkingClient
- Tests OAuth identity endpoint (`https://api.discogs.com/oauth/identity`)
- Includes authorization web view integration in SwiftUI

## Development Commands

### Building
```bash
# Build the project (use Xcode or xcodebuild)
xcodebuild -project oauth-tester.xcodeproj -scheme oauth-tester build
```

### Running
- Open `oauth-tester.xcodeproj` in Xcode
- Select target device/simulator
- Run with Cmd+R

## Project Structure

```
oauth-tester/
├── oauth-tester.xcodeproj/          # Xcode project file
├── oauth-tester/                    # Source code directory
│   ├── oauth_testerApp.swift        # App entry point
│   ├── ContentView.swift            # Main view with OAuth test UI
│   ├── Info.plist                   # Bundle configuration with URL schemes
│   └── Assets.xcassets/             # App assets and icons
```

## Important Notes

- The project contains test OAuth credentials for Discogs API that should not be used in production
- URL scheme configuration in Info.plist is critical for OAuth callback handling
- Dependencies are managed through Swift Package Manager (Package.resolved)
- Uses modern SwiftUI with iOS deployment target requirements