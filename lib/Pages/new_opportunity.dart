import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Util/opportunity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewOpportunity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewOpportunityState();
}

class NewOpportunityState extends State<NewOpportunity> {
  final inputControler = new TextEditingController();
  
  var _image;

  void _showLoading(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Aguarde um momento..."),
          content: Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            child: CircularProgressIndicator(backgroundColor: Colors.greenAccent,),
          ),
        );
      },
    );
  }

  void _writeOpportunity(BuildContext contex) async {
    if(inputControler.text == '')
      return;

    if(_image == null) {
      showDialog(
        context: contex,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Alerta'),
            content: Text('Insira uma imagem'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        }
      );

      return;
    }

    _showLoading();

    String user = await AuthProvider.of(context).auth.currentUser();
    Opportunity newOpportunity = Opportunity(user, DateTime.now(), 0, inputControler.text);

    CollectionReference ref = Firestore.instance.collection('opportunity').reference();
    DocumentReference response = await ref.add(newOpportunity.toMap());

    if(_image != null){
      StorageReference storage = FirebaseStorage.instance.ref().child('opportunity_imgs').child('${response.documentID}.jpg');
      StorageTaskSnapshot task =  await storage.putFile(_image).onComplete;

      String url = await task.ref.getDownloadURL();
      await response.updateData({'img': url});
    }

    // loading pop
    Navigator.of(context, rootNavigator: true).pop();

    if(response != null)
      Navigator.of(context).pop();

  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Nova Oportunidade'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          TextField(
            autocorrect: true,
            autofocus: true,
            controller: inputControler,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Descreva a oportunidade',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _writeOpportunity(context),
              ),
            ),
            maxLines: 5,
          ),
          _image == null ?
          FlatButton(
            child: Text('Inserir imagem'),
            onPressed: () => _getImage(),
          ) :
          Container(
            padding: EdgeInsets.all(10.0),
            child: Image.file(
              _image,
              width: MediaQuery.of(context).size.width-20.0,
            ),
          )
        ],
      ),
    );
  }

}