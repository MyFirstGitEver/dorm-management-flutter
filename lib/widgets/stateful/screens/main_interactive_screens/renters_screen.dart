import 'package:dorm_management/daos/renter_dao.dart';
import 'package:dorm_management/entities/renter_entity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../../daos/room_dao.dart';
import '../../../../dtos/renter_dto.dart';
import '../../../entity_widget/renter_entity_widget.dart';

class RentersScreen extends StatefulWidget {
  const RentersScreen({Key? key}) : super(key: key);

  @override
  State<RentersScreen> createState() => _RentersScreenState();
}

class _RentersScreenState extends State<RentersScreen> {
  late final TextEditingController _searchTerm;

  Gender gender = Gender.all;
  bool isDeleting = false;

  List<RenterDTO> renters = [];

  @override
  void initState() {
    _searchTerm = TextEditingController();

    _searchTerm.addListener(() {
      RenterDAO.filterRentersBasedOnGenderAndTerm(gender, _searchTerm.text).then((list) =>  setState((){
        renters.clear();

        for(var entity in list){
          renters.add(RenterDTO(entity, true));
        }
      }));
    });

    RenterDAO.filterRentersBasedOnGenderAndTerm(gender, "").then((list) =>  setState((){
      for(var entity in list){
        renters.add(RenterDTO(entity, true));
      }
    }));

    super.initState();
  }

  @override
  void dispose() {
    _searchTerm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (isDeleting) {
            cleanUp(false);
            return false;
          }

          return true;
        },
        child: Scaffold(
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Expanded(child: searchBar()), filterButton()]),
              ),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (_, index) => Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          elevation: 0),
                      onLongPress: () {
                        if (!isDeleting) {
                          setState(() {
                            isDeleting = true;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Visibility(
                              visible: isDeleting,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: isDeleting,
                              child: Checkbox(
                                  value: renters[index].isChecked,
                                  onChanged: (value) => setState(() {
                                        renters[index].isChecked = value!;
                                      }))),
                          const SizedBox(width: 10),
                          Expanded(child: RenterEntityWidget(renter: renters[index].entity))
                        ],
                      )),
                ),
                itemCount: renters.length,
              ))
            ],
          ),
          floatingActionButton: isDeleting
              ? SizedBox(
                  width: 35,
                  height: 35,
                  child: FloatingActionButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) => deleteAlertDialog()),
                      child: const Icon(Icons.remove)),
                )
              : null,
        ));
  }

  Widget searchBar() => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: Colors.grey),
    margin: const EdgeInsets.all(10),
    child: Row(
      children: [
        const Icon(Icons.search),
        Expanded(child: TextField(
          controller: _searchTerm,
          decoration: const InputDecoration(hintText: "Tìm kiếm theo tên hoặc theo số phòng",
              border: InputBorder.none),
        ))
      ],
    ),
  );

  Widget filterButton(){
    final list = ["Tất cả", "Nam", "Nữ"];

    return StatefulBuilder(builder: (_, setState){
      return DropdownButton<String>(
        value: gender.inString(),
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (String? value) {
          switch(value!){
            case "Nam":
              gender = Gender.male;
              break;
            case "Nữ":
              gender = Gender.female;
              break;
            default:
              gender = Gender.all;
              gender = Gender.all;
          }

          RenterDAO.filterRentersBasedOnGenderAndTerm(gender, _searchTerm.text).then((list) =>  this.setState((){
            renters.clear();

            for(var entity in list){
              renters.add(RenterDTO(entity, true));
            }
          }));
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    });
  }

  AlertDialog deleteAlertDialog() => AlertDialog(
    title: const Text("Xóa?"),
    content: const Text("Bạn có muốn xóa những người thuê đã chọn"),
    actions: [
      TextButton(onPressed:(){
        Navigator.pop(context);
        cleanUp(true);
      }, child: const Text("Yes, delete them all!")),
      TextButton(onPressed:(){
        Navigator.pop(context);
      }, child: const Text("No, keep them")),
    ],
  );

  void cleanUp(bool removeChecked) async{
    List<RenterEntity> removedRenters = [];

    for(int i=renters.length-1;i>=0;i--){
      if(renters[i].isChecked && removeChecked){
        removedRenters.add(renters[i].entity);
        renters.removeAt(i);
      }
      else{
        renters[i].isChecked = false;
      }
    }

    setState(() {
      isDeleting = false;
    });

    if(removeChecked){
      RenterDAO.deleteRenters(removedRenters);
      RoomDAO.decrementRoomCurrentStays(removedRenters);

      for(var renter in removedRenters){
        FirebaseStorage.instance.ref().child("${renter.id}.png").delete();
      }
    }
  }
}