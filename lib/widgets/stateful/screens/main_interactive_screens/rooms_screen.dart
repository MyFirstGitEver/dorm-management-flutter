import 'package:dorm_management/daos/room_dao.dart';
import 'package:dorm_management/daos/room_initializer_dao.dart';
import 'package:dorm_management/entities/room_initialiser_entity.dart';
import 'package:dorm_management/widgets/stateful/absolute_collapse.dart';
import 'package:dorm_management/widgets/stateful/invisible_expanded_header.dart';
import 'package:flutter/material.dart';

import '../../../../dtos/room_dto.dart';
import '../../../../entities/room_entity.dart';
import '../../../entity_widget/room_entity_widget.dart';
import '../../../tools.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<RoomInitializerEntity?> roomTypes = [];
  List<RoomDTO> rooms = [];
  String roomType = "Tất cả";

  int totalCount = 0;

  @override
  void initState() {
    RoomInitializerDAO.getAllInitializers().then((entities){
      for(var entity in entities){
        totalCount += entity.total;
      }

      roomTypes = [null];
      entities.sort((a, b) => a.capacity - b.capacity);
      roomTypes.addAll(entities);

      RoomDAO.getAllRooms().then((rooms) => fillInFakeRooms(rooms));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbsoluteCollapseContainer(
        header: SliverPersistentHeader(
            pinned: true, delegate: PersistentHeader(widget: filterButton())),
        appBar: SliverAppBar(
          backgroundColor: Colors.blueAccent,
          expandedHeight: 150,
          floating: true,
          pinned: true,
          title: const InvisibleExpandedHeader(
              child: Text("Dorm management",
                  style: TextStyle(color: Colors.black))),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset("images/hall.png")),
                  const SizedBox(height: 15),
                  Text(
                      "Tổng cộng $totalCount phòng. Có các loại phòng: ${listOutAllRoomTypes()}")
                ],
              ),
            ),
            stretchModes: const <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
              StretchMode.fadeTitle,
            ],
          ),
        ),
        child: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return RoomEntityWidget(room: rooms[index].entity);
            },
            childCount: rooms.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            childAspectRatio: 2.0,
          ),
        ),
      ),
    );
  }

  Widget filterButton() => Container(
        margin: const EdgeInsets.only(left: 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: roomType,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              onChanged: (String? value) async {
                roomType = value!;

                if (roomType == "Tất cả") {
                  await RoomDAO.getAllRooms()
                      .then((rooms) => fillInFakeRooms(rooms));
                } else {
                  await RoomDAO.getRoomsOfType(roomType)
                      .then((rooms) => fillInFakeRooms(rooms));
                }
              },
              items: roomTypes.map<DropdownMenuItem<String>>(
                  (RoomInitializerEntity? value) {
                return DropdownMenuItem<String>(
                  value: value == null ? "Tất cả" : "${value.capacity}",
                  child: Text(
                      value == null ? "Tất cả" : "${value.capacity} Người"),
                );
              }).toList(),
            )),
      );

  void fillInFakeRooms(List<RoomEntity> rentedRooms){
    List<RoomDTO> dtos = [];
    var counter = <int, int>{};

    for(RoomEntity entity in rentedRooms){
      dtos.add(RoomDTO(entity, true));

      counter[entity.capacity] = (counter[entity.capacity] ?? 0) + 1;
    }

    if(roomType != "Tất cả"){
      int type = int.parse(roomType);
      fillInFakeRoomsOfCapacity(dtos, getLeftRoomCount(type, dtos.length), type);
    }
    else{
      for(var roomType in roomTypes){
        if(roomType != null){
          fillInFakeRoomsOfCapacity(dtos, roomType.total - (counter[roomType.capacity] ?? 0), roomType.capacity);
        }
      }
    }

    setState(() {
      rooms = dtos;
    });
  }

  fillInFakeRoomsOfCapacity(List<RoomDTO> dtos, int left, int type){
    for(int i=0;i<left;i++){
      dtos.add(RoomDTO(RoomEntity(-1, type, 0), false));
    }
  }

  int getLeftRoomCount(int roomType, int filled){
    return roomTypes.where((initializer) => initializer != null && initializer.capacity == roomType)
        .elementAt(0)!.total - filled;
  }

  String listOutAllRoomTypes(){
    StringBuffer buffer = StringBuffer();

    for(int i=1;i<roomTypes.length;i++){
      if(i != roomTypes.length - 1){
        buffer.write("${roomTypes[i]!.capacity} Người, ");
      }
      else{
        buffer.write("${roomTypes[i]!.capacity} Người");
      }
    }

    return buffer.toString();
  }
}