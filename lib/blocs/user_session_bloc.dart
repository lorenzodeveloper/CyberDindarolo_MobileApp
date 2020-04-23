import 'dart:async';

import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/user_session_repository.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

class UserSessionBloc extends BlocBase {
  UserSessionRepository _userSessionRepository;
  StreamController _userSessionListController;

  //UserSessionModel _lastValidData;

  //UserSessionModel get lastValidData => _lastValidData;

  StreamSink<Response<UserSessionModel>> get userListSink =>
      _userSessionListController.sink;

  Stream<Response<UserSessionModel>> get userListStream =>
      _userSessionListController.stream;

  bool get isClosed => _userSessionListController.isClosed;

  UserSessionBloc() {
    _userSessionListController =
        StreamController<Response<UserSessionModel>>.broadcast();
    _userSessionRepository = UserSessionRepository();
    //_lastValidData = null;
  }

  login({String username, String password}) async {
    userListSink.add(Response.loading('Loggin in.'));
    try {
      UserSessionModel us = await _userSessionRepository.login(
          username: username, password: password);
      userListSink.add(Response.completed(us));
      //_lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  fetchUserSession() async {
    userListSink.add(Response.loading('Fetching user session.'));
    try {
      UserSessionModel us = await _userSessionRepository.fetchUserSession();
      userListSink.add(Response.completed(us));
      //_lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  fetchUserSessionWithoutStream() async {
    try {
      UserSessionModel us = await _userSessionRepository.fetchUserSession();
      return Response.completed(us);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  logout() async {
    userListSink.add(Response.loading('Loggin out.'));
    try {
      UserSessionModel us = await _userSessionRepository.logout();
      userListSink.add(Response.completed(us));
      //_lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<UserProfileModel>> editProfile(
      {@required UserProfileModel oldInstance,
      @required UserProfileModel newInstance,
      String newPwd}) async {
    try {
      UserProfileModel us = await _userSessionRepository.editProfile(
          oldInstance: oldInstance, newInstance: newInstance, newPwd: newPwd);
      return Response.completed(us);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  Future<Response<UserProfileModel>> createUser(
      {@required UserProfileModel instance, @required String pwd}) async {
    try {
      UserProfileModel us =
          await _userSessionRepository.createUser(instance: instance, pwd: pwd);
      return Response.completed(us);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  Future<Response<bool>> deleteAccount({@required int id}) async {
    try {
      final bool success = await _userSessionRepository.deleteAccount(id: id);

      return Response.completed(success);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  Future<Response<bool>> resetPwd({@required String email}) async {
    try {
      final bool success = await _userSessionRepository.resetPwd(email: email);

      return Response.completed(success);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }

  dispose() {
    _userSessionListController?.close();
  }
}
