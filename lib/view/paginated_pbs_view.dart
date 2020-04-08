
import 'package:cyberdindaroloapp/blocs/paginated_pbs_bloc.dart';
import 'package:cyberdindaroloapp/widgets/piggybanks_listview_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

enum Choice { PIGGYBANKS, NOTIFICATIONS, HISTORY }

class PiggyBanksPage extends StatefulWidget {
  PiggyBanksPage({Key key}) : super(key: key);

  @override
  _PiggyBanksPageState createState() => _PiggyBanksPageState();
}

class _PiggyBanksPageState extends State<PiggyBanksPage> {
  PaginatedPiggyBanksBloc _bloc;
  Choice selectedChoice;

  @override
  void initState() {
    _bloc = PaginatedPiggyBanksBloc();
    selectedChoice = Choice.PIGGYBANKS;
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _chosenWidget() {
    switch (selectedChoice) {
      case Choice.PIGGYBANKS:
        return BlocProvider(
          bloc: _bloc,
          child: PiggyBankListView(),
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


