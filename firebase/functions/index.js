const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
});

exports.sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();

    // Get all users' FCM tokens
    const usersSnapshot = await admin.firestore().collection('users').get();
    const tokens = [];

    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log('No FCM tokens found');
      return;
    }

    const payload = {
      notification: {
        title: notification.title,
        body: notification.subtitle,
      },
      data: {
        aqiValue: notification.aqiValue.toString(),
        locationName: notification.locationName,
      },
    };

    // Send to all tokens
    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log('Successfully sent message:', response);
  });
