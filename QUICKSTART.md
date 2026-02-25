# KOBBO Quick Start Guide

## Available Devices

You have the following devices/emulators available:

### Currently Connected:
- ✅ **macOS Desktop** - Native macOS app
- ✅ **Chrome Browser** - Web app

### Available Emulators:
- 📱 **iOS Simulator** - iPhone/iPad emulator
- 📱 **Medium Phone API 36.1** - Android emulator
- 📱 **Pixel 8 Pro** - Android emulator (Google)

## Running the App

### Quick Start (Auto-select device)
```bash
cd kobo
flutter run
```

### On macOS Desktop
```bash
cd kobo
flutter run -d macos
```

### On Chrome (Web)
```bash
cd kobo
flutter run -d chrome
```

### On iOS Simulator
First launch the simulator:
```bash
cd kobo
flutter emulators --launch apple_ios_simulator
```
Then run the app:
```bash
flutter run -d ios
```

### On Android Emulator (Medium Phone)
First launch the emulator:
```bash
cd kobo
flutter emulators --launch Medium_Phone_API_36.1
```
Then run the app:
```bash
flutter run -d android
```

### On Android Emulator (Pixel 8 Pro)
First launch the emulator:
```bash
cd kobo
flutter emulators --launch Pixel_8_Pro
```
Then run the app:
```bash
flutter run -d android
```

## Testing the App

The app comes pre-loaded with sample data:
- 5 sample items (Tomatoes, Palm Oil, Garri, Pepper, Onions)
- 3 sample sales transactions

### Try These Features:

1. **Home Tab** 🏠
   - View today's sales summary
   - Check total items and low stock alerts
   - Use Quick Sell buttons for fast transactions
   - See recent sales history

2. **Items Tab** 📦
   - View all inventory items
   - Tap "+ Add Item" to add new products
   - Tap "Sell" on any item to record a sale
   - Notice the color dots: Green = Produce, Orange = Groceries
   - Items with ≤5 quantity show in red (low stock warning)

3. **Sales Tab** 📊
   - View all today's transactions
   - See total earnings
   - Check transaction count and details

## App Features

### Recording a Sale
1. Tap any item from Home or Items tab
2. Use +/- buttons to adjust quantity
3. See the total amount update in real-time
4. Tap "Confirm Sale ✓" to complete
5. Inventory automatically updates

### Adding New Items
1. Go to Items tab
2. Tap "+ Add Item"
3. Enter item name (e.g., "Rice (bag)")
4. Enter price in Naira (e.g., 5000)
5. Enter quantity (e.g., 10)
6. Select category (Produce or Groceries)
7. Tap "Add Item +"

## Design Highlights

- **Nigerian Market Focus**: Prices in Naira (₦), common market items
- **Easy to Use**: Large buttons, simple navigation
- **Visual Feedback**: Color-coded categories, low stock warnings
- **Quick Actions**: Fast selling from home screen
- **Professional Look**: Clean design with green prosperity theme

## Next Steps

To customize for production:
1. Add data persistence (SQLite or Hive)
2. Implement user authentication
3. Add backup/restore functionality
4. Generate PDF receipts
5. Add WhatsApp sharing
6. Create reports (daily/weekly/monthly)
