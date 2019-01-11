// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const request = require('request');

const db = admin.firestore();

const notifyUrl = 'https://fcm.googleapis.com/fcm/send';
const options = {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'key=AAAALiA9ah0:APA91bGDdKjTwp4Mo2mQIs7CjjotT91uLBem7irgMgX2ns46LmwxISDnbZJ7CUEBFOYsnAW4yXPyVJ0_dIHdGvDvoorXfGV6kIGqBPHHMXCzHjO_xUOdlI7Nqzru1y80h9xyeWSIie2o'
  }
};

exports.addCommentNotification = functions.firestore
    .document('comments/{commentRef}')
    .onCreate((snapshot, context) => {
        const original = snapshot.data();

        var ref = db.collection('posts').doc(original.postId);
        return ref.get().then(doc => {
		console.log(doc);
            var ref = db.collection('fcm').doc(doc.data().author);
            ref.get().then(doc => {
	        const postData = JSON.stringify({
	            "notification": {
		        "body": "Novo comentário adicionado em sua publicação",
		        "title": "Novidades!"
	            },
	            "priority": "high",
	            "data": {
		        "click_action": "FLUTTER_NOTIFICATION_CLICK",
		       "id": "1",
		       "status": "done"
	            },
                    "to": doc.data().token
	        });
		
	        const req = request(notifyUrl, options, (res) => { });
	        req.write(postData);
            });
        });
    });
