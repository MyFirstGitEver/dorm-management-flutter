import 'dart:io';
import 'dart:typed_data';

import 'package:dorm_management/daos/file_dao.dart';
import 'package:dorm_management/daos/renter_dao.dart';
import 'package:dorm_management/entities/file_entity.dart';
import 'package:dorm_management/widgets/stateful/others/sliding_window.dart';
import 'package:dorm_management/widgets/tools.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../../dtos/file_dto.dart';
import '../../../entity_widget/file_entity_widget.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  List<FileDTO> files = [];
  FileEntity currentFolder = FileEntity(-1, "Thư mục chính", "", null);

  bool isOpeningOptions = false;

  @override
  void initState() {
    files.add(FileDTO(FileEntity(0, "Sẵn có", "", null), false));
    files.add(FileDTO(FileEntity(1, "Khác", "", null), false));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          Container(
              decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey, width: 1))),
              width: double.infinity,
              margin: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(onPressed:(){
                        if(currentFolder.id == -1){
                          return;
                        }

                        backToMain();
                      }, icon: const Icon(Icons.arrow_back)),
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(currentFolder.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  TextButton(
                      onPressed: () {
                        if(currentFolder.id != -1 && currentFolder.id != 0){
                          isOpeningOptions = !isOpeningOptions;

                          if(!isOpeningOptions){
                            cleanUp(false, false);
                          }
                          setState(() {});
                        }
                      },
                      child: const Text("Sửa",
                          style: TextStyle(color: Colors.black)))
                ],
              )),
          Expanded(
              child: ListView.builder(
                  itemBuilder: (_, index) => index < files.length ? animatingFileWidget(index) : addMoreFilesButton(),
                  itemCount: currentFolder.id == 1 ? files.length + 1 : files.length))
        ],
      ), Visibility(visible: isOpeningOptions,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: isOpeningOptions,
              child: SlidingWindow(toast: buttonsRow()))
    ]));
  }

  Widget buttonsRow() => Container(
    height: 100,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: ElevatedButton(
                style: boxStyle,
                onPressed: () {
                  cleanUp(true, false);
                },
                child: Column(
                  children: const [
                    Icon(Icons.delete),
                    Text("Xóa")
                  ],
                )
            )
        ),
        Expanded(
            child: ElevatedButton(
                style: boxStyle,
                onPressed: () {
                  cleanUp(false, true);
                },
                child: Column(
                  children: const [
                    Icon(Icons.share),
                    Text("Chia sẻ")
                  ],
                ))),
      ],
    ),
  );

  Widget animatingFileWidget(int index) => Row(
    children: [
      Visibility(
          visible: isOpeningOptions,
          maintainSize: isOpeningOptions,
          maintainState: true,
          maintainAnimation: true,
          child: Checkbox(
              value: files[index].isChecked,
              onChanged: (value) {
                setState(() {
                  files[index].isChecked = value!;
                });
              })),
      const SizedBox(width: 15),
      Expanded(
          child: ElevatedButton(
              onPressed: () {
                FileEntity entity = files[index].entity;

                if (entity.id == 0 || entity.id == 1) {
                  openFolder(entity);
                }
                else{
                  openFileInWeb(entity);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.grey,
                  elevation: 0),
              child: FileEntityWidget(dto: files[index])))
    ],
  );

  Widget addMoreFilesButton() => ElevatedButton(onPressed:(){
    Tools.pickAFile().then((result){
      if(result == null){
        return;
      }

      var entity = result.toFileEntity();

      setState(() {
        files.add(FileDTO(entity, false));
      });

      FileDAO.insertNewFile(entity);

      SettableMetadata metadata;
      if(result.extension == ".doc") {
        metadata = SettableMetadata(contentType: "application/ms");
      }
      else if(result.extension == ".pdf"){
        metadata = SettableMetadata(contentType: "application/pdf");
      }
      else{
        metadata = SettableMetadata(contentType: "image/${result.extension.substring(1)}");
      }

      var storage =
        FirebaseStorage.instance.ref().child("document/${result.name}${result.extension}");

      if(result.data != null){
        storage.putData(result.data!, metadata);
      }
      else{
        storage.putFile(result.dataFile!, metadata);
      }
    });
  }, child: Row(
    children: const [
      Icon(Icons.add),
      SizedBox(width: 15),
      Text("Thêm tài liệu")
    ],
  ));


  void openFolder(FileEntity entity) async{
    if(entity.id == 0){
      var allRenters = await RenterDAO.filterRentersBasedOnGenderAndTerm(Gender.all, "");

      setState((){
        currentFolder = entity;
        files.clear();

        for(var renter in allRenters){
          files.add(FileDTO(FileEntity(-1, "${renter.id}", ".png", renter.name), true));
        }
      });
    }
    else{
      var files = await FileDAO.getAllSavedFiles();

      setState(() {
        currentFolder = entity;
        this.files.clear();

        for(FileEntity file in files){
          this.files.add(FileDTO(file, false));
        }
      });
    }
  }

  openFileInWeb(FileEntity file) async{
    if(file.extension == '.doc'){
      var url = await
        FirebaseStorage.instance.ref().child("document/${file.name}${file.extension}").getDownloadURL();

      debugPrint(url);
      bool successful = await launchUrl(Uri.parse("https://drive.google.com/viewerng/viewer?embedded=true&url=${Uri.encodeComponent(url)}"));

      if(!successful){
        debugPrint("Something goes wrong!");
      }
    }
  }

  void backToMain(){
    setState(() {
      currentFolder =  FileEntity(-1, "Thư mục chính", "", null);

      files.clear();
      files.add(FileDTO(FileEntity(0, "Sẵn có", "", null), false));
      files.add(FileDTO(FileEntity(1, "Khác", "", null), false));
    });

    cleanUp(false, false);
  }

  void cleanUp(bool removeChecked, bool sharingChecked) async{
    List<FileEntity> removedFiles = [];

    for(int i=files.length-1;i>=0;i--){
      if(files[i].isChecked && removeChecked){
        removedFiles.add(files[i].entity);
        files.removeAt(i);
      }
      else if(files[i].isChecked && sharingChecked){
        removedFiles.add(files[i].entity);
        files[i].isChecked = false;
      }
      else{
        files[i].isChecked = false;
      }
    }

    setState(() {
      isOpeningOptions = false;
    });

    if(removeChecked){
      await FileDAO.deleteFiles(removedFiles);

      for(var file in removedFiles){
        FirebaseStorage.instance.ref().child("document/${file.name}${file.extension}").delete();
      }
    }

    if(sharingChecked){
      var sharedFiles = <XFile>[];

      for(var file in removedFiles){
        String mimeType;

        if(file.extension == ".jpg"){
          mimeType = "image/jpeg";
        }
        else if(file.extension == ".png"){
          mimeType = "image/png";
        }
        else{
          mimeType = "application/msword";
        }

        var downloaded = await downloadFile("document/${file.name}${file.extension}");
        sharedFiles.add(XFile.fromData(downloaded!, mimeType: mimeType));
      }

      Share.shareXFiles(sharedFiles, text : "Chia sẻ từ nhà trọ");
    }
  }

  Future<Uint8List?> downloadFile(String path){
    var storage = FirebaseStorage.instance.ref().child(path);

    return storage.getData();
  }
}