import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_users_model.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated/paginated_users_repository.dart';
import 'package:flutter/material.dart';


class PaginatedUsersBloc extends BlocBase {
  PaginatedUsersRepository _pagUsersRepository;
  StreamController _pagUsersListController;

  StreamSink<Response<PaginatedUsersModel>> get pagUsersListSink =>
      _pagUsersListController.sink;

  Stream<Response<PaginatedUsersModel>> get pagUsersListStream =>
      _pagUsersListController.stream;

  bool get isClosed => _pagUsersListController.isClosed;

  PaginatedUsersBloc() {
    _pagUsersListController = StreamController<Response<PaginatedUsersModel>>.broadcast();
    _pagUsersRepository = PaginatedUsersRepository();
  }

  fetchUsers({int page: 1, String pattern}) async {
    pagUsersListSink.add(Response.loading('Getting users.'));
    try {
      PaginatedUsersModel paginatedUsers =
      await _pagUsersRepository.fetchUsers(page: page, pattern: pattern);
      pagUsersListSink.add(Response.completed(paginatedUsers));
    } catch (e) {
      pagUsersListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<UserProfileModel>> getUser({@required int id}) async {
    try {
      UserProfileModel userProfileModel =
          await _pagUsersRepository.getUser(id: id);
      return Response.completed(userProfileModel);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  dispose() {
    _pagUsersListController?.close();
  }
}