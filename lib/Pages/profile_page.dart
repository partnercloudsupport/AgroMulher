import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';
import '../Util/profile.dart';
import '../UI/profile_pic.dart';

class ProfileView extends StatefulWidget {
  final String _id;

  ProfileView(this._id);

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  bool _showSocial = false;
  bool _showAcademic = false;
  bool _showProfessional = false;

  TextEditingController _newCampName;
  TextEditingController _newCampDesc;

  // ****** ACTIONS ****** //
  void _deleteContent(BuildContext context, String id, String type) async {
    DocumentReference ref;
    switch(type){
      case 'Social':
        ref = Firestore.instance.collection('socialNetworks').document(id);
        break;
      case 'Experiência':
        ref = Firestore.instance.collection('professional').document(id);
        break;
      case 'Formação acadêmica':
        ref = Firestore.instance.collection('academic').document(id);
        break;
      default:
        return;
    }

    await ref.delete();
  }
  
  void _addContent(BuildContext context, String type, String id) async {

    if(_newCampDesc.text == '' || _newCampName.text == '')
      return;

    CollectionReference ref;
    switch(type){
      case 'Social':
        ref = Firestore.instance.collection('socialNetworks').reference();
        break;
      case 'Experiência':
        ref = Firestore.instance.collection('professional').reference();
        break;
      case 'Formação acadêmica':
        ref = Firestore.instance.collection('academic').reference();
        break;
      default:
        return;
    }

    ref.add({
      'uid' : id,
      'name' : _newCampName.text,
      'desc' : _newCampDesc.text
    });

    // remove popup
    Navigator.of(context).pop();
  }

  @override
  void dispose(){
    super.dispose();

    // clear inputs
    _newCampDesc.dispose();
    _newCampName.dispose();
  }

  void _showDialog(BuildContext contex, String type, String curUser) {
    _newCampName = new TextEditingController();
    _newCampDesc = new TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(type),
          content: Form(
            child: ListView(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Nome'),
                  controller: _newCampName,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descrição'),
                  controller: _newCampDesc,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () => _addContent(context, type, curUser),
            ),
            FlatButton(
              child: new Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  // ****** BUILDERS ****** //
  Widget _buildBody(BuildContext context, String user, String curUser){
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document(user).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return _buildProfile(context, snapshot.data, curUser);
      },
    );
  }

  Widget _buildCard(BuildContext context, DocumentSnapshot doc, String type){
    Size screenSize = MediaQuery.of(context).size;
    return  Container(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 1.5, right: 1.5),
            child: Text(doc.data['name'], style: TextStyle(fontSize: 14.0, color: Colors.black),),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: screenSize.width/1.5,
                child: Text(doc.data['desc'], style: TextStyle(fontSize: 14.0, color: Colors.grey),),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _deleteContent(context, doc.documentID, type)
              ),
            ],
          ),
          Divider(color: Colors.grey,)
        ],
      ),
    ); 
  }

  Widget _buildList(BuildContext context, QuerySnapshot data, String type){
    return Column(
      children: data.documents.map((data) => _buildCard(context, data, type)).toList()
    );
  }

  Widget _buildProfile(BuildContext context, DocumentSnapshot data, String curUser){
    final _user = Profile.fromSnapshot(data);
    Size screenSize = MediaQuery.of(context).size;

    return new ListView(
      children: <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    ProfilePic(
                      userId: _user.userId,
                      size: screenSize.width/5,
                      src: _user.img,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 150.0,
                              child: Text(
                              '${_user.name}',
                                style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Job
                            Container(
                              width: 150.0,
                              child: Text(
                                '${_user.job}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // Local
                            Container(
                              width: 150.0,
                              child: Text(
                                '${_user.city}, ${_user.state}, ${_user.country}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                        ),
                        _user.userId != curUser ? Card() : Container(
                          width: 50.0,
                          child: FlatButton(
                            child: Icon(Icons.edit),
                            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => EditProfile(_user.userId))),
                          ),
                        )
                      ] 
                    )
                  ],
                ),
              ),
              _user.userId != curUser || !_user.isMentor ? Card() : Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Você é um mentor, parabéns!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.green
                  ),
                ),
              ),
              // Social
                // Header
              ListTile(
                leading: CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.grey[800],
                  child:  Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                title: Text(
                  'Social'
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon( _showSocial ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                      onPressed: () => setState((){ _showSocial = !_showSocial; }),
                    ),
                    _user.userId != curUser ? Card() : IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _showDialog(context, 'Social', curUser),
                    )
                  ],
                )
              ),
                // Content
              !_showSocial ? Card() : StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('socialNetworks').where('uid', isEqualTo: _user.userId).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

                  return _buildList(context, snapshot.data, 'Social');
                },
              ),
              // Professional
                // Header
              ListTile(
                leading: CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.grey[800],
                  child:  Icon(
                    Icons.work,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                title: Text(
                  'Experiência'
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon( _showProfessional ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                      onPressed: () => setState((){ _showProfessional = !_showProfessional; }),
                    ),
                    _user.userId != curUser ? Card() : IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () =>_showDialog(context, 'Experiência', curUser),
                    )
                  ],
                ) 
              ),
              !_showProfessional ? Card() :  StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('professional').where('uid', isEqualTo: _user.userId).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

                  return _buildList(context, snapshot.data, 'Experiência');
                },
              ),
              // Academic
                // Header
              ListTile(
                leading: CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.grey[800],
                  child:  Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                title: Text(
                  'Formação acadêmica'
                ),
                trailing:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon( _showAcademic ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                      onPressed: () => setState((){ _showAcademic = !_showAcademic; }),
                    ),
                    _user.userId != curUser ? Card() : IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _showDialog(context, 'Formação acadêmica', curUser),
                    )
                  ],
                )
              ),
              !_showAcademic ? Card() :  StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('academic').where('uid', isEqualTo: _user.userId).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

                  return _buildList(context, snapshot.data, 'Formação acadêmica');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {    
    return FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return widget._id == snapshot.data ? _buildBody(context, widget._id, snapshot.data) : 
        Scaffold(
          appBar: AppBar(
            title: Text('Perfil'),
          ),
          body: _buildBody(context, widget._id, snapshot.data)
        );
      },
    );
     
  }
}