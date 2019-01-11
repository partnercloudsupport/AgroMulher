import 'dart:io';

import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Util/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewPostState();
}

class NewPostState extends State<NewPost> {
  final inputControler = new TextEditingController();
  File _image;
  
  Future _showLoading(){
    return showDialog(
      context: context,
      barrierDismissible: false,
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

  void _writePost() async {
    if(inputControler.text == '')
      return;

    _showLoading();

    String user = await AuthProvider.of(context).auth.currentUser();

    Post newPost = Post(user, inputControler.text, '');
    CollectionReference refPost = Firestore.instance.collection('posts').reference();
    DocumentReference response = await refPost.add(newPost.toMap());

    if(_image != null){
      StorageReference storage = FirebaseStorage.instance.ref().child('post_imgs').child('${response.documentID}.jpg');
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
        title: Text('Nova Postagem'),
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
              hintText: 'O que deseja publicar?',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _writePost(),
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