import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dorm_management/dtos/file_result.dart';
import 'package:dorm_management/entities/renter_entity.dart';
import 'package:dorm_management/widgets/stateful/screens/take_picture_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../tools.dart';

class RenterEditor extends StatefulWidget {
  final RenterEntity renter;
  final Function(FileResult) loadNewImage;

  const RenterEditor({Key? key, required this.renter, required this.loadNewImage}) : super(key: key);

  @override
  State<RenterEditor> createState() => _RenterEditorState();
}

class _RenterEditorState extends State<RenterEditor> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phoneNumber;

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _phoneNumber = TextEditingController();

    _name.text = widget.renter.name;
    _email.text = widget.renter.email;
    _phoneNumber.text = widget.renter.phoneNumber;

    _name.addListener(() {
      widget.renter.name = _name.text;
    });

    _email.addListener(() {
      widget.renter.email = _email.text;
    });

    _phoneNumber.addListener(() {
      widget.renter.phoneNumber = _phoneNumber.text;
    });

    super.initState();
  }


  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(hintText: "Họ và tên"),
        ),
        TextField(
          controller: _email,
          decoration: const InputDecoration(hintText: "Email"),
        ),
        TextField(
          controller: _phoneNumber,
          decoration: const InputDecoration(hintText: "Số điện thoại"),
        ),
        Row(mainAxisAlignment : MainAxisAlignment.center, children: [
          const Text("Nam giới"),
          const SizedBox(width: 10),
          Switch(
            // This bool value toggles the switch.
            value: widget.renter.isMale,
            activeColor: Colors.red,
            onChanged: (bool value) {
              // This is called when the user toggles the switch.
              setState(() {
                widget.renter.isMale = value;
              });
            },
          ),
        ]),
        TextButton(onPressed:(){
          if(!kIsWeb){
            openCamera(widget.renter.id);
          }
          else{
            Tools.pickAFile().then((result){
              if(result != null){
                widget.loadNewImage(result);
              }
            });
          }
        }, child: const Text("Chọn ảnh khác"))
      ],
    );
  }

  void openCamera(int renterId) async{
    var cameras = await availableCameras();

    final firstCamera = cameras.first;

    showDialog(context: context, builder: (_) => TakePictureScreen(camera: firstCamera, renterId: renterId))
      .then((image){
        if(image != null){
          var result = FileResult("$renterId", ".png");
          result.data = image;

          widget.loadNewImage(result);
        }
    });
  }
}