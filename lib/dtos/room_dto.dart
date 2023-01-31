import 'package:dorm_management/entities/room_entity.dart';

class RoomDTO{
  bool isReal;
  RoomEntity entity;

  RoomDTO(this.entity, this.isReal);
}