import 'package:agro_mulher/Pages/mentor.dart';
import 'package:agro_mulher/Util/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Pages/profile_page.dart';
import '../Pages/news.dart';
import '../Pages/marketplace.dart';
import '../Controllers/auth_provider.dart';

class HomePage extends StatelessWidget{
  final int index;
  
  HomePage({this.index});
  
  Widget _userProfile(BuildContext context) {
    return FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return ProfileView(snapshot.data);
      },
    );
  }

  Widget _mentor(BuildContext context, DocumentSnapshot data){
    Profile user = Profile.fromSnapshot(data);
    return Mentor(user.job, user.userId);
  }

  Widget _userId(BuildContext context) {
    return FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('users').document(snapshot.data).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
            return _mentor(context, snapshot.data);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
      home: DefaultTabController(
        initialIndex: index,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
            title: Text('AgroMulher', style: TextStyle(),),
          ),
          bottomNavigationBar: TabBar(
            labelColor: Colors.lightGreen,
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.work)),
              Tab(icon: Icon(Icons.find_in_page)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
          body: TabBarView(
            children: [
              new NewsFeedPage(),
              new MarketPlace(),
              _userId(context),
              _userProfile(context),
            ]
          )
        )
      )
    );
  }
}