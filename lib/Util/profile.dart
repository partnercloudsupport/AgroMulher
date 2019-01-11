import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String _userId;
  String _name;
  String _job;
  String _desc;
  String _city;
  String _state;
  String _country;
  String _img;
  bool _isMentor;

  Profile(this._userId, this._name, [this._job, this._desc, this._city, this._state, this._country, this._img, this._isMentor]);

  Profile.fromMap(Map<String, dynamic> map, DocumentReference ref)
    : assert(map['name'] != null),
      _userId = ref.documentID,
      _name = map['name'],
      _job = map['job'],
      _desc = map['desc'],
      _city = map['city'],
      _state = map['state'],
      _country = map['country'],
      _isMentor = map['isMentor'],
      _img = map['img'];

  Profile.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.reference);
  Map<String, dynamic> toMap(){
    Map map = Map<String, dynamic>();

    map['name'] = _name;
    map['job'] = _job;
    map['desc'] = _desc;
    map['city'] = _city;
    map['state'] = _state;
    map['country'] = _country;
    map['isMentor'] = _isMentor;
    map['img'] = _img;

    return map;
  }
  String get name => _name;
  String get userId => _userId;
  String get job => _job;
  String get desc => _desc;
  String get city => _city;
  String get state => _state;
  String get country =>_country;
  String get img =>_img;
  bool get isMentor => _isMentor;
}