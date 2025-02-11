# Flutter Easy Build Example

This example demonstrates how to use the `flutter_easy_build` CLI tool to simplify building Flutter APKs and to automatically open the output folder in your file explorer.

**Note:** Support for building AAB (Android App Bundle) files is planned for a future release.

**Prerequisites:**

*   You must have Flutter installed and configured on your system.
*   You must have a Flutter project to build.

**Basic Usage:**

The `flutter_easy_build` tool provides two main commands:

*   `buildApk`: Builds the APK and opens the output directory.
*   `cleanAndBuild`: Cleans the project, builds the APK, and opens the output directory.

**Examples:**

**1. Building a Standard APK:**

To build a standard APK for your Flutter project, navigate to the root directory of your Flutter project in your terminal and run:

```
flutter_easy_build buildApk
```


This command will:

1.  Build an APK in release mode using the default Flutter build settings.
2.  Open a file explorer window, displaying the generated APK file in your system's file explorer.

**2. Cleaning and Building APK:**

To clean the Flutter project, build the APK file, and open the output directory, run:

```
flutter_easy_build cleanAndBuild
```

This command will:

1.  Clean the Flutter project using the `flutter clean` command.
2.  Build an APK using the default Flutter build settings.
3.  Open a file explorer window, displaying the generated APK file in your system's file explorer.

