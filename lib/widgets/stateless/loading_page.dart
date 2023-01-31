import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Đang tải..."),
            const SizedBox(height: 30),
            SizedBox(width : 70,
                height : 70,
                child: Image.asset("images/hall.png")),
            const SizedBox(height: 30),
            const Text("Dorm  management", style: TextStyle(color: Colors.blue, fontSize: 19))
          ],
        ),
      ),
    );
  }
}