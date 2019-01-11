import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  String _id;
  String _author;
  DateTime _date;
  String _content;
  String _img;
  int _accessNumber;


  Opportunity(this._author, this._date, this._accessNumber, this._content, [this._img]);

  Opportunity.fromMap(Map<String, dynamic> map, DocumentReference ref)
    :  _id = ref.documentID,
      _author = map['author'],
      _date = map['date'],
      _content = map['content'],
      _img = map['img'],
      _accessNumber = map['accessNumber'];

  Opportunity.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.reference);

  Map<String, dynamic> toMap(){
    Map map = Map<String, dynamic>();

    map['author'] = _author;
    map['content'] = _content;
    map['accessNumber'] = _accessNumber;
    map['date'] = _date;
    map['img'] = _img;

    return map;
  }

  String get id => _id;
  String get author => _author;
  DateTime get date => _date;
  String get img => _img;
  String get content => _content;
  int get accessNumber => _accessNumber;
}