import 'dart:io';

import 'package:flutter_easy_build/build_apk.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("❌ No command provided. Use:");
    print("   flutter_easy_build buildApk    # Build the APK");
    print("   flutter_easy_build cleanAndBuild # Clean and build the APK");
    exit(1);
  }

  switch (args[0]) {
    case 'buildApk':
      buildApk();
      break;
    case 'cleanAndBuild':
      cleanAndBuild();
      break;
    default:
      print("❌ Unknown command: ${args[0]}");
      exit(1);
  }
}
