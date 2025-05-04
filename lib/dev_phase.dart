import 'package:flutter/material.dart';

class DevelopmentPhasePage extends StatelessWidget {
  const DevelopmentPhasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Under Development',style: TextStyle(color: Colors.red),),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'This feature is currently under development.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DevelopmentPhasePage(),
  ));
}
