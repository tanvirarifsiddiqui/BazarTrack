# BazarTrack
Smart Purchase & Money Management System

## Overview
BazarTrack is a Flutter application that helps shop owners and assistants keep
track of purchases and spending. The owner can create purchase orders, record
advance payments, and monitor a complete audit trail of all activity.

## Main Features
- **User & Role System** – manage owners and assistants with individual wallet
  balances.
- **Order Management** – create orders, assign them, and track progress.
- **Order Items** – update item quantities, mark them purchased, or flag as
  unavailable.
- **Advance Payments** – issue advances and automatically deduct expenses.
- **History & Audit Log** – maintain a timeline of every change for
  accountability.


The project follows a layered architecture with modular features so each part
of the codebase stays organized and maintainable.

## Prerequisites
- **Flutter**: stable 3.x
- **Dart**: 3.7 or later

Make sure Flutter and Dart are installed and available in your `PATH`.
Android Studio or VS Code with the Flutter extension are recommended for
development.

## Running the App
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run on an emulator or connected device:
   ```bash
   flutter run
   ```
   The app will start on the selected device. Use hot reload during development
   for faster iteration.

## Contribution Guidelines
We welcome pull requests. Before submitting one:
1. Keep new Dart files in their respective feature directories.
2. Run `flutter analyze` and `flutter test`.
3. Use commit messages in the form `<module>: <short description>`.
4. Use GetX for navigation and dependency injection; register controllers in
   `helper/get_di.dart`.
5. Update language files such as `assets/language/en.json` when adding text.
6. Open a pull request for review when your changes are ready.

