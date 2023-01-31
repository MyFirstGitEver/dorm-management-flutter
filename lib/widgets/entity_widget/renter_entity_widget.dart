import 'package:dorm_management/entities/renter_entity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RenterEntityWidget extends StatefulWidget {
  final RenterEntity renter;

  const RenterEntityWidget({Key? key, required this.renter}) : super(key: key);

  @override
  State<RenterEntityWidget> createState() => _RenterEntityWidgetState();
}

class _RenterEntityWidgetState extends State<RenterEntityWidget> {
  late final Future<String> fetchImageURL;

  @override
  void initState() {
    var storage = FirebaseStorage.instance.ref().child("${widget.renter.id}.png");
    fetchImageURL = storage.getDownloadURL();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom:  10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<String>(
              future: fetchImageURL,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  return SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(snapshot.data!));
                } else {
                  return SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset("images/hall.png"));
                }
              }),
          const SizedBox(height: 15),
          Text(widget.renter.getInfoInString(),
              style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}