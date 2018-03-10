# PinIt
PinIt is an image collection app inspired by Pinterest. 

![alt text](https://github.com/jwells18/PinIt/blob/master/PinIt_Preview.GIF)

# Disclaimer
I created PinIt to learn Swift and showcase my abilities to potential clients and employers. DO NOT USE IT TO COPY PINTEREST. The initial version was created in a couple of weeks and thus lacks some features and contains a few known bugs. I do not intend to manage this repo,  but please feel free to fork it and expand upon it.

# Setup
Firebase powers the backend for PinIt. Visit https://firebase.google.com to create an account and setup a project. Be sure to follow all of the instructions during setup and include your GoogleService-Info.plist file in this project. PinIt is currently limited to email authentification and must be selected as a "Sign-In Method" from the Authentification tab of your Firebase project account.

PinIt also relies on some Firebase Cloud Functions to manage data. Setup Firebase cloud functions by following these instructions https://firebase.google.com/docs/functions/get-started and deploying the code in the index.js file. Make sure that you update the welcome notification function with your own personalized welcome board.

There a few Cocoapod dependencies to install before launching PinIt. If you are unfamiliar with Cocoapods, please visit https://guides.cocoapods.org/using/getting-started.html to learn more and get started.

# Known Bugs / Missing Features
As I mentioned previously, I have no intention on managing this repo but I'm aware of the following bugs/missing features:

- Transition Animation sometimes causes issues with the layout being too far above or below the navigation bar
- Horizontal scrolling through pins does not have pagination
- Dismissing a Pin Detail controller that is not visible from the presenting controller causes crash (issue with setNeedsLayout)
- People to Follow in the discover section does not return users randomly but by their Firebase key
- Followers/Following returns a list of all users with their follower/following status instead of just followers/following (can be implemented easily using Cloud Firestore, which is still in beta as of March 2018)

There are other bugs and missing features of course, but I just highlighted a few. Some of these issues are noted in the source code.
