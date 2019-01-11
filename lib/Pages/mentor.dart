import 'package:agro_mulher/Pages/profile_page.dart';
import 'package:agro_mulher/UI/profile_pic.dart';
import 'package:agro_mulher/Util/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Mentor extends StatefulWidget {
  final String _job;
  final String _id;

  Mentor(this._job, this._id);

  @override
  _MentorState createState() => _MentorState();
}

class _MentorState extends State<Mentor> {
  final _searchControler = new TextEditingController();
  bool _viewSearch = false;

  Widget _buildSearch(BuildContext context, QuerySnapshot data, String search){
    List<DocumentSnapshot> _users = data.documents
      .where((data) {
        return data.data['name'].toLowerCase().contains(search.toLowerCase());
      }).toList();

    return _users.length == 0 ? Container(
        padding: EdgeInsets.all(20.0),
        child: Text('Sem resultados :(', textAlign: TextAlign.center,)
      ) : Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/2,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            shrinkWrap: true,
            // scrollDirection: Axis.horizontal,
            itemCount: _users.length,
            itemBuilder: (context, index) => _buildMentors(context, _users[index]),
          )
        ),
      );
  }

  Widget _buildMentors(BuildContext context, DocumentSnapshot data){
    Profile user = Profile.fromSnapshot(data);
    return Container(
      width: MediaQuery.of(context).size.width,
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
              trailing: Text(
                'Ver informações',
                style: TextStyle(
                  fontSize: 12.0
                )
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

  Widget _buildMentorList(BuildContext context, QuerySnapshot snapshot){
    // Faz uma baguncinha de leve
    snapshot.documents.shuffle();
    return Column(
      children: snapshot.documents
        .where((data) => data.documentID != widget._id)
        .map((data) => _buildMentors(context, data)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        // Search
        ListTile(
          title: TextField(
            decoration: InputDecoration(
              hintText: 'Procurar',
            ),
            controller: _searchControler,
          ),
          trailing: IconButton(
            icon: Icon(!_viewSearch ? Icons.search : Icons.close),
            onPressed: () => setState(() => _viewSearch = !_viewSearch),
          ),
        ),
        !_viewSearch ? Card() : StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Container(
                                    width: MediaQuery.of(context).size.width/10,
                                    height: MediaQuery.of(context).size.height/10,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  );

            return _buildSearch(context, snapshot.data, _searchControler.text);
          },
        ),
        // Title
        ListTile(
          title: Text('Lista de mentores na sua área', textAlign: TextAlign.center,),
        ),
        // List of mentors
        StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').where('job', isEqualTo: widget._job).where('isMentor', isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Container(
                                    width: MediaQuery.of(context).size.width/6,
                                    height: MediaQuery.of(context).size.height/6,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  );

            return _buildMentorList(context, snapshot.data);
          },
        )
      ],
    );
  }
}