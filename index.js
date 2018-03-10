const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Listens for new user creation and sends welcome notification
exports.sendWelcomeNotification = functions.auth.user().onCreate((event) => {
    //Grab new user Data
    const user = event.data //Firebase user
    const uid = user.uid
    const timeStamp = admin.database.ServerValue.TIMESTAMP
    //Create Notification Dictionary
    var notificationDict = {
        "createdAt": timeStamp,
        "updatedAt": timeStamp,
        "boardId": " ",
        "boardCreatorId": " ",
        "images": " ",
        "message" : "We found someone who shares your taste in Pins!",
        "objectId": " ",
        "profilePicture" : " ",
        "type" : "board",
        "recipientId" : uid,
        "createdBy" : " "
      };
    return admin.database().ref('/Notifications').child(uid).child(notificationDict["objectId"]).set(notificationDict);
});

// Listens for new Pins added to /Pins/:pinnedBy/:objectId and creates a
// DiscoverPins version of the Pin to /DiscoverPins/:objectId
exports.createDiscoverPin = functions.database.ref('/Pins/{pinnedBy}/{objectId}').onCreate((event) => {
    // Grab the current value the uploaded Pin
    const originalPin = event.data.val();
    const originalPinId = event.params.objectId;
    console.log('Original Pin', originalPin);
    //Write Pin to Discover section
    return admin.database().ref('/DiscoverPins').child(originalPinId).set(originalPin);
});