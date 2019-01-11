import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final String userId;
  final String src;
  final double size;
  
  ProfilePic({@required this.userId, this.src, this.size});

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        color: Colors.green[800],
        shape: BoxShape.circle,
        image: src == null || src == '' ? new DecorationImage(image: AssetImage('Imgs/profile.png')): new DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(src),
        ),
      )
    );
  }

}