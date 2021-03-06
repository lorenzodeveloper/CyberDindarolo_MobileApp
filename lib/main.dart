import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/credit_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_invitations_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_users_bloc.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/pages/about_page.dart';
import 'package:cyberdindaroloapp/pages/home_page.dart';
import 'package:cyberdindaroloapp/pages/login_page.dart';
import 'package:cyberdindaroloapp/pages/products_page.dart';
import 'package:cyberdindaroloapp/pages/users_list_page.dart';
import 'package:flutter/material.dart';

import 'blocs/paginated/paginated_entries_bloc.dart';
import 'blocs/paginated/paginated_participants_bloc.dart';
import 'blocs/paginated/paginated_piggybanks_bloc.dart';
import 'blocs/paginated/paginated_products_bloc.dart';
import 'blocs/paginated/paginated_purchases_bloc.dart';
import 'blocs/paginated/paginated_stock_bloc.dart';

void main() => runApp(MyApp());

class GlobalBlocs extends StatelessWidget {
  // Provide Blocs to all the app widgets
  final Widget child;

  GlobalBlocs({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: UserSessionBloc(),
      child: BlocProvider(
        bloc: PaginatedUsersBloc(),
        child: BlocProvider(
            bloc: PiggyBankBloc(),
            child: BlocProvider(
                bloc: PaginatedPiggyBanksBloc(),
                child: BlocProvider(
                    bloc: PaginatedParticipantsBloc(),
                    child: BlocProvider(
                        bloc: PaginatedProductsBloc(),
                        child: BlocProvider(
                            bloc: PaginatedStockBloc(),
                            child: BlocProvider(
                              bloc: PaginatedEntriesBloc(),
                              child: BlocProvider(
                                bloc: CreditBloc(),
                                child: BlocProvider(
                                    bloc: PaginatedPurchasesBloc(),
                                    child: BlocProvider(
                                        bloc: PaginatedInvitationsBloc(),
                                        child: child)),
                              ),
                            )))))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalBlocs(
      child: MaterialApp(
          title: 'CyberDindarolo',
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => LoginPage(),
            '/home': (BuildContext context) => HomePage(),
            '/users': (BuildContext context) => UsersListViewPage(),
            '/products': (BuildContext context) => ProductsPage(),
            '/about': (BuildContext context) => AboutPage(),
          },
          theme: ThemeData(
              textTheme: Theme.of(context).textTheme.apply(
                    fontSizeFactor: 1.1,
                    fontSizeDelta: 2.0,
                  ))),
    );
  }
}