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

## Done With
* Flutter (Dart)
* VSCode

## Features (v1):
* adding deadlines
* editing deadlines
* deleting deadlines
* changing theme between light and dark
* choosing an accent color from list or custom accent color
* read and write to local storage, meaning data gets saved on device
* about menu, including a delete all data button

## Details (v1):
* intuitive and theme-friendly icons for (almost) everything
* smooth animations for all color changes
* support for text overflow
* support for many deadlines (scrollable)
* setting custom color includes a preview circle thing
* date picker for adding deadlines
* ~~support for dateless deadlines~~ and ones with date - Removed in v2.0
* edit menu starts with initial value of deadline and date (eg. if deadline is "Birthday" and date is "11/28/2025", then the edit menu starts with those values)
* removing date in the edit menu if set, **However, cannot confirm without a date** <-Added in v2.0
* cannot save a deadline if title is empty (grays out the save button and makes it non-functional)
* cannot save an edited deadline if title and date match (grayed out save button)

## Future Plans
* "Complete deadline", functions like delete but stores in a different "Completed" area
* ~~Sorting and filtering deadlines~~ - Done in v2.1
* Notifications for upcoming deadlines
* Decreasing code size, removing repetitions into methods / widgets
* ~~Adding a login page with backend~~ Done in v2.0
* ~~Making each deadline clickable (edit)~~ Done in v1.2
* ~~Adding a "Due in x days" feature~~ Done in v1.1
