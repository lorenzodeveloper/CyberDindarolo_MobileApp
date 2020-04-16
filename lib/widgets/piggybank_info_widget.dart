import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/credit_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_participants_bloc.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_participants_model.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/entry_form_page.dart';
import 'package:cyberdindaroloapp/pages/home_page.dart';
import 'package:cyberdindaroloapp/widgets/composed_floating_button_widget.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:cyberdindaroloapp/widgets/loading_widget.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_form_widget.dart';
import 'package:cyberdindaroloapp/widgets/stock_listview_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';

/*
* This class show piggybank info:
*   - Name, Description and status (opened / closed)
*   - Stock
*
* It handles piggybank operations:
*   - CLOSE PG
*   - EDIT PG
*   - ADD PRODUCT IN PG
*   - INVITE USER
* */

class PiggyBankInfoWidget extends StatefulWidget {
  final PiggyBankModel piggyBankInstance;

  PiggyBankInfoWidget({@required this.piggyBankInstance});

  @override
  _PiggyBankInfoWidgetState createState() {
    return _PiggyBankInfoWidgetState();
  }
}

enum Operation { INFO_VIEW, EDIT_VIEW }

class _PiggyBankInfoWidgetState extends State<PiggyBankInfoWidget> {
  // Operation setter: Viewing info / Edit piggybank
  Operation _operation;

  PiggyBankBloc _piggyBankBloc;

  // Blocs
  PaginatedParticipantsBloc _paginatedParticipantsBloc;
  CreditBloc _creditBloc;

  // Composed Floating Button functions and params
  List<Function> functions;
  List<dynamic> parameters;
  static const List<IconData> icons = const [
    Icons.account_circle, // invite user
    Icons.delete, // close piggybank
    Icons.edit, // edit piggybank
    Icons.add, // insert product
  ];

  void Function(int) onInviteUser;
  void Function(int) onClosePiggyBank;
  void Function(int) onEditPiggyBank;
  void Function(int) onAddEntry;

