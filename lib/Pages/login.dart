import 'package:agro_mulher/Pages/select_job.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import '../Controllers/auth_provider.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;

  LoginPage({this.onSignedIn, this.onSignedOut});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType{
  login,
  register,
  recover
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FormType formType = FormType.login;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = new AnimationController(
      vsync: this, 
      duration: new Duration(milliseconds: 500)
    );

    _iconAnimation = new CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.bounceOut,
    );

    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();
  }

  @override
  void dispose(){
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _showLoading(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Aguarde um momento..."),
          content: Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            child: CircularProgressIndicator(backgroundColor: Colors.greenAccent,),
          ),
        );
      },
    );
  }

  void _showDialog(String titleErro, String erro) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("$titleErro"),
          content: new Text("$erro"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool validateLogin(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void validadeAndSubmit() async{
    if(validateLogin()){
      try{
        var auth = AuthProvider.of(context).auth;
          if (formType == FormType.login) {
            _showLoading();
            await auth.signInWithEmailAndPassword(emailController.text, passwordController.text).whenComplete(
              () => Navigator.of(context).pop()
            );
            widget.onSignedIn();
          } else if(formType == FormType.register) {
            _showLoading();
            String userId = await auth.createUserWithEmailAndPassword(emailController.text, passwordConfirmController.text);
            Firestore.instance.collection("users").document("$userId").get();
            final DocumentReference documentReference = Firestore.instance.collection("users").document("$userId");
            _add(nameController.text, "", documentReference);
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => JobSelect(userId, widget.onSignedOut)));
            // widget.onSignedIn();
          } else {
            FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
            _firebaseAuth.sendPasswordResetEmail(email: emailController.text).whenComplete(
              () {
                setState(() {
                  _showDialog("Vamos lá", "Acesse seu e-mail e recupere sua senha!");
                });
              }
            ).catchError(() {
              setState(() {
                _showDialog("Ops!", "Falha no envio do e-mail");
              });
            });
          }
      } on PlatformException catch (e){
        switch(e.message){
          case 'The password is invalid or the user does not have a password.':
            setState(() {
              _showDialog("Ops!", "Senha incorreta!");
            });
            break;
          case 'The given password is invalid. [ Password should be at least 6 characters ]':
            setState(() {
              _showDialog("Ops!", "Mínimo de 6 caracteres na senha!");
            });
          break;
          case 'The email address is already in use by another account.':
            setState(() {
              _showDialog("Ops!", "Já existe uma conta com esse e-mail!");
            });
          break;
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            setState(() {
              _showDialog("Ops!", "Esse usuário não existe em nosso banco de dados. Crie agora mesmo!");
            });
          break;
        }
        print("Erro ${e.message}");
      }
    }
  }

  void loginWithGoogle() async {
    _showLoading();
    try{
      var auth = AuthProvider.of(context).auth;
      FirebaseUser userGoogle = await auth.handleSignInGoogle();
      String userId = userGoogle.uid;
      final DocumentReference documentReference = Firestore.instance.collection("users").document("$userId");
      DocumentSnapshot snapshot = await documentReference.get();
      if(snapshot.data == null){
        _add(userGoogle.displayName, userGoogle.photoUrl, documentReference);
        userGoogle.sendEmailVerification();
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => JobSelect(userId, widget.onSignedOut)));
      } else {
        Navigator.of(context).pop();
        widget.onSignedIn(); 
      }
    } catch (e){
      Navigator.of(context).pop();
      setState(() {
        _showDialog("Erro", "Erro desconhecido!");
      });
    }
  }

  void loginWithFacebook() async {
    _showLoading();
    try{
      var auth = AuthProvider.of(context).auth;
      FirebaseUser userFacebook = await auth.handleSignInFacebook();
      String userId = userFacebook.uid;
      final DocumentReference documentReference = Firestore.instance.collection("users").document("$userId");
      DocumentSnapshot snapshot = await documentReference.get();
      if(snapshot.data == null){
        _add(userFacebook.displayName, userFacebook.photoUrl, documentReference);
        userFacebook.sendEmailVerification();
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => JobSelect(userId, widget.onSignedOut)));
      } else {
        Navigator.of(context).pop();
        widget.onSignedIn(); 
      }
    } catch (e){
      Navigator.of(context).pop();
      setState(() {
        _showDialog("Erro", "Erro desconhecido!");
      });
    }
  }

  void _add(String nome, String img, DocumentReference documentReference){
    Map<String, dynamic> data = <String, dynamic>{
      "name": "$nome",
      "job" : "",
      "desc" : "",
      "img" : img,
      "isMentor" : false,
      "city" : "",
      "state" : "",
      "country" : ""
    };
    documentReference.setData(data).whenComplete(() { 
      Navigator.of(context).pop();
      setState(() {
          _showDialog("Tudo certo!", "Confirme sua conta através do e-mail recebido!");
      });
    }).catchError(() {
      setState(() {
        _showDialog("Ops!", "Algo de errado não está certo :(");
      });
    });
  }

  void moveRegister(){
    _formKey.currentState.reset();

    setState(() {
      formType = FormType.register;
    });
  }

  void moveLogin(){
    _formKey.currentState.reset();  
    setState(() {
      formType = FormType.login;
    });
  }
  
  void moveRecover(){
    _formKey.currentState.reset();
    setState(() {
      formType = FormType.recover;
    });
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Image(
                image: new AssetImage("Imgs/background.jpg"),
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
                        key: _formKey,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: buildFields() + buildButtons()
                        )
                      )
                    )
                  ],
                )
              )
            ]
          ),
        )
    );
  }
  
  List<Widget> buildFields(){
    if(formType == FormType.login){
      return [
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
        new TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          controller: emailController,
          validator: (value) {
            String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regExp = new RegExp(p);
            if(value.isEmpty){
              return "Insira seu e-mail!";
            } else if(!regExp.hasMatch(value)){
              return "Formato inválido de e-mail!";
            }
          },
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Senha'),
          obscureText: true,
          controller: passwordController,
          validator: (value) {
            if(value.isEmpty){
              return "Insira sua senha!";
            }
          },
        ),
        new Padding(padding: EdgeInsets.all(2.0),)
      ];
    } else if(formType == FormType.register){
      return [
        new TextFormField(
          key: Key('nome'),
          decoration: InputDecoration(labelText: 'Nome'),
          controller: nameController,
          validator: (value) {
            if(value.isEmpty){
              return "Insira seu Nome!";
            }
          },
        ),
        new TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          controller: emailController,
          validator: (value) {
            String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regExp = new RegExp(p);
            if(value.isEmpty){
              return "Insira seu e-mail!";
            } else if(!regExp.hasMatch(value)){
              return "Formato inválido de e-mail!";
            }
          },
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Senha'),
          obscureText: true,
          controller: passwordController,
          validator: (value) {
            if(value.isEmpty){
              return "Insira sua senha!";
            }
          },
        ),
        new TextFormField(
          decoration: InputDecoration(labelText: 'Confirme sua senha'),
          obscureText: true,
          controller: passwordConfirmController,
          validator: (value) {
            if(value.isEmpty){
              return "Insira sua senha!";
            } else if(value != passwordController.text){
              return "Senhas não coincidem!";
            }
          },
        ),
        new Padding(padding: EdgeInsets.all(2.0),)
      ];
    } else {
      return [
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
        new TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          controller: emailController,
          validator: (value) {
            String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regExp = new RegExp(p);
            if(value.isEmpty){
              return "Insira seu e-mail!";
            } else if(!regExp.hasMatch(value)){
              return "Formato inválido de e-mail!";
            }
          },
        ),
        new Padding(padding: EdgeInsets.all(2.0),)
      ];
    }
  }

  List<Widget> buildButtons(){
    if(formType == FormType.login){
      return [
        // account login
        new RawMaterialButton(
          fillColor: Colors.pinkAccent,
          splashColor: Colors.pink,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max ,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text('Entrar', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: validadeAndSubmit,
        ),
        new Padding(padding: EdgeInsets.all(2.0)),
        
        // Google login
        new RawMaterialButton(
          fillColor: Colors.blue,
          splashColor: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(FontAwesomeIcons.google, size: 25.0, color: Colors.white,),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Entrar com Google', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: loginWithGoogle,
        ),
        new Padding(padding: EdgeInsets.all(2.0)),

        // Facebook login
        new RawMaterialButton(
          fillColor: Colors.blue[900],
          splashColor: Colors.blue[900],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(FontAwesomeIcons.facebook, size: 25.0, color: Colors.white,),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Entrar com Facebook', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: loginWithFacebook,
        ),
        new Padding(padding: EdgeInsets.all(2.0)),

        // Register
        new RawMaterialButton(
          fillColor: Colors.lightGreen,
          splashColor: Colors.green,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text('Criar conta', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: moveRegister,
        ),
        new FlatButton(
          child: Text('Esqueci minha senha', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
          shape: const StadiumBorder(),
          onPressed: () {
            moveRecover();
          },
        )
      ];
    } else if(formType == FormType.register){
      return [
        // Create account
        new RawMaterialButton(
          fillColor: Colors.pinkAccent,
          splashColor: Colors.pink,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(FontAwesomeIcons.addressCard, size: 25.0, color: Colors.white,),
                new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Criar conta', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: validadeAndSubmit,
        ),
        new Padding(padding: EdgeInsets.all(2.0)),

        // Back to login
        new RawMaterialButton(
          fillColor: Colors.lightGreen,
          splashColor: Colors.lightGreenAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.account_circle, size: 25.0, color: Colors.white,),
                new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Voltar e logar', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: moveLogin
        )
      ];
    } else {
      return [
        new RawMaterialButton(
          fillColor: Colors.pinkAccent,
          splashColor: Colors.pink,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(FontAwesomeIcons.addressCard, size: 25.0, color: Colors.white,),
                new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Recuperar conta', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: validadeAndSubmit,
        ),
        new Padding(padding: EdgeInsets.all(2.0)),

        // Back to login
        new RawMaterialButton(
          fillColor: Colors.lightGreen,
          splashColor: Colors.lightGreenAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.account_circle, size: 25.0, color: Colors.white,),
                new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                new Text('Voltar e logar', style: new TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold))
              ]
            )
          ),
          shape: const StadiumBorder(),
          onPressed: moveLogin
        )
      ];
    }
  }

}