import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'Controllers/auth.dart';
import 'Controllers/auth_provider.dart';
import 'Pages/index.dart';


void main() {
  initializeDateFormatting('pt_BR', null).then((_) => runApp(new AgroMulher()));
} 

class AgroMulher extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        theme: new ThemeData(primaryColor: Colors.pink),
        home: new IndexPage(),
      )
    );
  }
}
