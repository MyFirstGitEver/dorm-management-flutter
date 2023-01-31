import 'package:dorm_management/entities/renter_entity.dart';

class RenterDTO{
  RenterEntity entity;
  bool isChecked = false;
  bool isReal;

  RenterDTO(this.entity, this.isReal);
}