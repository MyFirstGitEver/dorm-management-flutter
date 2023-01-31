import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dorm_management/daos/renter_dao.dart';
import 'package:dorm_management/daos/room_dao.dart';
import 'package:dorm_management/dtos/file_result.dart';
import 'package:dorm_management/entities/room_entity.dart';
import 'package:dorm_management/widgets/stateful/others/renter_editor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../dtos/renter_dto.dart';
import '../../../entities/renter_entity.dart';
import '../../entity_widget/renter_entity_widget.dart';

class RoomInfoDialog extends StatefulWidget {
  final RoomEntity room;

  const RoomInfoDialog({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomInfoDialog> createState() => _RoomInfoDialogState();
}

class _RoomInfoDialogState extends State<RoomInfoDialog> {
  int currentPage = 0;
  String mode = "viewing";

  RenterEntity? lastInformation;
  List<RenterDTO> renters = [];
  FileResult? result;

  @override
  void initState() {
    RenterDAO.filterBasedOnRoomId(widget.room.id).then((entities) => setState((){
      for(var entity in entities){
        renters.add(RenterDTO(entity, true));
      }

      for(int i=renters.length;i<widget.room.capacity;i++){
        renters.add(RenterDTO(RenterEntity(-1, widget.room.id, true, "Chưa có tên", "Rỗng", "Rỗng"), false));
      }
    }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(children: [
        Dialog(
            child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    IconButton(
                      onPressed: () {
                        if (mode == "editing") {
                          showDialog(
                              context: context,
                              builder: (_) => askForSavingInformationDialog());
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text("Phòng ${widget.room.id}")
                  ]),
                  TextButton(
                      onPressed: () {
                        lastInformation = renters[currentPage].entity.clone();

                        setState(() {
                          mode = "editing";
                        });
                      },
                      child: const Text("Sửa",
                          style: TextStyle(color: Colors.black)))
                ],
              ),
              Container(
                  height: 350,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: mode == "viewing"
                        ? PageView(
                            onPageChanged: (index) => currentPage = index,
                            controller:
                                PageController(initialPage: currentPage),
                            children: rentersDisplay(),
                          )
                        : RenterEditor(
                            renter: renters[currentPage].entity,
                            loadNewImage: (result) {
                              this.result = result;
                            }),
                  ))
            ],
          ),
        ))
      ]),
    );
  }

  List<Widget> rentersDisplay(){
    var list = <Widget>[];

    for(int i=0;i<renters.length;i++){
      list.add(RenterEntityWidget(renter: renters[i].entity));
    }

    return list;
  }

  AlertDialog askForSavingInformationDialog() => AlertDialog(
    title: const Text("Lưu thông tin người thuê"),
    content: const Text("Thêm người này vào danh sách thuê"),
    actions: [
      TextButton(onPressed:(){
        renters[currentPage].entity = lastInformation!;

        setState(() {
          mode = "viewing";
        });
        Navigator.pop(context);
      }, child: const Text("Hủy")),
      TextButton(onPressed:(){
        if(renters[currentPage].isReal){
          RenterDAO.modifyRenterUsingId(renters[currentPage].entity);
          loadImage();
        }
        else{
          if(widget.room.id == -1){
            insertFirstRenter();
          }
          else{
            insertNewRenter();
          }
        }

        setState(() {
          mode = "viewing";
        });
        Navigator.pop(context);
      }, child: const Text("OK")),
    ],
  );

  void insertFirstRenter() async{
    await RoomDAO.insertNewRoom(widget.room);

    for(var renter in renters){
      renter.entity.roomId = widget.room.id; // reassign new room id
    }

    insertNewRenter();
  }

  void insertNewRenter() async{
    renters[currentPage].isReal = true;
    await RenterDAO.insertNewRenter(renters[currentPage].entity);
    await RoomDAO.incrementRoomCurrentStays(widget.room);

    loadImage();
  }

  void loadImage(){
    if(result != null){
      var storage = FirebaseStorage.instance.ref().child("${renters[currentPage].entity.id}.png");

      if(result!.data != null){
        storage.putData(result!.data!);
      }
      else{
        storage.putFile(result!.dataFile!);
      }

      result = null;
    }
  }
}