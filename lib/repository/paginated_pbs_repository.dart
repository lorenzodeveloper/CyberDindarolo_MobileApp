
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';

class PaginatedPiggyBanksRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedPiggyBanksModel> fetchPiggyBanksData(
      {int page: 1}) async {

    final stored_token = await _storageRepository.getToken();

    var headers = {
      'Authorization': 'Token $stored_token'
    };

    //if (id == null) {
    final response =
    await _provider.get("piggybanks/?page=$page", headers: headers);
    return PaginatedPiggyBanksModel.fromJson(response);

    /*for (int i = 2; i <= page && ppbs.next != null; i++) {
      response = await _provider.get("piggybanks/?page=$i", headers: headers);
      ppbs.results.addAll(PaginatedPiggyBanksModel.fromJson(response).results);
      ppbs.next = PaginatedPiggyBanksModel.fromJson(response).next;
    }
    return ppbs;*/
    //}

    //var response = await _provider.get("piggybanks/$id/", headers: headers);
    //return PaginatedPiggyBanks.fromJson(response);
  }
}