import 'package:agro_mulher/Util/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../Pages/maket_opportunity.dart';

import '../Util/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  final String _id;
  
  OpportunityCard(this._id){
    initializeDateFormatting();
  }

  Widget _buildAuthor(BuildContext context, DocumentSnapshot data, DateTime date){
    Profile author = Profile.fromSnapshot(data);

    return Container(
      width: 150.0,
      padding: EdgeInsets.only(bottom: 10.0),
      //alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Por: ${author.name}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0, 
            ),
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
          Text(
            'Em: ${new DateFormat.yMd('pt_BR').add_Hm().format(date)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0, 
            ),
          ),
        ],
      ),  
    );
  }

  Widget _buildCard(BuildContext context, DocumentSnapshot data){
    Opportunity _opportunity = Opportunity.fromSnapshot(data);

    return new Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: FlatButton(
            child: Column(
              children: <Widget>[
                // Author info
                StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection('users').document(_opportunity.author).snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container(
                                            width: MediaQuery.of(context).size.width/6,
                                            height: MediaQuery.of(context).size.height/6,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );

                    return _buildAuthor(context, snapshot.data, _opportunity.date);
                  },
                ),
                // Image
                _opportunity.img == null || _opportunity.img == '' ? Card() : Container(
                  child: Image.network(
                    _opportunity.img,
                    scale: 1.0,
                    width: 100.0,
                    height: 140.0,
                    fit: BoxFit.cover,
                  ),
                  padding: EdgeInsets.only(bottom: 10.0),
                ),
                // Button
              ],
            ),
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MarketOpportunity(_id))),
          ),
        ),
        Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('opportunity').document(_id).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/6,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );

        return _buildCard(context, snapshot.data);
      },
    );
  }

}