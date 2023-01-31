import 'package:dorm_management/entities/file_entity.dart';

class FileDTO{
  FileEntity entity;
  bool isChecked = false, isRenterPic, isNew = true;

  FileDTO(this.entity, this.isRenterPic);
}