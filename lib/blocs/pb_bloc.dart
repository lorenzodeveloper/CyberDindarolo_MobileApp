import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/pb_repository.dart';

class PiggyBankBloc extends BlocBase {
  PiggyBankRepository _piggybankRepository;
  StreamController _piggybankListController;

  StreamSink<Response<PiggyBankModel>> get pbListSink =>
      _piggybankListController.sink;

  Stream<Response<PiggyBankModel>> get pbListStream =>
      _piggybankListController.stream;

  PiggyBankBloc(int id) {
    _piggybankListController = StreamController<Response<PiggyBankModel>>();
    _piggybankRepository = PiggyBankRepository();
    fetchPiggyBank(id);
  }

  fetchPiggyBank(int id) async {
    pbListSink.add(Response.loading('Getting piggybank.'));
    try {
      PiggyBankModel pb =
      await _piggybankRepository.fetchPiggyBankData(id);
      pbListSink.add(Response.completed(pb));
    } catch (e) {
      pbListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<bool>> closePiggyBank(int id) async {
    try {
      final bool success =
      await _piggybankRepository.closePiggyBank(id);

      return Response.completed(success);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  dispose() {
    _piggybankListController?.close();
  }


}