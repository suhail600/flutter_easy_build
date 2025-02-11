/// A simple command-line tool to automate Flutter APK builds,
/// streamlining the process of building, renaming, and opening
/// the output directory.
///
/// This tool reads version information from the `pubspec.yaml` file,
/// cleans the project (optional), builds the APK in release mode,
/// renames the APK with a timestamp and version, and then opens
/// the directory containing the generated APK in the system's file explorer.
///
/// Usage:
///
/// 1.  Run `flutter_easy_build buildApk` to build the APK.
/// 2.  Run `flutter_easy_build cleanAndBuild` to clean the project and then build the APK.

library;

import 'dart:convert';
import 'dart:io';

/// ANSI escape code to reset text formatting.
const _reset = '\x1B[0m';

/// ANSI escape code for blue text.
const _bl = '\x1B[34m';

/// ANSI escape code for green text.
const _gr = '\x1B[32m';

/// ANSI escape code for red text.
const _rd = '\x1B[31m';

/// ANSI escape code for yellow text.
const _yl = '\x1B[33m';

/// ANSI escape code for white text.
const _wt = '\x1B[37m';

/// Log data
void _logData(String key, String msg, {String clr = _reset}) {
  print('$clr[$key] $msg\x1B[0m');
}

/// Handle process
Future<void> _handleProcess(Process process, String key) async {
  process.stdout.transform(const Utf8Decoder()).listen((data) {
    _logData(key, data, clr: _wt);
  });
  process.stderr.transform(const Utf8Decoder()).listen((data) {
    _logData('${key}_ERROR', data, clr: _rd);
  });

  final exitCode = await process.exitCode;
  final lkey = key.toLowerCase();

  if (exitCode != 0) {
    _logData(
      'ERROR',
      'Flutter $lkey failed with exitCode: $exitCode',
      clr: _rd,
    );
    return;
  }
}

/// Get formatted date and time
String _getFormattedDt() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
}

/// Open directory
Future<void> _openDir(String apkPath) async {
  final dirPath = Directory(apkPath).parent.path;

  if (Platform.isWindows) {
    Process.run('explorer', [dirPath]);
  } else if (Platform.isMacOS) {
    Process.run('open', [dirPath]);
  } else if (Platform.isLinux) {
    Process.run('xdg-open', [dirPath]);
  } else {
    _logData('ERROR', 'Unsupported operating system: $dirPath', clr: _rd);
  }

  _logData('INFO', 'Opening APK directory: $dirPath', clr: _bl);
}

///   - [cleanAndBuild] to clean the project before building.
Future<void> cleanAndBuild() async => await _buildApk(clean: true);

///   - [buildApk] for building the APK without cleaning.
Future<void> buildApk() async => await _buildApk(clean: false);

/// Build APK function
Future<void> _buildApk({required bool clean}) async {
  _logData('INFO', 'Current directory: ${Directory.current.path}', clr: _bl);

  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)');
  final match = versionRegex.firstMatch(content);

  if (match != null) {
    final flutterPath = Platform.isWindows ? 'flutter.bat' : 'flutter';

    final version = match.group(1)!;
    final buildNumber = int.parse(match.group(2)!);
    final dt = _getFormattedDt(); // Get formatted date and time

    if (clean) {
      _logData('INFO', 'Cleaning the project...', clr: _yl);
      final cleanProcess = await Process.start(flutterPath, ['clean']);
      await _handleProcess(cleanProcess, 'CLEAN');
    }

    _logData('INFO', 'Running flutter pub get...', clr: _yl);
    final pubGetProcess = await Process.start(flutterPath, ['pub', 'get']);
    await _handleProcess(pubGetProcess, 'PUB_GET');

    _logData('INFO', 'Building the APK...', clr: _yl);
    final buildProcess = await Process.start(flutterPath, ['build', 'apk']);
    await _handleProcess(buildProcess, 'BUILD');

    /// APK build was successful, rename the APK file
    const apkPath = 'build\\app\\outputs\\flutter-apk\\app-release.apk';
    final apkFile = File(apkPath);

    if (apkFile.existsSync()) {
      /// Regular expression to find the app name
      final nameRegex = RegExp(r'name:\s*(\S+)');
      final nameMatch = nameRegex.firstMatch(content);
      final appName = nameMatch?.group(1) ?? 'app-name'; // name if not found
      final newApkName = '$appName-$dt-v$version+$buildNumber.apk';
      final newApkPath = 'build\\app\\outputs\\flutter-apk\\$newApkName';
      apkFile.renameSync('${apkFile.parent.path}\\$newApkName');

      _logData(
        'INFO',
        'APK file renamed to : $newApkName\n[INFO] APK file at : $newApkPath',
        clr: _gr,
      );

      /// Green text

      await _openDir(newApkPath);
    } else {
      _logData('ERROR', 'APK file not found at $apkPath', clr: _rd);
    }
  } else {
    _logData('ERROR', 'Version information not found in pubspec.yaml.',
        clr: _rd);
  }
}
