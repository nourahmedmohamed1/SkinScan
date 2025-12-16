import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/scan_history_provider.dart';
import '../models/scan_record.dart';
// ✨ السطور المضافة للمسارات
import 'results_screen.dart';
import '../models/prediction.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          // Clear all button
          Consumer<ScanHistoryProvider>(
            builder: (context, provider, child) {
              if (provider.scans.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear All',
                onPressed: () => _showClearDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF4FF),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<ScanHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.scans.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.scans.length,
              itemBuilder: (context, index) {
                final scan = provider.scans[index];
                return _buildScanCard(context, scan, provider);
              },
            );
          },
        ),
      ),
    );
  }

  // Empty state when no scans
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: const Color(0xFF0B5FA5).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Scan History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B2946),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your saved scans will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // Individual scan card
  Widget _buildScanCard(
      BuildContext context,
      ScanRecord scan,
      ScanHistoryProvider provider,
      ) {
    final bool isSuspicious = scan.result.toLowerCase() == 'suspicious';
    final Color resultColor = isSuspicious
        ? const Color(0xFFD9534F)
        : const Color(0xFF28A745);

    // Format date
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(scan.date);

    return Dismissible(
      key: Key(scan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (direction) {
        provider.removeScan(scan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Scan deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.addScan(scan);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // ✨ التعديل المطلوب: الانتقال لصفحة النتائج بدلاً من الديالوج
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(
                  prediction: Prediction(
                    result: scan.result,
                    confidence: scan.confidence,
                  ),
                  imageFile: File(scan.imagePath),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: File(scan.imagePath).existsSync()
                        ? Image.file(
                      File(scan.imagePath),
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Scan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Result
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: resultColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: resultColor),
                        ),
                        child: Text(
                          scan.result.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Confidence
                      Text(
                        'Confidence: ${scan.confidence.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show detailed view dialog (تم الحفاظ عليها دون حذف)
  void _showDetailDialog(BuildContext context, ScanRecord scan) {
    final bool isSuspicious = scan.result.toLowerCase() == 'suspicious';
    final Color resultColor = isSuspicious
        ? const Color(0xFFD9534F)
        : const Color(0xFF28A745);

    final dateFormat = DateFormat('MMMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(scan.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: File(scan.imagePath).existsSync()
                    ? Image.file(
                  File(scan.imagePath),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Result Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: resultColor, width: 2),
                      ),
                      child: Text(
                        scan.result.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confidence
                    Text(
                      'Confidence: ${scan.confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0B2946),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Confirm clear all dialog
  void _showClearDialog(
      BuildContext context,
      ScanHistoryProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete all saved scans. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All scans cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/*
🎓 BEGINNER EXPLANATION:

1. Consumer widget:
   - Listens to changes in ScanHistoryProvider
   - Rebuilds only this widget when data changes
   - More efficient than using Provider.of

2. ListView.builder:
   - Creates list items on demand (lazy loading)
   - More efficient for long lists
   - itemBuilder is called for each item

3. Dismissible widget:
   - Allows swipe-to-delete gesture
   - background: Widget shown while swiping
   - onDismissed: Called when swiped away

4. DateFormat:
   - From intl package
   - Formats dates nicely
   - 'MMM dd, yyyy' → "Dec 06, 2025"

5. File().existsSync():
   - Checks if image file still exists
   - Prevents errors if file was deleted
   - Shows placeholder if missing

6. showDialog():
   - Shows popup dialog
   - AlertDialog: Pre-styled dialog widget
   - Modal: User must interact before continuing
*/