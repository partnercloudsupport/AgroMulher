import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  // Details
  String _id;
  String _author;
  DateTime _postDate;
  String _content;
  String _img;
  
  // Social
  int _likesNumber = 0;
  int _dislikesNumber = 0;
  int _sharesNumber = 0;
  int _commentsNumber = 0;

  // Status
  bool _liked = false;
  bool _disliked = false;
  bool _shared = false;

  Post(this._author, this._content, [this._img])
    : _postDate = DateTime.now();

  Post.fromMap(Map<String, dynamic> map, DocumentReference ref)
    :  _id = ref.documentID,
      _author = map['author'],
      _postDate = map['postDate'],
      _content = map['content'],
      _likesNumber = map['likesNumber'],
      _dislikesNumber = map['dislikesNumber'],
      _commentsNumber = map['commentsNumber'],
      _sharesNumber = map['sharesNumber'],
      _img = map['img'];

  Post.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.reference);

  Map<String, dynamic> toMap(){
    Map map = Map<String, dynamic>();

    map['author'] = _author;
    map['postDate'] = _postDate;
    map['content'] = _content;
    map['likesNumber'] = _likesNumber;
    map['dislikesNumber'] = _dislikesNumber;
    map['commentsNumber'] = _commentsNumber;
    map['sharesNumber'] = _sharesNumber;
    map['img'] = _img;

    return map;
  }

  set liked(like) => _liked = like; 
  set disliked(dislike) => _disliked = dislike; 
  set shared(share) => _shared = share; 
  
  void voteUp() => _liked = !_liked;
  void voteDown() => _disliked = !_disliked;
  void share() => _shared = !_shared;

  void addComent() => _commentsNumber++;
  void deleteComment() => _commentsNumber--;

  String get id => _id;
  String get author => _author;
  DateTime get postDate => _postDate;
  String get content => _content;
  String get img => _img;

  int get likesNumber => _likesNumber;
  int get dislikesNumber => _dislikesNumber;
  int get sharesNumber => _sharesNumber;
  int get commentsNumber => _commentsNumber;

  bool get liked => _liked;
  bool get disliked => _disliked;
  bool get shared => _shared; 
}