import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Util/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../Util/post.dart';

import '../Pages/post_details.dart';

import 'profile_pic.dart';

class PostCard extends StatefulWidget {
  final String _id;
  final PostCardState _initial;

  void extend() => _initial.extend();

  PostCard(this._id) :
    _initial = new PostCardState();
    

  @override
  State<StatefulWidget> createState() => _initial;
}

class PostCardState extends State<PostCard>{
  bool _extended = false;
  
  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
  }

  // ****** ACTIONS ****** //
  void extend() => _extended = true;

  Future<DocumentReference> _createSocial(String id, String user) {
    CollectionReference refSocial = Firestore.instance.collection('social').reference();
    return refSocial.add({
      'postId': id,
      'uid': user,
      'liked': false,
      'disliked': false,
      'shared': false
    });
  }

  void _deletePost(String id) async {
    // delete comments
    QuerySnapshot comments = await Firestore.instance.collection('comments').where('postId', isEqualTo: id).getDocuments();
    for(int i=0; i < comments.documents.length; i++){
      Firestore.instance.collection('comments').document(comments.documents[i].documentID).delete();
    }

    // delete image
    StorageReference storage = FirebaseStorage.instance.ref().child('post_imgs').child(id+'.jpg');
    storage.delete();

    // delete social
    QuerySnapshot social = await Firestore.instance.collection('social').where('postId', isEqualTo: id).getDocuments();
    for(int i=0; i < social.documents.length; i++){
      Firestore.instance.collection('social').document(social.documents[i].documentID).delete();
    }
    
    // delete post
    Firestore.instance.collection('posts').document(id).delete(); 

    // back to homepage
    if(_extended)
      Navigator.of(context).pop();
  }

  void _like(bool state) async {
    var user = await AuthProvider.of(context).auth.currentUser();

    Firestore.instance.runTransaction((transaction) async {
      DocumentReference refPost = Firestore.instance.collection('posts').document(widget._id);

      final freshSnapshot = await transaction.get(refPost);
      Post post = Post.fromSnapshot(freshSnapshot);
      
      await transaction
        .update(refPost, {'likesNumber' : state ? post.likesNumber+1 : post.likesNumber-1});

      QuerySnapshot refSocialList = await Firestore.instance.collection('social')
                                        .where('postId', isEqualTo: widget._id)
                                        .where('uid', isEqualTo: user)
                                        .snapshots().first;
      
      DocumentReference refSocial = refSocialList.documents.isEmpty ? (await _createSocial(widget._id, user)) : refSocialList.documents[0].reference;
      
      await transaction
        .update(refSocial, {'liked' : state});
    });

  }

  void _dislike(bool state) async {
    var user = await AuthProvider.of(context).auth.currentUser();

    Firestore.instance.runTransaction((transaction) async {
      DocumentReference refPost = Firestore.instance.collection('posts').document(widget._id);

      final freshSnapshot = await transaction.get(refPost);
      Post post = Post.fromSnapshot(freshSnapshot);
      
      await transaction
        .update(refPost, {'dislikesNumber' : state ? post.dislikesNumber+1 : post.dislikesNumber-1});
      
      QuerySnapshot refSocialList = await Firestore.instance.collection('social')
                                        .where('postId', isEqualTo: widget._id)
                                        .where('uid', isEqualTo: user)
                                        .snapshots().first;
      
      DocumentReference refSocial = refSocialList.documents.isEmpty ? (await _createSocial(widget._id, user)) : refSocialList.documents[0].reference;

      await transaction
        .update(refSocial, {'disliked' : state});
    });
  }

  void _share(bool state) async {
    var user = await AuthProvider.of(context).auth.currentUser();

    Firestore.instance.runTransaction((transaction) async {
      DocumentReference refPost = Firestore.instance.collection('posts').document(widget._id);

      final freshSnapshot = await transaction.get(refPost);
      Post post = Post.fromSnapshot(freshSnapshot);
      
      await transaction
        .update(refPost, {'sharesNumber' : state ? post.sharesNumber+1 : post.sharesNumber-1});

      QuerySnapshot refSocialList = await Firestore.instance.collection('social')
                                        .where('postId', isEqualTo: widget._id)
                                        .where('uid', isEqualTo: user)
                                        .snapshots().first;
      
      DocumentReference refSocial = refSocialList.documents.isEmpty ? (await _createSocial(widget._id, user)) : refSocialList.documents[0].reference;

      await transaction
        .update(refSocial, {'shared' : state});
    });
  }

  // ****** BUILDERS ****** //
  Widget _buildAuthor(BuildContext context, DocumentSnapshot data, DateTime postDate) {
    Profile _author = Profile.fromSnapshot(data);

    return FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return ListTile(
          leading: ProfilePic(
            userId: _author.userId,
            size: 50.0,
            src: _author.img,
          ),
          title: Text(_author.name != null ? _author.name : 'unknow', style: TextStyle(fontSize: 12.0, color: Colors.black)),
          subtitle: Text(_author.job != null ? _author.job : 'unknow', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(postDate != null ? '${new DateFormat.yMd('pt_BR').add_Hm().format(postDate)}' : 'unknow', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
              snapshot.data != _author.userId ? Container() : Container(
                width: 25.0,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: IconButton(
                  iconSize: 14.0,
                  icon: Icon(Icons.close),
                  onPressed: () => _deletePost(widget._id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocial(BuildContext context, DocumentSnapshot social, Post post){
    if(social != null) {     
      post.liked = social.data['liked'];
      post.disliked = social.data['disliked'];
      //post.shared = social.data['shared'];
    }
    
    return ButtonTheme.bar(
      child: ButtonBar(
        mainAxisSize: MainAxisSize.min,
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          // like button
          FlatButton(
            child: Row(
              children: <Widget>[
                Text(post.likesNumber.toString() + "  ", style: TextStyle(color: post.liked ? Colors.green[900] : Theme.of(context).accentColor,)),
                Icon(Icons.thumb_up, color: post.liked ? Colors.green[900] : Theme.of(context).accentColor,),
              ],
            ),
            onPressed: () { 
              if(post.disliked) return;
              post.voteUp(); 
              _like(post.liked);
            },
          ),
          // dislike button
          FlatButton(
            child: Row(
              children: <Widget>[
                Text(post.dislikesNumber.toString() + "  ", style: TextStyle(color: post.disliked ? Colors.red : Theme.of(context).accentColor,)),
                Icon(Icons.thumb_down, color: post.disliked ? Colors.red : Theme.of(context).accentColor,),
              ],
            ),
            onPressed: () { 
              if(post.liked) return;

              post.voteDown();
              _dislike(post.disliked);
            },
          ),
          // comment button
          FlatButton(
            child: Row(
              children: <Widget>[
                Text(post.commentsNumber.toString() + "  "),
                Icon(Icons.comment),
              ],
            ),
            onPressed: () => _extended ? print('nothing') : Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new PostDetails(post.id))),
          ),
          // share button (temporally disabled)
          /*FlatButton(
            child: Row(
              children: <Widget>[
                Text(post.sharesNumber.toString() + "  "),
                Icon(Icons.share, color: post.shared ? Colors.pink : Theme.of(context).accentColor,),
              ],
            ),
            onPressed: () { post.share(); _share(post.shared);},
          ),
          */
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, DocumentSnapshot data){
    Post _post = Post.fromSnapshot(data);
  
    return new Container(
      //padding: EdgeInsets.all(5.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          // Header
          StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('users').document(_post.author).snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container(
                                      width: MediaQuery.of(context).size.width/6,
                                      height: MediaQuery.of(context).size.height/6,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    );

              return _buildAuthor(context, snapshot.data, _post.postDate);
            },
          ),
          // Body
          Container(
            //fit: FlexFit.loose,
            child: new InkWell(
              onTap: () => _extended ? print('nothing') : Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new PostDetails(_post.id))),
              child: Column(
                children: <Widget>[
                  Text(
                    _post.content,
                    maxLines: !_extended ? 5 : _post.content.length,
                    overflow: !_extended ? TextOverflow.ellipsis : null,
                  ),
                  _post.img == null || _post.img == '' ? Card() : _extended ? Container(
                    child: Image.network(
                      _post.img,
                      scale: 1.0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                  ) : Container(
                    child: Image.network(
                      _post.img,
                      scale: 1.0,
                      width: 320,
                      height: 320,
                      fit: BoxFit.cover
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                  ),
                ],
              )
            ),
          ),
         
          // Action buttons
          FutureBuilder(
            future: AuthProvider.of(context).auth.currentUser(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container(
                                      width: MediaQuery.of(context).size.width/6,
                                      height: MediaQuery.of(context).size.height/6,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    );

              return StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('social').where('uid', isEqualTo: snapshot.data).where('postId', isEqualTo: widget._id).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return Container(
                                          width: MediaQuery.of(context).size.width/6,
                                          height: MediaQuery.of(context).size.height/6,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(),
                                        );

                  if(snapshot.data.documents.length > 0)
                    return _buildSocial(context, snapshot.data.documents[0], _post);

                  return _buildSocial(context, null, _post);
                },
              );
            },
          ),
          Divider(
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('posts').document(widget._id).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return _buildPostCard(context, snapshot.data);
      },
    );
  }
}