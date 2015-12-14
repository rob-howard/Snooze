# Snooze
This is an app for controlling a sonos system from your iphone.  Additionally, it's an app that connects to a microsoft band.

Personal goals of this project:
- Write something that I will use
- Write something with Swift, Storyboards, and Autolayout
- Get familiar with the Microsoft Band SDK, do something non-trivial - https://developer.microsoftband.com/
- Integrate with Sonos, since there isn't a public SDK, try to figure out how. Forked someones objc project: https://github.com/rob-howard/sonos-objc-fork 


Installation / Setup:
- git clone https://github.com/rob-howard/Snooze.git
- git submodule init
- git submodule update
- pod install

Initial feature (Sleep timer):
- app will create a new Tile on a Microsoft Band
- select a sonos controller for use with the app
- select a sonos favorite to play
- open the tile on the microsoft band, if all is set up properly it will prompt "Ready to sleep?" with a "Go" button
- press "Go" and the favorite music will play in the selected zone with a sleep timer of 30 minutes

Known Issues:
- Not a whole lot of error checking... in progress, but really since the end user is one person there doesn't need to be ;)
- Nothing saved when app closed.  Work in progress.
- Not user friendly yet, very bare bones UI, early focus is on minimum functionality
- lots of other issues not really worth listing

Feature Roadmap:
- Initial setup wizard
- Persist settings after app closes (controller / music choices)
- Better list UI, images and such
- Sleep timer duration option
- Volume level option
- More sonos stuff (play/pause zones, etc.  )
- More Microsoft Band Tile features
- icons / UI / make pretty
