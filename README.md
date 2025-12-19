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
* Update baseUrl in lib/main.dart to point to your backend server
* Alternatively, Xampp can be used by changing baseUrl to http://localhost, and uploading the sql file to phpmyadmin
* I have set up a host and uploaded the backend and sql to it. change baseUrl in main.dart to http://yakback.atwebpages.com to use it

## Done With
* Flutter (Dart)
* VSCode
* PHP (Backend)
* MySQL (Database)

## Features (v2):
* login and register system with user authentication
* backend database storage for deadlines (MySQL)
* each user has their own separate deadlines
* adding deadlines
* editing deadlines
* deleting deadlines
* sorting deadlines by name or date (ascending/descending)
* changing theme between light and dark
* choosing an accent color from list or custom accent color
* local storage for theme preferences and user credentials (auto-login)
* refresh button to sync deadlines with database
* about menu with logout functionality
* "Due in x days" feature showing time until deadline

## Details (v2):
* intuitive and theme-friendly icons for (almost) everything
* smooth animations for all color changes
* support for text overflow
* support for many deadlines (scrollable)
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
* backend API endpoints: getUsers, insertUser, getDeadlines, insertDeadline, updateDeadline, deleteDeadline

## Backend Structure:
* PHP API files in Backend/ directory, to be uploaded to backend server if hosted or htdocs if using xampp
* MySQL database "deadtrack" with tables: users, deadlines
* json communication between flutter and php

## Future Plans
* "Complete deadline", functions like delete but stores in a different "Completed" area
* Filtering deadlines
* Notifications for upcoming deadlines
* Decreasing code size, removing repetitions into methods / widgets
* ~~Adding a login page with backend~~ Done in v2.0
* ~~Making each deadline clickable (edit)~~ Done in v1.2
* ~~Adding a "Due in x days" feature~~ Done in v1.1
* ~~Sorting deadlines~~ Done in v2.0
