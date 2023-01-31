import 'dart:io';
import 'dart:typed_data';

import 'package:dorm_management/entities/file_entity.dart';

class FileResult{
  String name, extension;
  Uint8List? data;
  File? dataFile;

  FileResult(this.name, this.extension);

  FileEntity toFileEntity(){
    return FileEntity(-1, name, extension, null);
  }
}