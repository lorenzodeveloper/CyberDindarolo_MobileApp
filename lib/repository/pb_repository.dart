import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';

class PiggyBankRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PiggyBankModel> fetchPiggyBankData(
      int id) async {

    final stored_token = await _storageRepository.getToken();

    var headers = {
      'Authorization': 'Token $stored_token'
    };

    print(stored_token);

    final response = await _provider.get("piggybanks/$id/", headers: headers);
    return PiggyBankModel.fromJson(response);
  }
}