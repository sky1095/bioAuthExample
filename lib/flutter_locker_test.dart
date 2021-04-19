import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:flutter_locker/flutter_locker.dart';

class FlutterLockerTest extends StatefulWidget {
  @override
  _FlutterLockerTestState createState() => _FlutterLockerTestState();
}

class _FlutterLockerTestState extends State<FlutterLockerTest> {
  final TextEditingController _writeController =
      TextEditingController(text: 'top secret password');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bio Auth'),
        ),
        body: Center(
          child: FutureBuilder<bool>(
              future: FlutterLocker.canAuthenticate(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return StorageActions(
                    writeController: _writeController,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }
}

class StorageActions extends StatefulWidget {
  const StorageActions({
    Key key,
    @required this.writeController,
  }) : super(key: key);

  final TextEditingController writeController;

  @override
  _StorageActionsState createState() => _StorageActionsState();
}

class _StorageActionsState extends State<StorageActions> {
  String result = '';

  static const String key = 'secureFile';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          color: Colors.amber,
          child: Center(
            child: Text(
              result ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              child: const Text('read'),
              onPressed: () async {
                log('reading ');
                result = await FlutterLocker.retrieve(
                  RetrieveSecretRequest(
                    key,
                    AndroidPrompt('Authenticate', 'Cancel'),
                    IOsPrompt('Authenticate'),
                  ),
                );
                log('read: {$result}');
                setState(() {});
              },
            ),
            ElevatedButton(
              child: const Text('write'),
              onPressed: () async {
                log('Going to write...');
                await FlutterLocker.save(
                  SaveSecretRequest(
                    key,
                    '[${DateTime.now()}] ${widget.writeController.text}',
                    AndroidPrompt("Authenticate", "Cancel"),
                  ),
                );
                log('Written content.');
              },
            ),
            ElevatedButton(
              child: const Text('delete'),
              onPressed: () async {
                log('deleting...');
                await FlutterLocker.delete(key);
                log('Deleted.');
              },
            ),
          ],
        ),
      ],
    );
  }
}