  @override
  void initState() {
    super.initState();

    _piggyBankBloc = BlocProvider.of<PiggyBankBloc>(context); //new PiggyBankBloc();

    _operation = Operation.INFO_VIEW;

    // BLOCS MANAGED BY A STREAM BUILDER
    _paginatedParticipantsBloc = new PaginatedParticipantsBloc();
    _creditBloc = new CreditBloc();

    _paginatedParticipantsBloc.fetchUsersData(
        piggybank: widget.piggyBankInstance.id);
    _creditBloc.getCredit(piggybank: widget.piggyBankInstance.id);

    // Composed Floating Button functions and params
    onInviteUser = (int piggybank_id) {
      // TODO: REDIRECT TO INVITE USER
    };

    // Close piggybank
    onClosePiggyBank = (int piggybank_id) async {
      //region ClosePiggyBankFunction
      final ConfirmAction confirmation = await asyncConfirmDialog(context,
          title: "Do you really want to close this piggy bank?",
          question_message: "You won't be able to rollback once you "
              "decide to close a piggy bank. "
              "No one will be able to insert/edit things inside "
              "this PG.");
      switch (confirmation) {
        case ConfirmAction.CANCEL:
          break;
        case ConfirmAction.ACCEPT:
          // Close request
          final response = await _piggyBankBloc.closePiggyBank(piggybank_id);

          // Handle response
          if (response.status == Status.COMPLETED) {
            // redirect and refresh piggybanks list
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()));
          } else if (response.status == Status.ERROR) {
            // Show error message
            if (response.message.toLowerCase().contains('token')) {
              showAlertDialog(context, 'Error', response.message,
                  redirectRoute: '/');
            } else {
              showAlertDialog(context, 'Error', response.message);
            }
          }
          break;
      }
      //endregion
    };

    // Edit piggybank
    onEditPiggyBank = (int piggybank_id) {
      setState(() {
        _operation = Operation.EDIT_VIEW;
      });
    };

    // Add entry in piggybank
    onAddEntry = (int piggybank_id) async {
      var selectedProduct = await asyncProductOptionDialog(context);

      // If operation not canceled and selectedProduct exists and not error
      if (selectedProduct != null && selectedProduct != -1 && selectedProduct != -2) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EntryFormPage(
                piggyBankInstance: widget.piggyBankInstance,
                productID: selectedProduct)));
      } else if (selectedProduct != null && selectedProduct == -1) {
        // TODO: REDIRECT TO INSERT NEW PRODUCT
      } else if (selectedProduct != null && selectedProduct == -2) {
        // TODO: HANDLE ERROR
      }
    };

    // Composed Floating Button functions and params
    functions = [
      onInviteUser,
      onClosePiggyBank,
      onEditPiggyBank,
      onAddEntry,
    ];

    parameters = [
      widget.piggyBankInstance.id,
      widget.piggyBankInstance.id,
      widget.piggyBankInstance.id,
      widget.piggyBankInstance.id,
    ];
  }

  @override
  void dispose() {
    _creditBloc.dispose();
    _paginatedParticipantsBloc.dispose();
    //_piggyBankBloc.dispose();
    super.dispose();
  }

  Widget _getCreditWidget() {
    //Returns user's credit in this PG
    return StreamBuilder<Response<Decimal>>(
      stream: _creditBloc.creditStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.data);
          switch (snapshot.data.status) {
            case Status.LOADING:
              //return Loading(loadingMessage: snapshot.data.message);
              return CircularProgressIndicator();
              break;
            case Status.COMPLETED:
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    '${snapshot.data.data.toString()} PGM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      //backgroundColor: Colors.lightBlueAccent
                    ),
                  ),
                ),
              );
              break;
            case Status.ERROR:
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () => _creditBloc.getCredit(
                    piggybank: widget.piggyBankInstance.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }

  Expanded _expColumn(
      {@required int flex,
      @required List<Widget> children,
      MainAxisAlignment mAA: MainAxisAlignment.start,
      CrossAxisAlignment cAA: CrossAxisAlignment.start}) {
    return Expanded(
        flex: flex,
        child: Column(
          mainAxisAlignment: mAA,
          crossAxisAlignment: cAA,
          children: children,
        ));
  }

  Widget _getPiggyBankHeader() {
    // Build Row with piggybank image, name, status and description.

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _expColumn(flex: 3, children: <Widget>[
              CircleAvatar(
                minRadius: 15,
                maxRadius: 30,
                child: Image(
                  image: AssetImage('assets/images/pink_pig.png'),
                ),
              )
            ]),
            _expColumn(flex: 8, children: <Widget>[
              ExpandablePanel(
                header: Text(
                  widget.piggyBankInstance.pbName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                collapsed: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                  child: Text(
                    '(ID: ${widget.piggyBankInstance.id}) - ${widget.piggyBankInstance.getDescription()}',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black45),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                  child: Text(
                      '(ID: ${widget.piggyBankInstance.id}) - ${widget.piggyBankInstance.getDescription()}',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black45)),
                ),
              )
            ]),
            _expColumn(
                mAA: MainAxisAlignment.spaceAround,
                cAA: CrossAxisAlignment.center,
                flex: 4,
                children: <Widget>[
                  Text(widget.piggyBankInstance.closed ? 'CLOSED' : 'OPEN',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.piggyBankInstance.closed
                              ? Colors.red
                              : Colors.green)),
                  _getCreditWidget(),
                ])
          ],
        ),
      ],
    );
  }

  Widget _participantsOverviewStreamBuilder() {
    // streamBuilder of participants
    return StreamBuilder<Response<PaginatedParticipantsModel>>(
      stream: _paginatedParticipantsBloc.pagParticipantsListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text('You and ${snapshot.data.data.count - 1} other users'),
              );
              break;
            case Status.ERROR:
              print(snapshot.data.message);
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () => _paginatedParticipantsBloc.fetchUsersData(
                    piggybank: widget.piggyBankInstance.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }

  Widget _getParticipantsOverviewWidget() {
    // Returns a row that contains an overview of participants inside this PG
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            _participantsOverviewStreamBuilder(),
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
    );
  }

  Widget _buildInfoView() {
    /* Returns the real widget for viewing piggybank info
    *   - PiggyBank Header
    *   - PiggyBank Participants
    *   - PiggyBank Stock
    *   - Floating Button with piggybank operations
    */
    return Stack(
      children: <Widget>[
        ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            // PiggyBank Header: Name, Desc, Credit
            _getPiggyBankHeader(),
            Divider(),
            // Participants overview
            _getParticipantsOverviewWidget(),
            Divider(),
            // STOCK
            Row(
              children: <Widget>[
                StockListViewWidget(
                    closed: widget.piggyBankInstance.closed,
                    piggybank_id: widget.piggyBankInstance.id,
                    onPurchase: () {
                      _creditBloc.getCredit(
                          piggybank: widget.piggyBankInstance.id);
                    }),
              ],
            ),
          ],
        ),
        // Floating button
        Container(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // If piggybank is closed, floating button is disabled
            child: !widget.piggyBankInstance.closed
                ? ComposedFloatingButton(
                    icons: icons,
                    functions: functions,
                    parameters: parameters,
                  )
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: null,
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build widget in INFO view or EDIT view
    switch (_operation) {
      case Operation.INFO_VIEW:
        return _buildInfoView();
        break;
      case Operation.EDIT_VIEW:
        return BlocProvider(
          bloc: PiggyBankBloc(),
          child: PiggyBankForm(
            piggyBankInstance: widget.piggyBankInstance,
            onFormCancel: () {
              setState(() {
                _operation = Operation.INFO_VIEW;
                //_piggyBankBloc.fetchPiggyBank(widget.piggyBankInstance.id);
                _paginatedParticipantsBloc.fetchUsersData(
                    piggybank: widget.piggyBankInstance.id);
                _creditBloc.getCredit(piggybank: widget.piggyBankInstance.id);
              });
            },
            onFormSuccessfullyValidated: () {
              setState(() {
                _operation = Operation.INFO_VIEW;
                //_piggyBankBloc.fetchPiggyBank(widget.piggyBankInstance.id);
                _paginatedParticipantsBloc.fetchUsersData(
                    piggybank: widget.piggyBankInstance.id);
                _creditBloc.getCredit(piggybank: widget.piggyBankInstance.id);
              });
            },
          ),
        );
        break;
    }
  }
}
