# v2.1

- Added a filtering / sorting system for the deadlines
- Support sorting by name, date, and reverting the sort to default
- Supports ascending and descending order

# v2.0

- Added a fully functional Login / Register page
- Added fully functional backend. Database, and APIs
- Each user has their own deadlines
- Insert (add), update (edit), delete, deadlines are allowed
- Revamped the read-write functionality. Now only the theme data and user data are stored locally. Deadlines and dates are stored on database
- Added a refresh button to the appbar for refreshing deadlines in case of modification from database or different device
- Changed delete data feature to log out

# vFinalPhase1

- Nothing of note added. Fixed version in about section.

# v1.2

- added ability to click on deadline (InkWell), functions same as edit


# v1.1

- changed dates list from String to DateTime, modified read and write functions to accomodate the change, as well as all usages for dates
- added a TextEditingController for adding new deadlines, similar to the one made for editing deadlines
- added a dateCalculator function to calculate the difference between current time and deadline time
- made both adding and editing deadlines limited to only 50 characters, textfield doesn't allow an input larger than 50 chars
- changed deadline and date display to a column instead of multiple line Text
- now displays remaining date for deadline. eg "Due Today", "Due in 5 days", "Due Date Passed", etc
- fixed a few bugs, including but not limited to the date not fully being removed when clicking the delete button
