import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

/*
* This class shows app info:
* - Author
* - Goal
* - ...
* */


class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      drawer: DefaultDrawer(
        highlitedVoice: Voice.ABOUT,
      ),
      //backgroundColor: Color(0xFF333333),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.android),
                title: Text('Developed by Lorenzo Fiorani',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('github.com/lorenzodeveloper'),
              ),
              ListTile(
                title: Text(
                  '\n\nThis is a project with educational purposes only as it\'s the result of \"Mobile & Web Applications\" class.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                subtitle: Text(
                    '\n\nThere is no specific currency used in this app '
                        'so money is addressed as PGM = PiggyBank Money.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
