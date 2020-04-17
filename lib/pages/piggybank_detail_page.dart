import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:cyberdindaroloapp/widgets/loading_widget.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_info_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
* This class prepare the piggybank info widget
*
*
* */

class PiggyBankDetailPage extends StatefulWidget {
  final int selectedPiggybank;

  const PiggyBankDetailPage(this.selectedPiggybank);

  @override
  _PiggyBankDetailPageState createState() => _PiggyBankDetailPageState();
}

class _PiggyBankDetailPageState extends State<PiggyBankDetailPage> {
  PiggyBankBloc _piggyBankBloc;

  @override
  void initState() {
    super.initState();
    _piggyBankBloc = BlocProvider.of<PiggyBankBloc>(context);
    _piggyBankBloc.fetchPiggyBank(widget.selectedPiggybank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('PiggyBank Info',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(),
      //backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () =>
            _piggyBankBloc.fetchPiggyBank(widget.selectedPiggybank),
        child: StreamBuilder<Response<PiggyBankModel>>(
          stream: _piggyBankBloc.pbListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return new PiggyBankInfoWidget(
                      piggyBankInstance: snapshot.data.data);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () =>
                        _piggyBankBloc.fetchPiggyBank(widget.selectedPiggybank),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    //_piggyBankBloc.dispose();
    super.dispose();
  }
}
