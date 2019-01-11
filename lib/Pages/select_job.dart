import 'package:agro_mulher/Pages/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobSelect extends StatefulWidget {
  final String _userId;
  final VoidCallback _onSignedOut;

  JobSelect(this._userId, this._onSignedOut);

  @override
  _JobSelectState createState() => _JobSelectState();
}

class _JobSelectState extends State<JobSelect> {
  List<RadioModel> sampleData = new List<RadioModel>();
  int selected = -1;

  void _insertJob() async {
    if(selected == -1)
      return;
      
    DocumentReference ref = Firestore.instance.collection('users').document(widget._userId);
    DocumentSnapshot snapshot = await ref.get();
    
    Firestore.instance.runTransaction((Transaction transaction) async{
      await transaction.update(snapshot.reference, {'job' : sampleData[selected].text});
    });

    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => Menu(onSignedOut: widget._onSignedOut,)));
  }

  @override
  void initState() {
    super.initState();
    sampleData.add(new RadioModel(false, 'Engenheira Agrônoma'));
    sampleData.add(new RadioModel(false, 'Zootecnista'));
    sampleData.add(new RadioModel(false, 'Veterinária'));
    sampleData.add(new RadioModel(false, 'Gestora rural'));
    sampleData.add(new RadioModel(false, 'Gestora empresarial '));
    sampleData.add(new RadioModel(false, 'Empreendedora'));
    sampleData.add(new RadioModel(false, 'Executiva'));
    sampleData.add(new RadioModel(false, 'Consultora'));
    sampleData.add(new RadioModel(false, 'Estudante'));
    sampleData.add(new RadioModel(false, 'Outra'));
  }

  Widget _radioButton(BuildContext context, RadioModel _item) {
    return Container(
        margin: new EdgeInsets.all(15.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Container(
              height: 50.0,
              width: 50.0,
              decoration: new BoxDecoration(
                color: _item.isSelected ? Colors.green : Colors.transparent,
                border: new Border.all(
                  width: 1.0, 
                  color: _item.isSelected ? Colors.green : Colors.grey
                ),
                borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
              ),
            ),
            new Container(
              margin: new EdgeInsets.only(left: 10.0),
              child: new Text(
                _item.text,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            )
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image(
            image: new AssetImage("Imgs/background.jpg"),
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
          ListView(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.only(top: 10.0),
                title: Text(
                  'Selecione sua área de atuação',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontFamily: ,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height-150.0,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: sampleData.length,
                    // shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return new Card(
                        color: Colors.white.withAlpha(127),
                        // padding: EdgeInsets.all(10.0),
                        child: InkWell(
                          //highlightColor: Colors.red,
                          splashColor: Colors.green,
                          onTap: () {
                            setState(() {
                              sampleData.forEach((element) => element.isSelected = false);
                              sampleData[index].isSelected = true;
                              selected = index;
                            });
                          },
                          child: _radioButton(context, sampleData[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              FlatButton(
                child: Card(
                  color: Colors.green,                  
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                  ),
                ),
                onPressed: () => _insertJob(),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String text;

  RadioModel(this.isSelected, this.text);
}