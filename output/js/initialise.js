var app;

function initialiseApp(authToken, uid, displayName) {
  app = Elm.Main.init({
    node: document.getElementById('elmContainer'),
    flags: {
      authToken: authToken,
      displayName: displayName,
      uid: uid
    }
  });
}

function subscribeToSaveUserData() {
  app.ports.saveUserData.subscribe(function (data) {
    saveUserData(JSON.stringify(data));
  });
}

function subscribeToLoadCharacters() {
  db.collection("characters").doc("EgWivyQbMFqe71Fm5VgW").onSnapshot({
        // Listen for document metadata changes
        includeMetadataChanges: false
    }, function(doc) {
        app.ports.loadCharacters.send(doc.data());
    });
}

function subscribeToLoadUserScores() {
  db.collection("userScores").doc("menijTKeF99gb0mEjkmW").onSnapshot({
        // Listen for document metadata changes
        includeMetadataChanges: false
    }, function(doc) {
        app.ports.loadUserScores.send(doc.data());
    });
}

var uid;

function getCharacters() {
  var docRef = db.collection("characters").doc("EgWivyQbMFqe71Fm5VgW");
  docRef.get().then(function (doc) {
    if (doc.exists) {
      app.ports.loadCharacters.send(doc.data());
    } else {
      // doc.data() will be undefined in this case
      console.log("No such document!");
    }
  }).catch(function (error) {
    console.log("Error getting document:", error);
  });
}

function saveUserData(data) {
  // Add a new document in collection "cities"
  db.collection("userData").doc(uid).set(JSON.parse(data))
    .then(function () {
      console.log("Saved User Data!");
    })
    .catch(function (error) {
      console.error("Error writing document: ", error);
    });
}

function getUserData() {
  var docRef = db.collection("userData").doc(uid);
  docRef.get().then(function (doc) {
    if (doc.exists) {
      app.ports.loadUserData.send(doc.data());

    } else {
      // doc.data() will be undefined in this case
      console.log("No such document!");
    }
  }).catch(function (error) {
    console.log("Error getting document:", error);
  });
}

function getUserScores() {
  var docRef = db.collection("userScores").doc("menijTKeF99gb0mEjkmW");
  docRef.get().then(function (doc) {
    if (doc.exists) {
      app.ports.loadUserScores.send(doc.data());
    } else {
      // doc.data() will be undefined in this case
      console.log("No such document!");
    }
  }).catch(function (error) {
    console.log("Error getting document:", error);
  });
}

initApp = function () {
  firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
      // User is signed in.
      displayName = user.displayName;
      var email = user.email;
      var emailVerified = user.emailVerified;
      var photoURL = user.photoURL;
      uid = user.uid;
      var phoneNumber = user.phoneNumber;
      var providerData = user.providerData;
      user.getIdToken().then(function (accessToken) {
        // document.getElementById('sign-in-status').textContent = 'Signed in';
        // document.getElementById('sign-in').textContent = 'Sign out';
        // document.getElementById('account-details').textContent = JSON.stringify({
        //   displayName: displayName,
        //   email: email,
        //   emailVerified: emailVerified,
        //   phoneNumber: phoneNumber,
        //   photoURL: photoURL,
        //   uid: uid,
        //   accessToken: accessToken,
        //   providerData: providerData
        // }, null, '  ');
        initialiseApp(accessToken, user.uid, displayName);
        
        getCharacters();
        getUserData();
        subscribeToLoadCharacters();
        subscribeToSaveUserData();
        subscribeToLoadUserScores();
        getUserScores();
      });
    } else {
      // User is signed out.
      document.getElementById('sign-in-status').textContent = 'Signed out';
      document.getElementById('sign-in').textContent = 'Sign in';
      document.getElementById('account-details').textContent = 'null';
    }
  }, function (error) {
    console.log(error);
  });
};

window.addEventListener('load', function () {
  initApp()
});
var db = firebase.firestore(app);



