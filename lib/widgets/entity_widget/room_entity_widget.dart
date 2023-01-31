import 'package:dorm_management/entities/room_entity.dart';
import 'package:dorm_management/widgets/stateful/dialogs/room_info_dialog.dart';
import 'package:flutter/material.dart';

final buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.transparent,
  elevation: 0,
  foregroundColor: Colors.blue
);

class RoomEntityWidget extends StatelessWidget {
  final RoomEntity room;

  const RoomEntityWidget({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (_, setState) => Scaffold(
            body: Container(
                decoration: BoxDecoration(border: Border.all()),
                constraints: const BoxConstraints.expand(),
                margin: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => RoomInfoDialog(room: room)).then((result) => setState(() {})),
                    style: buttonStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            "Phòng ${room.id == -1 ? "trống" : room.id}(${room.currentStays}/${room.capacity})",
                            style: const TextStyle(color: Colors.black)),
                        currentStaysDisplay()
                      ],
                    )))));
  }

  Widget currentStaysDisplay(){
    var peopleDisplay = <Widget>[];

    for(int i=0;i<room.capacity;i++){
      if(i >= room.currentStays){
        peopleDisplay.add(personDisplay(true));
      }
      else{
        peopleDisplay.add(personDisplay(false));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: peopleDisplay,
    );
  }

  Widget personDisplay(bool occupied){
    return Row(
      children: [
        SizedBox(width : 80 / room.capacity,
            height : 15, child: Image.asset(occupied ? "images/person.png" : "images/blue_person.png")),
        const SizedBox(width: 10)
      ],
    );
  }
}