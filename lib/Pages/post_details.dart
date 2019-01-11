import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Util/post.dart';
import 'package:agro_mulher/Util/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Util/comment.dart';

import '../UI/profile_pic.dart';
import '../UI/post_card.dart';

class PostDetails extends StatefulWidget {
  final String _id;
  
  PostDetails(this._id);

  @override
  State<StatefulWidget> createState() => new PostDetailsState();
}

class PostDetailsState extends State<PostDetails> {
  final _inputControl = new TextEditingController();
  final _inputFocus = FocusNode();

  // ****** ACTIONS ****** //
  void _writeComment(BuildContext context, String postId, String text) async {
    if(text == '')
      return;

    var user = await AuthProvider.of(context).auth.currentUser();
    CollectionReference ref = Firestore.instance.collection('comments').reference();
  
    Comment newComment = Comment(postId, user, text);

    Firestore.instance.runTransaction((transaction) async {
      DocumentReference refPost = Firestore.instance.collection('posts').document(postId);

      final freshSnapshot = await transaction.get(refPost);
      Post post = Post.fromSnapshot(freshSnapshot);
      
      await transaction
        .update(refPost, {'commentsNumber' : post.commentsNumber+1});
      
      await ref
        .add(newComment.toMap());
    });

    _inputControl.clear();
    //_inputControl.dispose();
  }

  void _deleteComment(BuildContext context, Comment comment) async {
    var user = await AuthProvider.of(context).auth.currentUser();

    if(user != comment.author){
      print('Only the author can exclude the comment');
      return;
    }

    Firestore.instance.runTransaction((transaction) async {
      DocumentReference ref = Firestore.instance.collection('posts').document(comment.post);

      final freshSnapshot = await transaction.get(ref);
      Post post = Post.fromSnapshot(freshSnapshot);
      
      await transaction
        .update(ref, {'commentsNumber' : post.commentsNumber-1});
    });

    Firestore.instance.collection('comments').document(comment.id).delete();      
  }
  
  // ****** BUILDERS ****** //
  Widget _buildAuthor(BuildContext context, DocumentSnapshot data){
    Comment _comment = Comment.fromSnapshot(data);

    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document(_comment.author).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
        return _buildCommentCard(context, _comment, snapshot.data);
      },
    );
  }

  Widget _buildCommentCard(BuildContext context, Comment comment, DocumentSnapshot data){
    Profile author = Profile.fromSnapshot(data);

    return new Container(
      child: new Column(
        children: <Widget>[
          ListTile(
            leading: ProfilePic(
              src: author.img,
              userId: author.userId,
              size: 35.0,
            ),
            title: new Text(author.name, style: TextStyle(fontSize: 12.0),),
            subtitle: new Text(comment.content, style: TextStyle(fontSize: 14.0),),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Like comment temporally disabled
                /* IconButton( 
                  iconSize: 20.0,
                  icon: Icon(Icons.thumb_up, color: comment.liked ? Colors.green : Theme.of(context).accentColor, size: 20.0,),
                  onPressed: () => setState(() { comment.voteUp();}),
                ), */
                IconButton(
                  icon: Icon(Icons.close, size: 20.0,),
                  onPressed: () => _deleteComment(context, comment),
                )
              ],
            )
          ),
        ],
      ),  
    );
  }

  Widget _buildCommentList(BuildContext context, List<DocumentSnapshot> comments){
    return new Column(
      children: comments.map((data) => _buildAuthor(context, data)).toList(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    PostCard card = new PostCard(widget._id);
    card.extend();

    return new Scaffold(
      appBar: AppBar(
        title: Text('Postagem')
      ),
      body: ListView(
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        children: <Widget>[
          // Post body
          card,
          // Comments section
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('comments').where('postId', isEqualTo: widget._id).snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container(
                                      width: MediaQuery.of(context).size.width/6,
                                      height: MediaQuery.of(context).size.height/6,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    );

              return _buildCommentList(context, snapshot.data.documents);
            },
          ),
          // Comment input
          Container(
            child: new TextField(
              autocorrect: true,
              controller: _inputControl,
              decoration: InputDecoration(
                hintText: 'Insira seu comentário',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _writeComment(context, widget._id, _inputControl.text),
                ),
              ),
              focusNode: _inputFocus,
            ),
          ),
        ],
      ),
    );
  }

}