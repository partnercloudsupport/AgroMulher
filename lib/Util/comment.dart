import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String _id;
  String _post;
  String _author;
  String _content;
  bool _liked = false;

  Comment(this._post, this._author, this._content);

  Comment.fromMap(Map<String, dynamic> map, DocumentReference ref)
    : _id = ref.documentID,
      _author = map['author'],
      _content = map['content'],
      _post = map['postId'];

  Comment.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.reference);

  Map<String, dynamic> toMap(){
    Map entry = Map<String, dynamic>();
    entry['postId'] = _post;
    entry['author'] = _author;
    entry['content'] = _content;

    return entry;
  }

  void voteUp(){
    _liked = !_liked;
  }

  String get post => _post;
  String get id => _id;
  String get author => _author;
  String get content => _content;
  bool get liked => _liked;
}
