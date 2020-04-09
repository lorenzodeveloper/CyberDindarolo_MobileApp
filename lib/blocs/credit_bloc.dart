import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated_piggybanks_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class CreditBloc extends BlocBase {
  PaginatedPiggyBanksRepository _piggybankRepository;
  StreamController _creditController;
  

  StreamSink<Response<Decimal>> get creditSink =>
      _creditController.sink;

  Stream<Response<Decimal>> get creditStream =>
      _creditController.stream;

  bool get isClosed => _creditController.isClosed;

  CreditBloc() {
    _creditController = StreamController<Response<Decimal>>.broadcast();
    _piggybankRepository = PaginatedPiggyBanksRepository();
  }

  getCredit({@required int piggybank}) async {
    creditSink.add(Response.loading('Getting credit.'));
    try {
      Decimal credit =
      await _piggybankRepository.getCredit(piggybank: piggybank);
      creditSink.add(Response.completed(credit));
    } catch (e) {
      creditSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _creditController?.close();
  }
}