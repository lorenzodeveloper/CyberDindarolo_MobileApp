import 'package:cyberdindaroloapp/models/invitation_model.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_invitations_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedInvitationsRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  Future<PaginatedInvitationsModel> fetchInvitations({int page: 1}) async {
    var headers = await _getAuthHeader();
    final response =
        await _provider.get("invitations/?page=$page", headers: headers);
    return PaginatedInvitationsModel.fromJson(response);
  }

  inviteUser({@required int piggybank_id, @required int invited_id}) async {
    var headers = await _getAuthHeader();
    var requestBody = {
      'invited': invited_id.toString(),
      'piggybank': piggybank_id.toString(),
    };

    final response = await _provider.post("invitations/",
        headers: headers, body: requestBody);
    return InvitationModel.fromJson(response);
  }

  Future<bool> acceptInvitation({@required int id}) async {
    final headers = await _getAuthHeader();

    final body = {'accept': '1'};

    final response =
        await _provider.post("invitations/manage/$id/", headers: headers, body: body);

    if (response['message'] != null) return true;

    return false;
  }

  Future<bool> declineInvitation({@required int id}) async {
    final headers = await _getAuthHeader();

    final body = {'accept': '0'};

    final response = await _provider.post("invitations/manage/$id/",
        headers: headers, body: body);

    if (response['message'] != null) return true;

    return false;
  }

  deleteInvitation({@required int id}) async {
    final headers = await _getAuthHeader();

    final response = await _provider.delete("invitations/$id/",
        headers: headers);

    return response['message'];
  }
}
