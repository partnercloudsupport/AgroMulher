import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../UI/post_card.dart';
import 'new_post.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  State createState() => new NewsFeedPageState();
}

class NewsFeedPageState extends State<NewsFeedPage> {
  
  Widget _buildBody(BuildContext context, QuerySnapshot data){
    Size screenSize = MediaQuery.of(context).size;

    List<String> postList = data.documents.map((data) => data.documentID).toList();

    return new Material(
      child: new Scaffold(
        body: Container(
          width: screenSize.width,
          height: screenSize.height,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            itemCount: postList.length,
            itemBuilder: (context, index) => PostCard(postList[index]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          mini: true,
          child: Icon(Icons.create, color: Colors.white, size: 20.0,),
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new NewPost())),
        ),
      ) 
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('posts').orderBy('postDate', descending: true).snapshots(),
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
