import 'package:agro_mulher/Controllers/auth_provider.dart';
import 'package:agro_mulher/Pages/new_opportunity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../UI/opportunity_card.dart';

class MarketPlace extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new MarketPlaceState();
}

class MarketPlaceState extends State<MarketPlace>{
  final _searchControler = new TextEditingController();
  bool _viewSearch = false;

  bool _viewHighlight = false;
  bool _viewDirected = false;
  bool _viewYours = false;
  
  void dispose(){
    _searchControler.dispose();
    super.dispose();
  }
  
  Widget _buildSearch(BuildContext context, QuerySnapshot data, String search){
    List<String> _highlights = data.documents
      .where((data) {
        return data.data['content'].toLowerCase().contains(search.toLowerCase());
      })                             
      .map((data) {
        return data.documentID;
      })
      .toList();

    return _highlights.length == 0 ? Container(
      padding: EdgeInsets.all(20.0),
      child: Text('Sem resultados :(', textAlign: TextAlign.center,),
    ) : Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/2,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          shrinkWrap: true,
          // scrollDirection: Axis.horizontal,
          itemCount: _highlights.length,
          itemBuilder: (context, index) => OpportunityCard(_highlights[index]),
        )
      ),
    );
  }

  Widget _buildHighlights(BuildContext context, QuerySnapshot data){
    List<String> _highlights = data.documents.map((data) => data.documentID).toList();

    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/2,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          shrinkWrap: true,
          // scrollDirection: Axis.horizontal,
          itemCount: _highlights.length,
          itemBuilder: (context, index) => OpportunityCard(_highlights[index]),
        )
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthProvider.of(context).auth.currentUser(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container(
                                              width: MediaQuery.of(context).size.width/6,
                                              height: MediaQuery.of(context).size.height/6,
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(),
                                            );

        return new Scaffold(
          body: ListView(
              children: <Widget>[
                // Search
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      hintText: 'Procurar',
                    ),
                    controller: _searchControler,
                  ),
                  trailing: IconButton(
                    icon: Icon(!_viewSearch ? Icons.search : Icons.close),
                    onPressed: () => setState(() => _viewSearch = !_viewSearch),
                  ),
                ),
                !_viewSearch ? Card() : StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('opportunity').where('content').snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container(
                                            width: MediaQuery.of(context).size.width/10,
                                            height: MediaQuery.of(context).size.height/10,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );

                    return _buildSearch(context, snapshot.data, _searchControler.text);
                  },
                ),
                // Highlights area
                ListTile(
                  title: Text('Em destaque', style: TextStyle(),),
                  leading: Icon(Icons.star_border, color: Colors.black),
                  trailing: IconButton(
                    icon: Icon(!_viewHighlight ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                    onPressed: () => setState(() => _viewHighlight = !_viewHighlight),
                  ),
                ),
                !_viewHighlight ? Card() : StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('opportunity').snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container(
                                            width: MediaQuery.of(context).size.width/10,
                                            height: MediaQuery.of(context).size.height/10,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );

                    return _buildHighlights(context, snapshot.data);
                  },
                ),
                // Directed area
                /*ListTile(
                  title: Text('Pra você', style: TextStyle(),),
                  leading: Icon(Icons.person_pin_circle, color: Colors.black),
                  trailing: IconButton(
                    icon: Icon(!_viewDirected ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                    onPressed: () => setState(() => _viewDirected = !_viewDirected),
                  ),
                ),
                !_viewDirected ? Card() : StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('opportunity').snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container(
                                            width: MediaQuery.of(context).size.width/10,
                                            height: MediaQuery.of(context).size.height/10,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );

                    return _buildHighlights(context, snapshot.data);
                  },
                ),*/
                // Creted by you
                ListTile(
                  title: Text('Criadas por você', style: TextStyle(),),
                  leading: Icon(Icons.create_new_folder, color: Colors.black),
                  trailing: IconButton(
                    icon: Icon(!_viewYours ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                    onPressed: () => setState(() => _viewYours = !_viewYours),
                  ),
                ),
                !_viewYours ? Card() : StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('opportunity').where('author', isEqualTo: snapshot.data).snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container(
                                            width: MediaQuery.of(context).size.width/10,
                                            height: MediaQuery.of(context).size.height/10,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );

                    return _buildHighlights(context, snapshot.data);
                  },
                ),
              ],
          ),
          floatingActionButton: FloatingActionButton(
            mini: true,
            child: Icon(Icons.create, color: Colors.white, size: 20.0,),
            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new NewOpportunity())),
          ),
        );
      },
    );
  }
}