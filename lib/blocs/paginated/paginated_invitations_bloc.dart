import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/invitation_model.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_invitations_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated/paginated_invitations_repository.dart';
import 'package:flutter/material.dart';

class PaginatedInvitationsBloc extends BlocBase {
  PaginatedInvitationsRepository _pagInvitationsRepository;
  StreamController _pagInvitationsListController;

  StreamSink<Response<PaginatedInvitationsModel>> get pagInvitationsListSink =>
      _pagInvitationsListController.sink;

  Stream<Response<PaginatedInvitationsModel>> get pagInvitationsListStream =>
      _pagInvitationsListController.stream;

  bool get isClosed => _pagInvitationsListController.isClosed;

  PaginatedInvitationsBloc() {
    _pagInvitationsListController =
        StreamController<Response<PaginatedInvitationsModel>>.broadcast();
    _pagInvitationsRepository = PaginatedInvitationsRepository();
  }

  fetchInvitations({int page: 1}) async {
    pagInvitationsListSink.add(Response.loading('Getting invitations.'));
    try {
      PaginatedInvitationsModel paginatedInvitationsModel =
          await _pagInvitationsRepository.fetchInvitations(page: page);
      pagInvitationsListSink.add(Response.completed(paginatedInvitationsModel));
    } catch (e) {
      pagInvitationsListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<InvitationModel>> inviteUser(
      {@required int piggybank_id,
        @required int invited_id}) async {
    try {
      InvitationModel invitationModel =
          await _pagInvitationsRepository.inviteUser(
            piggybank_id: piggybank_id,
            invited_id: invited_id);

      return Response.completed(invitationModel);
    } catch (e) {
      return Response.error(e.toString());
    }
  }

  dispose() {
    _pagInvitationsListController?.close();
  }
}
