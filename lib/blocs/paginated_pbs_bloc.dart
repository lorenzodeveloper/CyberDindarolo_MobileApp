import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated_pbs_repository.dart';

class PaginatedPiggyBanksBloc extends BlocBase {
  PaginatedPiggyBanksRepository _piggybankRepository;
  StreamController _piggybankListController;
  PaginatedPiggyBanksModel _lastValidData;

  PaginatedPiggyBanksModel get lastValidData => _lastValidData;

  StreamSink<Response<PaginatedPiggyBanksModel>> get pbListSink =>
      _piggybankListController.sink;

  Stream<Response<PaginatedPiggyBanksModel>> get pbListStream =>
      _piggybankListController.stream;

  bool get isClosed => _piggybankListController.isClosed;

  PaginatedPiggyBanksBloc() {
    _piggybankListController = StreamController<Response<PaginatedPiggyBanksModel>>.broadcast();
    _piggybankRepository = PaginatedPiggyBanksRepository();
    _lastValidData = null;
    //fetchPiggyBanks(token, page: page);
  }



  fetchPiggyBanks({int page: 1}) async {
    pbListSink.add(Response.loading('Getting piggybanks.'));
    try {
      PaginatedPiggyBanksModel paginatedPB =
      await _piggybankRepository.fetchPiggyBanksData(page: page);
      pbListSink.add(Response.completed(paginatedPB));
      _lastValidData = paginatedPB;
    } catch (e) {
      pbListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _piggybankListController?.close();
  }
}