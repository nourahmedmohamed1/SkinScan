import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/scan_record.dart';

/// Provider for managing scan history
/// Uses ChangeNotifier to notify UI of changes
class ScanHistoryProvider extends ChangeNotifier {
  List<ScanRecord> _scans = [];

  // Getter for scans (read-only access)
  List<ScanRecord> get scans => List.unmodifiable(_scans);

  // Key for SharedPreferences storage
  static const String _storageKey = 'scan_history';

  /// Constructor - automatically loads saved history
  ScanHistoryProvider() {
    _loadScans();
  }

  /// Load scans from local storage
  Future<void> _loadScans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? scansJson = prefs.getString(_storageKey);

      if (scansJson != null && scansJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(scansJson);
        _scans = decodedList
            .map((item) => ScanRecord.fromJson(item as Map<String, dynamic>))
            .toList();

        // Sort by date (newest first)
        _scans.sort((a, b) => b.date.compareTo(a.date));

        notifyListeners();
      }
    } catch (e) {
      print('Error loading scans: $e');
      _scans = [];
    }
  }

  /// Save scans to local storage
  Future<void> _saveScans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> scansList =
      _scans.map((scan) => scan.toJson()).toList();
      final String scansJson = jsonEncode(scansList);
      await prefs.setString(_storageKey, scansJson);
    } catch (e) {
      print('Error saving scans: $e');
    }
  }

  /// Add a new scan to history
  void addScan(ScanRecord scan) {
    _scans.insert(0, scan); // Add to beginning (newest first)
    notifyListeners();
    _saveScans();
  }

  /// Remove a scan from history
  void removeScan(String id) {
    _scans.removeWhere((scan) => scan.id == id);
    notifyListeners();
    _saveScans();
  }

  /// Clear all scans
  void clearAll() {
    _scans.clear();
    notifyListeners();
    _saveScans();
  }

  /// Get scan by ID
  ScanRecord? getScanById(String id) {
    try {
      return _scans.firstWhere((scan) => scan.id == id);
    } catch (e) {
      return null;
    }
  }
}

/*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎓 BEGINNER'S GUIDE TO STATE MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 What is State Management?
───────────────────────────────────────────
State = Data that can change in your app
State Management = How you handle and share this data

Example:
- User's scan history is STATE
- When you add/remove scans, the STATE changes
- UI needs to update when state changes


📌 ChangeNotifier Pattern
───────────────────────────────────────────
ChangeNotifier is like a "broadcaster":

1. Extends ChangeNotifier
2. Holds data (_scans list)
3. Provides methods to modify data (addScan, removeScan)
4. Calls notifyListeners() when data changes
5. UI automatically rebuilds


📌 How It Works
───────────────────────────────────────────
1. Provider wraps your app in main.dart:

   ChangeNotifierProvider(
     create: (context) => ScanHistoryProvider(),
     child: MaterialApp(...),
   )

2. UI reads data with Consumer:

   Consumer<ScanHistoryProvider>(
     builder: (context, provider, child) {
       return ListView(
         children: provider.scans.map(...).toList(),
       );
     },
   )

3. UI modifies data with Provider.of:

   Provider.of<ScanHistoryProvider>(context, listen: false)
       .addScan(newScan);


📌 SharedPreferences (Local Storage)
───────────────────────────────────────────
SharedPreferences = Simple key-value storage on device
Like a small database for simple data

- Survives app restarts
- Stores strings, ints, bools
- We store JSON strings for complex objects

Flow:
1. Convert objects to JSON (toJson())
2. Convert JSON list to string (jsonEncode())
3. Save string (prefs.setString())
4. Load string (prefs.getString())
5. Convert string to JSON (jsonDecode())
6. Convert JSON to objects (fromJson())


📌 Why Use Provider?
───────────────────────────────────────────
Without Provider:
❌ Pass data through many screens
❌ Duplicate data everywhere
❌ Hard to keep in sync

With Provider:
✅ Single source of truth
✅ Any screen can access data
✅ Automatic UI updates
✅ Clean, maintainable code


📌 Key Concepts
───────────────────────────────────────────
1. notifyListeners():
   - Tells UI "data changed, rebuild!"
   - Like calling setState() globally

2. List.unmodifiable():
   - Returns read-only list
   - Prevents accidental modifications
   - Enforces using proper methods

3. async/await with SharedPreferences:
   - Getting SharedPreferences takes time
   - Must wait for it
   - Use await to wait for completion


📌 Alternative: Using a Real Database
───────────────────────────────────────────
For more complex apps, use a real database:

Options:
- sqflite: SQLite database for Flutter
- hive: Fast key-value database
- isar: Modern NoSQL database
- firebase: Cloud database

To upgrade to sqflite later:
1. Add sqflite package
2. Create database helper class
3. Replace SharedPreferences calls
4. Add SQL queries (INSERT, SELECT, DELETE)


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
*/