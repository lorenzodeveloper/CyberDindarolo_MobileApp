/*
*
                    * */


import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/view/home_page.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_form_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';


/*
* This class is the piggybank form widget holder
* */

class PiggyBankFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert new Piggy bank'),
      ),
      drawer: DefaultDrawer(),
      body: BlocProvider(
        bloc: PiggyBankBloc(),
        child: PiggyBankForm(
          onFormSuccessfullyValidated: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage()));
          },
          onFormCancel: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage()));
          },
        ),
      ),
    );
  }

}