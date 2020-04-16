import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/piggybank_repository.dart';
import 'package:flutter/material.dart';

class PiggyBankBloc extends BlocBase {
  PiggyBankRepository _piggybankRepository;
  StreamController _piggybankListController;

  StreamSink<Response<PiggyBankModel>> get pbListSink =>
      _piggybankListController.sink;

  Stream<Response<PiggyBankModel>> get pbListStream =>
      _piggybankListController.stream;

  bool get isClosed => _piggybankListController.isClosed;

  PiggyBankBloc() {
    _piggybankListController =
        StreamController<Response<PiggyBankModel>>.broadcast();
    _piggybankRepository = PiggyBankRepository();
    //fetchPiggyBank(id);
  }

  fetchPiggyBank(int id) async {
    pbListSink.add(Response.loading('Getting piggybank.'));
    try {
      PiggyBankModel pb = await _piggybankRepository.fetchPiggyBankData(id);
      pbListSink.add(Response.completed(pb));
    } catch (e) {
      pbListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<bool>> closePiggyBank(int id) async {
    try {
      final bool success = await _piggybankRepository.closePiggyBank(id);

      return Response.completed(success);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  Future<Response<PiggyBankModel>> updatePiggyBank(
      {@required int id,
      @required String newName,
      @required String newDescription}) async {
    try {
      PiggyBankModel pb = await _piggybankRepository.updatePiggyBank(
          id: id, newName: newName, newDescription: newDescription);
      return Response.completed(pb);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  Future<Response<PiggyBankModel>> createPiggyBank(
      {@required String name, @required String description}) async {
    try {
      PiggyBankModel pb = await _piggybankRepository.createPiggyBank(
          name: name, description: description);
      return Response.completed(pb);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  dispose() {
    _piggybankListController?.close();
  }
}
