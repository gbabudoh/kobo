# KOBBO - Market Vendor App

A simple, practical mobile app for Nigerian market vendors to track inventory, record sales, and manage their business easily.

## Features

### 🏠 Home Dashboard
- Daily sales total at a glance
- Quick stats (total items, low stock alerts)
- Quick Sell buttons for fast transactions
- Recent sales history

### 📦 Inventory Management
- Add new items with name, price, quantity
- Categorize as Produce (fresh) or Groceries (dry)
- Visual low stock warnings (red when ≤5 items)
- Easy sell button on each item

### 📊 Sales Tracking
- All today's sales with timestamps
- Total earnings summary
- Transaction count

### 💰 Simple Sales Recording
- Tap any item to sell
- Adjust quantity with +/- buttons
- See total before confirming
- Automatically updates inventory

## Design Features

- Prices in Naira (₦) format
- Common market items as examples (garri, palm oil, tomatoes)
- Large touch targets for quick use
- Simple categories vendors understand
- Green color scheme (prosperity & growth)
- Warm, vibrant African-inspired colors

## Getting Started

### Prerequisites
- Flutter SDK (3.10.3 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd kobo
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── item.dart            # Item model
│   └── sale.dart            # Sale model
├── screens/
│   ├── home_screen.dart     # Main screen with bottom navigation
│   ├── home_tab.dart        # Home dashboard
│   ├── items_tab.dart       # Inventory management
│   └── sales_tab.dart       # Sales history
├── widgets/
│   ├── add_item_modal.dart  # Modal for adding new items
│   └── sell_modal.dart      # Modal for recording sales
└── utils/
    └── formatters.dart      # Utility functions for formatting
```

## Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design** - UI components
- **intl** - Internationalization and formatting

## Future Enhancements

- Customer tracking
- Daily/weekly/monthly reports
- WhatsApp sharing of sales reports
- Data persistence (local database)
- Backup and restore
- Multiple vendor support
- Receipt printing

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
