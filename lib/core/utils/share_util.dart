import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtil {
  static final ScreenshotController screenshotController = ScreenshotController();

  static Future<void> shareWidget({
    required Widget widget,
    required String text,
    required BuildContext context,
  }) async {
    try {
      final uint8list = await screenshotController.captureFromWidget(
        Material(child: widget),
        context: context,
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/report_share.png').create();
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: text,
      );
    } catch (e) {
      debugPrint('Error sharing widget: $e');
      // Fallback to text only if screenshot fails
      await Share.share(text);
    }
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
