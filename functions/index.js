// const functions = require("firebase-functions");
// const admin = require("firebase-admin");

// admin.initializeApp();

// exports.sendNotificationOnNewMessage = functions.firestore
//   .document("chat_rooms/{chatRoomId}/messages/{messageId}")
//   .onCreate(async (snapshot, context) => {
//     const messageData = snapshot.data();
//     const recipientId = messageData.receiverId;
//     const senderId = messageData.senderId;

//     // Fetch recipient's FCM token
//     const recipientDoc = await admin.firestore().collection("users").doc(recipientId).get();
//     const recipientToken = recipientDoc.data().fcmToken;
//     const senderDoc = await admin.firestore().collection("users").doc(senderId).get();

//     if (!recipientToken) {
//       console.log("No FCM token found for user:", recipientId);
//       return;
//     }

    

//     const payload = {
//       notification: {
//         title: senderDoc.data().username,
//         body: messageData.messageType === "files" ? "Đã gửi file phương tiện" : messageData.message,
//         click_action: "FLUTTER_NOTIFICATION_CLICK",
//       },
//       token: recipientToken,
//     };

//     await admin.messaging().send(payload);
//   });


const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();

exports.sendNotificationOnNewMessage = onDocumentCreated(
  "chat_rooms/{chatRoomId}/messages/{messageId}",
  async (event) => {
    const messageData = event.data?.data(); // Get message document data
    if (!messageData) return;

    const recipientId = messageData.receiverId;
    const senderId = messageData.senderId;

    // Fetch recipient's FCM token
    const recipientDoc = await db.collection("users").doc(recipientId).get();
    const recipientToken = recipientDoc.data()?.fcmToken;
    const senderDoc = await db.collection("users").doc(senderId).get();

    if (!recipientToken) {
      console.log("No FCM token found for user:", recipientId);
      return;
    }

    // Construct notification payload
    const payload = {
      notification: {
        title: senderDoc.data().username,
        body: messageData.messageType === "files" ? "Đã gửi file phương tiện" : messageData.message,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: recipientToken,
    };

    // Send push notification
    try {
      await getMessaging().send(payload);
      console.log("Notification sent successfully to:", recipientId);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  }
);