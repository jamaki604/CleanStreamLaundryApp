import 'package:shared_preferences/shared_preferences.dart';

class StorageService{

   late SharedPreferences _storageInstance;

  Future<void> init() async{
    _storageInstance = await  SharedPreferences.getInstance();
  }

  Future<void> setValue(String key,String value) async{
    await _storageInstance.setString(key,value);
  }

  Future<String?> getValue(String key) async{
    return await _storageInstance.getString(key);
  }


}