# Flutter Project: Deadline Tracker
#### by Yousef Kahwaji

## Changelog
[Changelog](CHANGELOG.MD)

## Usage:
### Cloning:
* ```git clone https://github.com/liuYousefKahwaji/CSCI410Project.git```
* ```cd CSCI410Project```

### Building and Running (android only):
* ```flutter build apk```
* Apk is generated in "build\app\outputs\flutter-apk\app-release.apk"
* move apk to android device and run it
* Done

### Backend Setup:
* Set up a MySQL database named "deadtrack"
* Configure PHP backend files in Backend/ directory
* Change the `isLocal` bool in lib/main.dart (true for localhost, false for hosted server)
* For local testing: set `isLocal = true` (uses http://localhost)
* For hosted testing: set `isLocal = false` (uses http://yakback.atwebpages.com)
* Alternatively, Xampp can be used with `isLocal = true`, and upload the sql file to phpmyadmin

## Done With
* Flutter (Dart)
* VSCode
* PHP (Backend)
* MySQL (Database)

## Features (v3):
* login and register system with user authentication
* backend database storage for deadlines (MySQL)
* each user has their own separate deadlines
* adding deadlines
* editing deadlines
* deleting deadlines
* sorting deadlines by name or date (ascending/descending)
* urgency color system - deadlines show color-coded urgency based on how soon they're due
* changing theme between light and dark
* choosing an accent color from list or custom accent color
* local storage for theme preferences and user credentials (auto-login)
* refresh button to sync deadlines with database
* about menu with logout functionality
* An improved "Due in x days" feature with more accurate date calculations
* A revamped deadline display UI with individual containers for each deadline

## Details (v3):
* intuitive and theme-friendly icons for (almost) everything
* smooth animations for all color changes
* support for text overflow
* support for many deadlines (scrollable)
* each deadline displayed in its own container with rounded borders and accent color background
* urgency color coding for deadline dates: red (overdue/today), orange (1-3 days), amber (4-7 days), green (8-30 days), blue gray (31+ days)
* more accurate date calculation using improved daysCalculator function
* setting custom color includes a preview circle thing
* date picker for adding deadlines
* deadlines require both title and date (cannot save without date)
* edit menu starts with initial value of deadline and date (eg. if deadline is "Birthday" and date is "11/28/2025", then the edit menu starts with those values)
* cannot save a deadline if title is empty (grays out the save button and makes it non-functional)
* cannot save an edited deadline if title and date match (grayed out save button)
* deadline titles limited to 50 characters
* clicking on a deadline opens the edit dialog
* auto-login functionality - saves user credentials locally and automatically logs in on app start
* theme preferences (light/dark mode and accent colors) saved locally per device
* default dark mode color updated to a lighter purple (v3.0)
* easy backend switching via `isLocal` bool in main.dart
* backend API endpoints: getUsers, insertUser, getDeadlines, insertDeadline, updateDeadline, deleteDeadline

## Backend Structure:
* PHP API files in Backend/ directory, to be uploaded to backend server if hosted or htdocs if using xampp
* MySQL database "deadtrack" with tables: users, deadlines
* json communication between flutter and php

## Future Plans
* "Complete deadline", functions like delete but stores in a different "Completed" area
* Filtering deadlines (eg, show only deadlines due this week, search by keyword, etc)
* Notifications for upcoming deadlines
* Decreasing code size, removing repetitions into methods / widgets
* ~~Adding a login page with backend~~ Done in v2.0
* ~~Making each deadline clickable (edit)~~ Done in v1.2
* ~~Adding a "Due in x days" feature~~ Done in v1.1
* ~~Sorting deadlines~~ Done in v2.1
* ~~overhaul ui~~ Done in v3.0
* ~~Urgency color system~~ Done in v3.0
