import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/renter_entity.dart';

enum Gender {male, female, all}

extension ParseToString on Gender{
  String inString(){
    switch(index){
      case 0:
        return "Nam";
      case 1:
        return "Nữ";
      default:
        return "Tất cả";
    }
  }
}

class RenterDAO{
  static Future<List<RenterEntity>> filterRentersBasedOnGenderAndTerm(Gender gender, String term) async {
    var prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys().where((key) =>
        key.contains(RenterEntity.prefix));

    List<RenterEntity> list = [];

    for (var key in keys) {
      String json = prefs.getString(key)!;
      var entity = RenterEntity.fromJson(jsonDecode(json));

      if (gender == Gender.all ||
          (entity.isMale && gender == Gender.male) ||
          (!entity.isMale && gender == Gender.female)) {
        if(entity.name.contains(term) || entity.roomId == (int.tryParse(term) ?? -2)){
          list.add(entity);
        }
      }
    }

    return list;
  }

  static Future<List<RenterEntity>> filterBasedOnRoomId(int roomId) async{
    var prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys().where((key) =>
        key.contains("${RenterEntity.prefix}$roomId"));

    List<RenterEntity> list = [];

    for(var key in keys){
      String json = prefs.getString(key)!;
      var entity = RenterEntity.fromJson(jsonDecode(json));

      list.add(entity);
    }

    return list;
  }

  static insertNewRenter(RenterEntity entity) async{
    var prefs = await SharedPreferences.getInstance();

    int maxId = 0;
    prefs.getKeys().forEach((key) {
      if(key.contains(RenterEntity.prefix)){
        maxId = max(maxId, int.parse(key.substring(key.indexOf('-') + 1)));
      }
    });

    entity.id = maxId + 1;

    prefs.setString(entity.toString(), jsonEncode(entity));
  }

  static modifyRenterUsingId(RenterEntity entity) async{
    var prefs = await SharedPreferences.getInstance();

    prefs.setString(entity.toString(), jsonEncode(entity));
  }

  static deleteRenters(List<RenterEntity> renters) async{
    var prefs = await SharedPreferences.getInstance();

    for(var renter in renters){
      prefs.remove(renter.toString());
    }
  }
}