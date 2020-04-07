import 'package:cyberdindaroloapp/blocs/credit_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated_participants_bloc.dart';
import 'package:cyberdindaroloapp/blocs/pb_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated_participants_model.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:cyberdindaroloapp/widgets/loading_widget.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../validators.dart';

class PiggyBankInfoPage extends StatefulWidget {
  final int selectedPiggybank;

  const PiggyBankInfoPage(this.selectedPiggybank);

  @override
  _PiggyBankInfoPageState createState() => _PiggyBankInfoPageState();
}

class _PiggyBankInfoPageState extends State<PiggyBankInfoPage> {
  PiggyBankBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PiggyBankBloc(widget.selectedPiggybank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('PiggyBank Info',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(),
      //backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchPiggyBank(widget.selectedPiggybank),
        child: StreamBuilder<Response<PiggyBankModel>>(
          stream: _bloc.pbListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return PiggyBankWidget(piggyBank: snapshot.data.data);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () =>
                        _bloc.fetchPiggyBank(widget.selectedPiggybank),
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
    _bloc.dispose();
    super.dispose();
  }
}

class PiggyBankWidget extends StatefulWidget {
  final PiggyBankModel piggyBank;

  PiggyBankWidget({@required this.piggyBank});

  @override
  _PiggyBankWidgetState createState() {
    return _PiggyBankWidgetState();
  }
}

enum Operation { INFO_VIEW, EDIT_VIEW }

// Define a corresponding State class.
// This class holds data related to the form.
class _PiggyBankWidgetState extends State<PiggyBankWidget> {
  final _formKey = GlobalKey<FormState>();

  Operation _operation;

  final unameController = TextEditingController(text: "lorenzo_lamas123");
  final pwdController = TextEditingController(text: "prova1234");
  PaginatedParticipantsBloc _paginatedParticipantsBloc;
  CreditBloc _creditBloc;

  @override
  void initState() {
    super.initState();
    _operation = Operation.INFO_VIEW;
    _paginatedParticipantsBloc = new PaginatedParticipantsBloc();
    _creditBloc = new CreditBloc();

    _paginatedParticipantsBloc.fetchUsersData(piggybank: widget.piggyBank.id);
    _creditBloc.getCredit(piggybank: widget.piggyBank.id);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unameController.dispose();
    pwdController.dispose();

    super.dispose();
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              // Username field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: usernameValidator,
                decoration: InputDecoration(labelText: 'Enter your username'),
                //controller: unameController,
              ),
              // Pwd field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: passwordValidator,
                decoration: InputDecoration(labelText: 'Enter your password'),
                obscureText: true,
                //controller: pwdController,
              ),

              RaisedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {}
                },
                child: Text('Ciao bell'),
              ),
            ])));
  }

  Widget _buildInfoView() {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        // PiggyBank Header: Name, Desc, Credit
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
            Widget>[
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  child: Image(
                    image: AssetImage('assets/images/pink_pig.png'),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.piggyBank.pbName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                    widget.piggyBank.pbDescription == null
                        ? 'No Description'
                        : widget.piggyBank.pbDescription,
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                _getCreditWidget(),
              ],
            ),
          ),
        ]),
        Divider(),
        // Participants overview
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                _getParticipantsOverviewWidget(),
              ],
            ),
            Column(children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                // TODO: REINDIRIZZAMENTO A PAGINA PARTECIPANTI
                onPressed: () =>
                    print('REINDIRIZZAMENTO A PAGINA DEI PARTECIPANTI'),
              ),
            ]),
          ],
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    switch (_operation) {
      case Operation.INFO_VIEW:
        // TODO: Handle this case.
        return _buildInfoView();
        break;
      case Operation.EDIT_VIEW:
        return _buildForm();
        break;
    }
  }

  _getCreditWidget() {
    return StreamBuilder<Response<Decimal>>(
      stream: _creditBloc.creditStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.data);
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Text(
                '${snapshot.data.data.toString()} PGM',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.lightBlueAccent),
              );
              break;
            case Status.ERROR:
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () => _creditBloc.getCredit(
                    piggybank: widget.piggyBank.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }

  _getParticipantsOverviewWidget() {
    return StreamBuilder<Response<PaginatedParticipantsModel>>(
      stream: _paginatedParticipantsBloc.pagParticipantsListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Text(
                  'You and ${snapshot.data.data.count - 1} other users');
              break;
            case Status.ERROR:
              print(snapshot.data.message);
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () => _paginatedParticipantsBloc
                    .fetchUsersData(piggybank: widget.piggyBank.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }
}

/*
class PiggyBankWidget extends StatelessWidget {
  final PiggyBankModel piggyBank;

  const PiggyBankWidget({Key key, this.piggyBank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        constraints: new BoxConstraints.expand(),
        color: Colors.lightBlueAccent, //new Color(0xFF736AB7),
        child: new Stack(
          children: <Widget>[
            _getBackground(),
            _getGradient(context),
            _getContent(),
          ],
        ),
      ),
    );
  }

  Container _getBackground() {
    return new Container(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/pink_pig.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: null */
/* add child content here */ /*
,
      ),
    );
  }

  Container _getGradient(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.only(top: 90.0),
      height: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: <Color>[new Color(0x00736AB7), new Color(0xFF333333)],
          stops: [0.0, 0.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Widget _getContent() {
    return new ListView(
      padding: new EdgeInsets.fromLTRB(0.0, 280, 0.0, 32.0),
      children: <Widget>[
        new Container(
          margin: EdgeInsets.all(70.0),
          decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0))),
          padding: new EdgeInsets.symmetric(horizontal: 32.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              */
/*new Container(
                margin: EdgeInsets.fromLTRB(5, 15, 0.0, 0.0),
                child: new Image.network(
                  piggyBank.icon_url,
                  fit: BoxFit.cover,
                ),
              ),*/ /*

              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  piggyBank.pbName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}*/
