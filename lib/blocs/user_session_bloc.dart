import 'dart:async';

import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/user_session_repository.dart';

import '../bloc_provider.dart';

class UserSessionBloc extends BlocBase {
  UserSessionRepository _userSessionRepository;
  StreamController _userSessionListController;

  UserSessionModel _lastValidData;

  UserSessionModel get lastValidData => _lastValidData;

  StreamSink<Response<UserSessionModel>> get userListSink =>
      _userSessionListController.sink;

  Stream<Response<UserSessionModel>> get userListStream =>
      _userSessionListController.stream;

  UserSessionBloc() {
    _userSessionListController = StreamController<Response<UserSessionModel>>.broadcast();
    _userSessionRepository = UserSessionRepository();
    _lastValidData = null;
  }

  login({String username, String password}) async {
    userListSink.add(Response.loading('Loggin in.'));
    try {
      UserSessionModel us =
      await _userSessionRepository.login(username: username, password: password);
      userListSink.add(Response.completed(us));
      _lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  fetchUserSession() async {
    userListSink.add(Response.loading('Fetching user session.'));
    try {
      UserSessionModel us =
      await _userSessionRepository.fetchUserSession();
      userListSink.add(Response.completed(us));
      _lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  logout() async {
    userListSink.add(Response.loading('Loggin out.'));
    try {
      UserSessionModel us =
      await _userSessionRepository.logout();
      userListSink.add(Response.completed(us));
      _lastValidData = us;
    } catch (e) {
      userListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _userSessionListController?.close();
  }


}