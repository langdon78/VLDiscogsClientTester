# VL (Very Light 🪶) Discogs Client Tester

An iOS app for testing [VLDiscogsClient](https://github.com/corporatelangdon/VLDiscogsClient) — a Swift client library for the [Discogs API](https://www.discogs.com/developers). The app exercises every typed API method in the library, making it easy to verify behavior against the live Discogs service.

## What It Does

VLDiscogsClientTester provides a form-driven UI for every Discogs API endpoint exposed by VLDiscogsClient. Each request goes through the library's typed API layer (not raw HTTP), so you're testing the same code paths your app would use in production.

Supported API sections:

- **Database** — Releases, masters, artists, labels, and search
- **Marketplace** — Inventory, listings, orders, fees, price suggestions, and release statistics
- **User Identity** — Profile, submissions, and contributions
- **User Collection** — Folders, items, ratings, custom fields, and collection value
- **User Wantlist** — List, add, edit, and delete want items
- **User Lists** — Browse user lists and list details
- **Inventory Export** — Request, list, and download CSV exports
- **Inventory Import** — View recent uploads and upload status

## Getting Started

### Prerequisites

- Xcode 16+
- iOS 18+ deployment target
- A Discogs account with API credentials

### Dependencies

Managed via Swift Package Manager:

- **[VLDiscogsClient](https://github.com/corporatelangdon/VLDiscogsClient)** — Discogs API client
- **[VLOAuthFlowCoordinator](https://github.com/corporatelangdon/VLOAuthFlowCoordinator)** — OAuth 1.0a flow management
- **[VLNetworkingClient](https://github.com/corporatelangdon/VLNetworkingClient)** — Async networking layer
- **[swift-collections](https://github.com/apple/swift-collections)** — OrderedDictionary for preserving endpoint ordering

### Running

1. Open `VLDiscogsClientTester.xcodeproj` in Xcode
2. Build and run on a simulator or device
3. Add a Discogs account via the welcome screen (OAuth flow)
4. Browse API sections from the home menu and send requests

## Architecture

The app uses a data-driven approach where each API endpoint is defined as a `RequestUrlTemplate` containing:

- **Path and method** — displayed in the request list
- **Parameters** — rendered as a dynamic form (text fields, pickers, enumerations)
- **Execute closure** — calls the actual VLDiscogsClient API method

This means adding a new endpoint only requires defining it in `Requests.swift` — the views and view model are fully generic.

### Key Files

| File | Purpose |
|------|---------|
| `Requests.swift` | Defines all API endpoints with parameters and execute closures |
| `RequestUrlTemplate.swift` | Model for an API endpoint (path, method, parameters, action) |
| `RequestParameter.swift` | Model for a form field (type, location, validation) |
| `RequestTestViewModel.swift` | Handles form state, validation, and request execution |
| `RequestTestView.swift` | Form UI with parameter inputs, URL preview, and response display |
| `RequestListView.swift` | Grouped list of endpoints within an API section |
| `HomeMenu.swift` | Top-level navigation to each API section |

### Multi-Account Support

The app supports multiple Discogs accounts. Switch between them via the accounts toolbar button. Each account stores its own OAuth tokens and the active username is auto-filled into request parameters.
