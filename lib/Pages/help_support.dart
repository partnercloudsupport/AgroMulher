import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupport extends StatelessWidget {
  
  final int index;

  const HelpSupport({Key key, this.index}) : super(key: key);

  _launchPortal() async {
  const url = 'http://www.agromulher.com.br';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Não foi possivel carregar o site $url';
  }
  }

  _launchPrivacity() async {
  const url = 'https://';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Não foi possivel carregar o site $url';
  }
}


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("AgroMulher"),
        ),
        body: Stack(
          fit: StackFit.expand,
            children: <Widget>[
              Image(
                image: AssetImage("Imgs/background.jpg"),
                fit: BoxFit.cover,
                color: Colors.black54,
                colorBlendMode: BlendMode.darken,
              ),
              new Theme(
                data: new ThemeData(
                  //brightness: Brightness.dark,
                  inputDecorationTheme: new InputDecorationTheme(
                    // hintStyle: new TextStyle(color: Colors.blue, fontSize: 20.0),
                    labelStyle: new TextStyle(color: Colors.black,),
                  )
                ),
                isMaterialAppTheme: true,
                child: Center(
                                  child: new ListView(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image(
                        image: new AssetImage("Imgs/logo.png"),
                        //fit: BoxFit.cover,
                        // width: 100.0,
                        height: 210.0,
                      ),
                      new Container(
                        color: Color.fromRGBO(200, 200, 200, 0.4),
                        padding: const EdgeInsets.all(40.0),
                        child: new Form(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: buildText()
                          )
                        )
                      )
                    ],
                  ),
                )
              )
            ],
      ),
      )
    );
  }
  List<Widget> buildText(){
    return [
      Text("Em caso de dúvidas, sugestões ou problemas reporte ao contato abaixo", textAlign: TextAlign.justify,style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
      Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Text("Rede Digital AgroMulher", textAlign: TextAlign.center, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w800),),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text("Email: agromulher2016@gmail.com", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text("Instagram: @agromulher", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text("Os dados disponibilizados são assegurados pela política de privacidade do nosso sistema!", textAlign: TextAlign.justify,style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
      ),
      FlatButton(
        child: Text("Portal: www.agromulher.com.br", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
        onPressed: _launchPortal,
      ),
      RawMaterialButton(
        shape: const StadiumBorder(),
        fillColor: Colors.pink,
        splashColor: Colors.pinkAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Política de Privacidade", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),),
        ),
        onPressed: _launchPrivacity,
      ),
    ];
  }
}