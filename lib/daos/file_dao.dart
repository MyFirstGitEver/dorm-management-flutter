import 'dart:convert';
import 'dart:math';

import 'package:dorm_management/entities/file_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileDAO{
  static Future<List<FileEntity>> getAllSavedFiles() async{
    var prefs = await SharedPreferences.getInstance();

    var keys = prefs.getKeys().where((key) => key.contains(FileEntity.prefix));

    List<FileEntity> files = [];
    for(var key in keys){
      String json = prefs.getString(key)!;

      files.add(FileEntity.fromJson(jsonDecode(json)));
    }

    return files;
  }

  static insertNewFile(FileEntity entity) async{
    var prefs = await SharedPreferences.getInstance();

    int maxId = 1;
    prefs.getKeys().forEach((key) {
      if(key.contains(FileEntity.prefix)){
        maxId = max(maxId, int.parse(key.substring(4)));
      }
    });

    entity.id = maxId + 1;

    prefs.setString(entity.toString(), jsonEncode(entity));
  }

  static deleteFiles(List<FileEntity> files) async{
    var prefs = await SharedPreferences.getInstance();

    for(var file in files){
      prefs.remove(file.toString());
    }
  }
}