import 'package:dorm_management/dtos/file_dto.dart';
import 'package:dorm_management/entities/file_entity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FileEntityWidget extends StatefulWidget {
  final FileDTO dto;

  const FileEntityWidget({Key? key, required this.dto}) : super(key: key);

  @override
  State<FileEntityWidget> createState() => _FileEntityWidgetState();
}

class _FileEntityWidgetState extends State<FileEntityWidget> {
  Future<String>? fetchImage;

  @override
  void initState() {
    super.initState();

    refreshState();
  }

  @override
  void didUpdateWidget(covariant FileEntityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(!widget.dto.isNew){
      return;
    }

    widget.dto.isNew = false;
    refreshState();
  }

  void refreshState(){
    FileEntity file = widget.dto.entity;
    if(file.extension == ".png" || file.extension == ".jpg"){
      if(widget.dto.isRenterPic){
        fetchImage = FirebaseStorage.instance.ref().child("${file.name}${file.extension}")
            .getDownloadURL();
      }
      else{
        fetchImage = FirebaseStorage.instance.ref().child("document/${file.name}${file.extension}")
            .getDownloadURL();
      }
    }
    else{
      fetchImage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.dto.entity;

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          FutureBuilder<String>(future: fetchImage, builder: (_, snapshot) {
            if(snapshot.data != null && snapshot.connectionState == ConnectionState.done){
              return SizedBox(width : 80, height : 80, child: Image.network(snapshot.data!));
            }
            else{
              return !FileEntity.folderIds.contains(file.id)
                  ? const Icon(Icons.file_copy_outlined, size: 40)
                  : const Icon(Icons.folder, size: 40);
            }
          }),
          const SizedBox(width: 10),
          Flexible(child: Text(file.alias != null ? file.alias! : "${file.name}${file.extension}",
              style: const TextStyle(color: Colors.black)))
        ],
      ),
    );
  }
}