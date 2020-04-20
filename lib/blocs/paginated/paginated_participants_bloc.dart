import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_participants_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated/paginated_users_repository.dart';
import 'package:flutter/material.dart';


class PaginatedParticipantsBloc extends BlocBase {
  PaginatedUsersRepository _pagUsersRepository;
  StreamController _pagParticipantsListController;

  StreamSink<Response<PaginatedParticipantsModel>> get pagParticipantsListSink =>
      _pagParticipantsListController.sink;

  Stream<Response<PaginatedParticipantsModel>> get pagParticipantsListStream =>
      _pagParticipantsListController.stream;

  bool get isClosed => _pagParticipantsListController.isClosed;

  PaginatedParticipantsBloc() {
    _pagParticipantsListController = StreamController<Response<PaginatedParticipantsModel>>.broadcast();
    _pagUsersRepository = PaginatedUsersRepository();
  }

  fetchParticipants({int page: 1, @required int piggybank}) async {
    pagParticipantsListSink.add(Response.loading('Getting participants.'));
    try {
      PaginatedParticipantsModel paginatedUsers =
      await _pagUsersRepository.fetchParticipants(page: page, piggybank: piggybank);
      pagParticipantsListSink.add(Response.completed(paginatedUsers));
    } catch (e) {
      pagParticipantsListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _pagParticipantsListController?.close();
  }
}