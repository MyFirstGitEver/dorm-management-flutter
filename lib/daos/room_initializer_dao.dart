import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/room_initialiser_entity.dart';

class RoomInitializerDAO{
  static Future<bool> storeInitializers(List<RoomInitializerEntity> initializers) async{
    var prefs = await SharedPreferences.getInstance();

    for(var entity in initializers){
      prefs.setString(entity.toString(), jsonEncode(entity));
    }

    return true;
  }

  static Future<List<RoomInitializerEntity>> getAllInitializers() async{
    var entities = <RoomInitializerEntity>[];

    var prefs = await SharedPreferences.getInstance();

    var keys = prefs.getKeys().where((key) => key.contains(RoomInitializerEntity.prefix) && key != "init");

    for(String key in keys){
      String json = prefs.getString(key)!;
      entities.add(RoomInitializerEntity.fromJson(jsonDecode(json)));
    }

    return entities;
  }
}