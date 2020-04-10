import 'package:cyberdindaroloapp/blocs/paginated_piggybanks_bloc.dart';
import 'package:cyberdindaroloapp/view/piggybank_form_page.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_form_widget.dart';
import 'package:cyberdindaroloapp/widgets/piggybanks_listview_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

enum Choice { PIGGYBANKS, NOTIFICATIONS, HISTORY }

class PiggyBanksListPage extends StatefulWidget {
  PiggyBanksListPage({Key key}) : super(key: key);

  @override
  _PiggyBanksListPageState createState() => _PiggyBanksListPageState();
}

class _PiggyBanksListPageState extends State<PiggyBanksListPage> {
  PaginatedPiggyBanksBloc _paginatedPiggyBanksBloc;
  Choice selectedChoice;

  @override
  void initState() {
    _paginatedPiggyBanksBloc = PaginatedPiggyBanksBloc();
    selectedChoice = Choice.PIGGYBANKS;
    super.initState();
  }

  @override
  void dispose() {
    _paginatedPiggyBanksBloc.dispose();
    super.dispose();
  }

  Widget _chosenWidget() {
    switch (selectedChoice) {
      case Choice.PIGGYBANKS:
        return BlocProvider(
          bloc: _paginatedPiggyBanksBloc,
          child: PiggyBanksListViewWidget(),
        );
        break;
      case Choice.NOTIFICATIONS:
        // TODO: Handle NOTIFICATIONS case.
        break;
      case Choice.HISTORY:
        // TODO: Handle HISTORY case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PiggyBankFormPage()));
          },
        ),
        appBar: AppBar(
          title: const Text('PiggyBanks'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.android),
              color: selectedChoice == Choice.PIGGYBANKS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showPiggyBanks(),
            ),
            IconButton(
              icon: selectedChoice == Choice.NOTIFICATIONS
                  ? Icon(Icons.notifications)
                  : Icon(Icons.notifications_none),
              color: selectedChoice == Choice.NOTIFICATIONS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showNotifications(),
            ),
            IconButton(
              icon: Icon(Icons.history),
              color: selectedChoice == Choice.HISTORY
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showMovementsHistory(),
            ),
          ],
        ),
        drawer: DefaultDrawer(
          highlitedVoice: Voice.PIGGYBANKS,
        ),
        body: _chosenWidget(),
        resizeToAvoidBottomInset: false);
  }

  _showNotifications() {
    setState(() {
      selectedChoice = Choice.NOTIFICATIONS;
    });
  }

  _showPiggyBanks() {
    setState(() {
      selectedChoice = Choice.PIGGYBANKS;
    });
  }

  _showMovementsHistory() {
    setState(() {
      selectedChoice = Choice.HISTORY;
    });
  }
}
