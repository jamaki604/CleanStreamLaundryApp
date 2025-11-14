import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService{

   @protected
   late SharedPreferences storageInstance;

  Future<void> init() async{
    storageInstance = await  SharedPreferences.getInstance();
  }

  Future<void> setValue(String key,String value) async{
    await storageInstance.setString(key,value);
  }

  Future<String?> getValue(String key) async{
    return await storageInstance.getString(key);
  }


}