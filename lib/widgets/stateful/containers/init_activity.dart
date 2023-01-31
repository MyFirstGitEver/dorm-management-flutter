import 'package:dorm_management/daos/room_initializer_dao.dart';
import 'package:dorm_management/entities/room_initialiser_entity.dart';
import 'package:dorm_management/entities/room_entity.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../stateless/loading_page.dart';
import 'main_activity.dart';

class InitActivity extends StatefulWidget {
  const InitActivity({Key? key}) : super(key: key);

  @override
  State<InitActivity> createState() => _InitActivityState();
}

class _InitActivityState extends State<InitActivity> {
  static final List<String> availableTypes = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  String mode = "loading", chosenType = "1";

  final List<RoomInitializerEntity> roomTypes = [];

  @override
  Widget build(BuildContext context) {
    Widget showPage;

    if(mode == "loading"){
      showPage = const LoadingPage();

      Future.delayed(const Duration(seconds: 2), () async{
        final prefs = await SharedPreferences.getInstance();

        bool? init = prefs.getBool("init");

        if(init == null){
          setState(() {
            mode = "roomType";
          });
        }
        else{
          setState(() {
            mode = "main";
          });
        }
      });
    }
    else if(mode == "roomType" || mode == "capacity"){
      showPage = initPage();
    }
    else{
      showPage = const MainActivity();
    }

    return Scaffold(
      body: showPage,
    );
  }

  Widget initPage() => Scaffold(
    body: mode == "roomType" ? roomTypeStep() : specifyCapacityStep(),
  );

  Widget specifyCapacityStep() => Column(
    children: [
      Expanded(child: ListView.builder(itemBuilder: (_, index) =>
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
          padding: const EdgeInsets.only(bottom: 10),
          margin: const EdgeInsets.only(top:  10, left : 10, right: 10),
          child: Row(mainAxisAlignment : MainAxisAlignment.spaceBetween,
              children: [
                Text("Phòng ${roomTypes[index].capacity} Người. Số lượng :"),
                NumberPicker(minValue : 1, maxValue: 60, value: roomTypes[index].total, onChanged:(value){
                  setState(() {
                    roomTypes[index].total = value;
                  });
                })
          ]),
        ), itemCount: roomTypes.length)
      ),
      TextButton(onPressed:(){
        RoomInitializerDAO.storeInitializers(roomTypes).then((done){
          setState((){
            mode = "main";
          });

          SharedPreferences.getInstance().then((prefs) => prefs.setBool("init", true));
        });
      }, child: const Text("Hoàn tất"))
    ],
  );

  Widget roomTypeStep() => Column(
    children: [
      const Text("Dorm management", style: TextStyle(color: Colors.blue)),

      const SizedBox(height: 30), // divider

      SizedBox(width : 60, height : 60, child: Image.asset("images/hall.png")),

      const SizedBox(height: 40), //divider

      const Text("Chọn các loại phòng nhà trọ bạn hiện có",
          style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold)),
      roomCapacityDropdownButton(),

      const SizedBox(height: 30), //divider

      Expanded(
          child: ListView.builder(
            itemBuilder: (_, index) => SizedBox(child: Align(alignment: Alignment.center,
                child: roomType(roomTypes[index].capacity.toString()))),
            itemCount: roomTypes.length,
          )
      ),
      TextButton(onPressed:(){
        setState(() {
          mode = "capacity";
        });
      }, child: const Text("Xác nhận"))
    ],
  );

  Widget roomType(String type) => Container(margin : const EdgeInsets.all(8),
      padding : const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: Colors.grey),
      child: Stack(children: [
        const Positioned(right : 0, top : 0, child: Icon(Icons.close, size: 10,)),
        Text("$type Người")
      ])
  );

  Widget roomCapacityDropdownButton() => DropdownButton<String>(
    value: chosenType,
    elevation: 16,
    style: const TextStyle(color: Colors.deepPurple),
    onChanged: (String? value) {
      setState(() {
        chosenType = value!;
      });

      if(roomTypes.where((type) => type.capacity == int.parse(value!)).isEmpty){
        roomTypes.add(RoomInitializerEntity(int.parse(value!), 1));
      }
    },
    items: availableTypes.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}