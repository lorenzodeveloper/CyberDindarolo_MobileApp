import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/pages/home_page.dart';
import 'package:cyberdindaroloapp/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: UserSessionBloc(),
        child: BlocProvider(
          bloc: PiggyBankBloc(),
          child: MaterialApp(
            title: 'CyberDindarolo',
            initialRoute: '/',
            routes: {
              '/': (BuildContext context) => LoginPage(),
              '/home': (BuildContext context) => HomePage(),
            },
          ),
        ));
  }
}
