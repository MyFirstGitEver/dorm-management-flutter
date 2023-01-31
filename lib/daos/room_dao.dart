import 'dart:convert';
import 'dart:math';

import 'package:dorm_management/entities/room_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/renter_entity.dart';

class RoomDAO{
  static Future<List<RoomEntity>> getAllRooms() async{
    var prefs = await SharedPreferences.getInstance();
    var rooms = <RoomEntity>[];
    var keys = prefs.getKeys().where((key) => key.contains(RoomEntity.prefix));

    for(var key in keys){
      String json = prefs.getString(key)!;
      rooms.add(RoomEntity.fromJson(jsonDecode(json)));
    }

    return rooms;
  }

  static Future<List<RoomEntity>> getRoomsOfType(String type) async{
    var prefs = await SharedPreferences.getInstance();
    var rooms = <RoomEntity>[];
    var keys = prefs.getKeys().where((key) => key.contains("${RoomEntity.prefix}$type"));

    for(var key in keys){
      String json = prefs.getString(key)!;
      rooms.add(RoomEntity.fromJson(jsonDecode(json)));
    }

    return rooms;
  }

  static Future<bool> insertNewRoom(RoomEntity entity) async {
    var prefs = await SharedPreferences.getInstance();

    int maxId = 0;
    prefs.getKeys().forEach((key) {
      if(key.contains(RoomEntity.prefix)){
        maxId = max(maxId, int.parse(key.substring(key.indexOf('-') + 1)));
      }
    });

    entity.id = maxId + 1;

    prefs.setString(entity.toString(), jsonEncode(entity));

    return true;
  }

  static Future incrementRoomCurrentStays(RoomEntity room) async{
    var prefs = await SharedPreferences.getInstance();

    room.currentStays++;
    prefs.setString(room.toString(), jsonEncode(room));
  }

  static Future decrementRoomCurrentStays(List<RenterEntity> removedRenters) async{
    var prefs = await SharedPreferences.getInstance();

    for(RenterEntity renter in removedRenters){
      int roomId = renter.roomId;
      var key = prefs.getKeys().where((key) => key.contains(roomId.toString()) && key.contains(RoomEntity.prefix))
        .elementAt(0);

      RoomEntity room = RoomEntity.fromJson(jsonDecode(prefs.getString(key)!));

      room.currentStays--;

      if(room.currentStays == 0){
        prefs.remove(room.toString());
      }
      else{
        prefs.setString(room.toString(), jsonEncode(room));
      }
    }
  }
}