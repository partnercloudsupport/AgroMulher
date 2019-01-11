import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Pages/help_support.dart';
import 'package:agro_mulher/Pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Menu extends StatelessWidget {
  final VoidCallback onSignedOut;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();  

  Menu({this.onSignedOut});

  void pushFCMToken(BuildContext context, String token) async {
    String user = await AuthProvider.of(context).auth.currentUser();
    DocumentReference ref = Firestore.instance.collection('fcm').document(user);

    ref.setData({'token' : token});
  }

  void firebaseCloudMessagingListeners(BuildContext context) {
    // if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token){
      pushFCMToken(context, token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    firebaseCloudMessagingListeners(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Image(
          image: new AssetImage("Imgs/background.jpg"),
          fit: BoxFit.cover,
          color: Colors.black54,
          colorBlendMode: BlendMode.darken,
        ),
        new Container(
          //color: Colors.white,
          padding: EdgeInsets.all(30.0),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: new AssetImage("Imgs/logo.png"),
                  height: 210.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        width: MediaQuery.of(context).size.width/3.1,
                        height: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.share, size: 40.0),
                            Text("Feed de notícias", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),)
                          ],
                        )
                      ),
                      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomePage(index:  0,))),
                    ),
                    FlatButton(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        width: MediaQuery.of(context).size.width/3.1,
                        height: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.addressCard, size: 40.0),
                            Text('Perfil',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0)
                            ),
                          ],
                        )
                      ),
                      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomePage(index:  3,))),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 10.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        width: MediaQuery.of(context).size.width/3.1,
                        height: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.comments, size: 40.0),
                            Text('Mentoria',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0)),
                          ],
                        )
                      ),
                      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomePage(index:  2,))),
                    ),
                    FlatButton(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        width: MediaQuery.of(context).size.width/3.1,
                        height: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.work, size: 40.0, color: Colors.black.withOpacity(0.85),),
                            Text('Oportunidades',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.5)),
                          ],
                        )
                      ),
                      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomePage(index:  1,))),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20.0,
          top: 40.0,
          child: FloatingActionButton(
            backgroundColor: Colors.lightGreen.withAlpha(127),
            mini: true,
            child: Icon(FontAwesomeIcons.signOutAlt, size: 20.0),
            onPressed: () { print('sari'); onSignedOut();},
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          // top: 0,
          bottom: 0,
          child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton(
                    shape: const StadiumBorder(),
                    fillColor: Colors.pinkAccent,
                    splashColor: Colors.pink,
                    child: Text("Ajuda", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                    onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HelpSupport(index:  4,))),
                  )
                ],
              ),
        )
      ],
    );
  }
}