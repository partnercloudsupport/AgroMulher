import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../UI/profile_pic.dart';
import '../Util/profile.dart';
import '../Controllers/auth_provider.dart';

class EditProfile extends StatefulWidget {
  final String _id;

  EditProfile(this._id);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  List _jobs = ['Engenheira Agrônoma', 'Zootecnista', 'Veterinária', 'Gestora rural', 'Gestora empresarial ',
                'Empreendedora', 'Executiva', 'Consultora', 'Estudante', 'Outra'];

  GlobalKey<FormState> _formKeyEdit = GlobalKey<FormState>();
  File _profPic;
  String _name;
  String _job;
  String _desc;
  String _country;
  String _state;
  String _city;

  Profile _user;
  int _isMentor;

  bool validateEdit(){
    final form = _formKeyEdit.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }
    
  Widget _buildBody(BuildContext context, String user){
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document(user).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return _buildProfile(context, snapshot.data);
      },
    );
  }
  
  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    if(image == null) return;

    image = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 160,
      maxHeight: 160,
    );

    setState(() {
      _profPic = image;
    });
  }

  List<DropdownMenuItem<String>> _getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String job in _jobs) {
      items.add(new DropdownMenuItem(
          value: job,
          child: new Text(job)
      ));
    }
    return items;
}

  void changedDropDownItem(String value) {
    setState(() {
      _job = value;
    });
}

  void _handleRadioValueChange(int value) {
    setState(() {
      _isMentor = value;
    });
  }

  void validadeAndSubmit() async{
    if(validateEdit()){
      final DocumentReference documentReference = Firestore.instance.collection("users").document("${_user.userId}");
      DocumentSnapshot snapshot = await documentReference.get();
      
      String img = snapshot.data['img'];

      Firestore.instance.runTransaction((Transaction transaction) async{
        Profile editProfile = Profile(_user.userId, _name, _job, _desc, _city, _state, _country, img, _isMentor == 0);
        DocumentSnapshot snapshot = await transaction.get(documentReference);

        if(_profPic != null) {
          StorageReference storage = FirebaseStorage.instance.ref().child('profile_pics').child('${_user.userId}.jpg');
          StorageTaskSnapshot task =  await storage.putFile(_profPic).onComplete;
          String url = await task.ref.getDownloadURL();
          await transaction.update(snapshot.reference, {'img': url});
          editProfile = Profile(_user.userId, _name, _job, _desc, _city, _state, _country, url, _isMentor == 0);
        }

        await transaction.update(snapshot.reference, editProfile.toMap());
      });

      Navigator.pop(context);
    }
  }

  Widget _buildProfile(BuildContext context, DocumentSnapshot data) {
    _user = Profile.fromSnapshot(data);

    if(_job == null) _job = _user.job;
    if(_isMentor == null) _isMentor = _user.isMentor ? 0 : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
        // backgroundColor: Colors.lightGreen,
        actions: <Widget>[
          FlatButton(
            child: Text("Salvar", style: TextStyle(fontSize: 20.0),),
            onPressed: validadeAndSubmit
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKeyEdit,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FlatButton(
                    child: _profPic != null ? Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: FileImage(_profPic),
                        ),
                      )
                    ) :
                    ProfilePic(
                      userId: widget._id,
                      src: _user.img,
                      size: 80.0,
                    ),
                    onPressed: () => _getImage(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome'),
                    initialValue: _user.name,
                    validator: (value) {
                      if(value.isEmpty){
                        return "Digite seu nome!";
                      } else {
                        _name = value;
                      }
                    },
                  ),
                  DropdownButton(
                    value: _job,
                    items: _getDropDownMenuItems(),
                    onChanged: changedDropDownItem,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Descrição', labelStyle: TextStyle(fontSize: 15.0)),
                    initialValue: _user.desc,
                    maxLines: 2,
                    onSaved: (value){
                      _desc = value;
                    }
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'País'),
                    initialValue: _user.country,
                    onSaved: (value){
                      _country = value;
                    }
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Estado'),
                    initialValue: _user.state,
                    onSaved: (value){
                      _state = value;
                    }
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Cidade'),
                    initialValue: _user.city,
                    onSaved: (value){
                      _city = value;
                    }
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: -10.0, vertical: 10.0),
                    title: Text('Deseja ser mentor?'),
                    subtitle: Row(
                      children: <Widget>[
                        Text("Sim"),
                        Radio(
                          value: 0,
                          groupValue: _isMentor,
                          onChanged: _handleRadioValueChange,
                        ),
                        Text("Não"),
                        Radio(
                          value: 1,
                          groupValue: _isMentor,
                          onChanged: _handleRadioValueChange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          )
        )
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    // _job = _user.job;
    // _radioValue = _user.isMentor ? 0 : 1;
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

        return widget._id == snapshot.data ? _buildBody(context, widget._id) : Scaffold(
          appBar: AppBar(
            title: Text('Editar Perfil'),
          ),
          body: _buildBody(context, widget._id)
        );
      },
    );   
  }
}