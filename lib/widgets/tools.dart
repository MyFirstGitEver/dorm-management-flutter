import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dtos/file_result.dart';

import 'package:path/path.dart' as dart_path;

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  const PersistentHeader({required this.widget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: Card(
        margin: const EdgeInsets.all(0),
        color: Colors.white,
        elevation: 5.0,
        child: Center(child: widget),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class Tools{
  static Future<FileResult?> pickAFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'pdf']);

    if (result != null) {
      String fileName = result.files.first.name;
      String extension = dart_path.extension(fileName);
      fileName = fileName.substring(0, fileName.indexOf('.'));

      if(kIsWeb){
        var futureResult = FileResult(fileName, extension);
        futureResult.data = result.files.single.bytes;

        return futureResult;
      }
      else{
        var file = File(result.files.single.path!);
        var futureResult = FileResult(fileName, extension);
        futureResult.dataFile = file;

        return futureResult;
      }
    }

    return null;
  }
}