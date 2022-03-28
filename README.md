# Shuttlers

A kitty app for my badminton group.

## Features

- Members can see their balance and spending history
- Admin can:
    - add/remove members
    - add expenditure
    - add funds to members

## Breakdown

- Uses Google Firebase as a backend.
    - Admin member is authed through Firebase Authentication.
    - All data is stored on a Firebase Firestore DB with rules only allowin Admin member to add/update/remove data. Anyone can read data.
- Deployed as an Android app and also on GitHub pages. [Click here to check it out!](https://beardytim.github.io/shuttlers/)

## To Do

- [ ] redesign main view
- [ ] fix the dialogs - more of a flow?
- [ ] increase admin capability - edit previous games etc.