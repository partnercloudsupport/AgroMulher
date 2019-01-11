import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../Util/profile.dart';
import '../Util/opportunity.dart';

import '../UI/profile_pic.dart';

class MarketOpportunity extends StatefulWidget {
  final String _id;

  MarketOpportunity(this._id);
 
  @override
  State<StatefulWidget> createState() => new MarketOpportunityState();
}

class MarketOpportunityState extends State<MarketOpportunity> {
  bool _showInterested = false;

  // ****** ACTIONS ****** //
  void _showInterest(String opportunity) async {
    String user = await AuthProvider.of(context).auth.currentUser();
    CollectionReference ref = Firestore.instance.collection('interest');

    QuerySnapshot a = await Firestore.instance.collection('interest').where('user', isEqualTo: user).where('opportunity', isEqualTo: opportunity).snapshots().first;
    
    if(a.documents.length > 0) return;

    ref.add({
      'opportunity': widget._id,
      'user': user
    });
  }

  void _deleteInterest(String interest) {
    Firestore.instance.collection('interest').document(interest).delete();
  }

  void _deleteOpportunity() async {
    // delete interests
    QuerySnapshot interests = await Firestore.instance.collection('interest').where('opportunity', isEqualTo: widget._id).getDocuments();
    for(int i=0; i < interests.documents.length; i++){
      Firestore.instance.collection('interest').document(interests.documents[i].documentID).delete();
    }

    // delete image
    StorageReference storage = FirebaseStorage.instance.ref().child('opportunity_imgs').child(widget._id+'.jpg');
    storage.delete();
    
    // delete opportunity
    Firestore.instance.collection('opportunity').document(widget._id).delete(); 

    // back to homepage
    Navigator.of(context).pop();
  }

  // ****** BUILDERS ****** //
  Widget _buildInterresed(BuildContext context, String author, DocumentSnapshot data, String intRef){
    Profile user = Profile.fromSnapshot(data);
    Size screenSize = MediaQuery.of(context).size;

    return new FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
        
        return new Container(
          width: screenSize.width,
          padding: EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              FlatButton(
                child: ListTile(
                  leading: ProfilePic(
                    userId: user.userId,
                    src: user.img,
                    size: 40.0,
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      //fontSize: 8.0,
                    ),
                  ),
                  subtitle: Text(
                    user.job == null ? 'Não informado' : user.job,
                    style: TextStyle(
                      //fontSize: 8.0,
                    ),
                  ),
                  // If the autor is the logged user, can delete all proposes, the user can delete your own proposes
                  trailing: user.userId != author && user.userId != snapshot.data ? Card() : IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20.0,
                    ),
                    onPressed: () => _deleteInterest(intRef),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => ProfileView(user.userId))),
              ),
              Divider(
                color: Colors.grey,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInterestList(BuildContext context, String author, QuerySnapshot data){   
    List<String> _users = data.documents.map((data) => data['user'].toString()).toList();
    List<String> _refs = data.documents.map((data) => data.documentID).toList();


    return Container(
      height: 180.0,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('users').document(_users[index]).snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

              return _buildInterresed(context, author, snapshot.data, _refs[index]);
            },
          );
        }
      )
    );
  }

  Widget _buildAuthor(BuildContext context, DocumentSnapshot data){
    Profile author = Profile.fromSnapshot(data);

    return ListTile(
        leading: ProfilePic(
          userId: author.userId,
          size: 50.0,
          src: author.img,
        ),
        title: Text(
          'Por: ${author.name}',
        ),
        subtitle: Text(
          '${author.desc}',
          softWrap: true,
          maxLines: 5,
        ),
        trailing: FutureBuilder(
          future: AuthProvider.of(context).auth.currentUser(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Container(
                                        width: MediaQuery.of(context).size.width/6,
                                        height: MediaQuery.of(context).size.height/6,
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(),
                                      );
            return author.userId != snapshot.data ? Card() : IconButton(icon: Icon(Icons.close), onPressed: () => _deleteOpportunity(),);
          },
        ),
      );
  }

  Widget _buildBody(BuildContext context, DocumentSnapshot data){
    Opportunity _opportunity = Opportunity.fromSnapshot(data);
    Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: AppBar(
        title: Text('Oportunidade'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            // Author info
            StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('users').document(_opportunity.author).snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container(
                                        width: MediaQuery.of(context).size.width/6,
                                        height: MediaQuery.of(context).size.height/6,
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(),
                                      );

                return _buildAuthor(context, snapshot.data);
              },
            ),
            Divider(
              color: Theme.of(context).accentColor,
            ),
            // Opportunity details
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  // Associate image
                  _opportunity.img == null || _opportunity.img == '' ? Card() : Image.network(
                    _opportunity.img,
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    alignment: Alignment.center,
                  ),
                  // Content
                  Container(
                    padding: EdgeInsets.all(10.0),
                    width: screenSize.width,
                    child: Text(
                      '${_opportunity.content}',
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    )
                  ),
                ],
              ),
            ),
            // Show interest action
            Container(
              width: screenSize.width,
              //color: Colors.blue,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text('Gostou desta oportunidade?'),
                  FlatButton(
                    child: Text(
                      'Demostrar Interesse', 
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () => _showInterest(_opportunity.id),
                  ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).accentColor,//Colors.pink[200],
            ),
            // List of interresed people
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Pessoas que já demonstraram interesse: '),
                    trailing: IconButton(
                      icon: Icon(
                        !_showInterested ? Icons.arrow_drop_down: Icons.arrow_drop_up,
                        size: 40.0,
                        //color: Theme.of(context).accentColor,
                      ),
                      onPressed: () => setState(() {_showInterested = !_showInterested;}),
                    ),
                  ),
                  !_showInterested ? Card() : StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('interest').where('opportunity', isEqualTo: widget._id).snapshots(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) return Container(
                                              width: MediaQuery.of(context).size.width/6,
                                              height: MediaQuery.of(context).size.height/6,
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(),
                                            );

                      return _buildInterestList(context, _opportunity.author, snapshot.data);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('opportunity').document(widget._id).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return _buildBody(context, snapshot.data);
      },
    );
  }

}