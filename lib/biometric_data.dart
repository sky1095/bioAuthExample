import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:biometric_storage/biometric_storage.dart';

class BioMetericHome extends StatefulWidget {
  @override
  _BioMetericHomeState createState() => _BioMetericHomeState();
}

class _BioMetericHomeState extends State<BioMetericHome> {
  BiometricStorageFile _authStorage;
  static const String baseName = 'secureFile';

  final TextEditingController _writeController =
  TextEditingController(text: 'top secret password');

  String result = '';

  Future<CanAuthenticateResponse> _checkAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    log('checked if authentication was possible: $response');
    return response;
  }

  Future<void> getStorageData() async {
    _authStorage = await BiometricStorage().getStorage(
        '${baseName}_customPrompt',
        options:
        StorageFileInitOptions(authenticationValidityDurationSeconds: 30),
        androidPromptInfo: const AndroidPromptInfo(
          title: 'Authorise Biometric Scan',
          subtitle: 'Please authorise to continue',
          description: 'This authorisation is for ',
          negativeButton: 'Nope!',
        ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bio Auth'),
        ),
        body: Center(
          child: FutureBuilder<CanAuthenticateResponse>(
              future: _checkAuthenticate(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed:
                        snapshot.data == CanAuthenticateResponse.success
                            ? getStorageData
                            : null,
                        child: const Text('Allow Me'),
                      ),
                      if (_authStorage != null)
                        StorageActions(
                          storageFile: _authStorage,
                          writeController: _writeController,
                        ),
                    ],
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
    @required this.storageFile,
    @required this.writeController,
  }) : super(key: key);

  final BiometricStorageFile storageFile;
  final TextEditingController writeController;

  @override
  _StorageActionsState createState() => _StorageActionsState();
}

class _StorageActionsState extends State<StorageActions> {
  String result = '';

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
                log('reading from ${widget.storageFile.name}');
                result = await widget.storageFile.read();
                log('read: {$result}');
                setState(() {});
              },
            ),
            ElevatedButton(
              child: const Text('write'),
              onPressed: () async {
                log('Going to write...');
                await widget.storageFile.write(
                    ' [${DateTime.now()}] ${widget.writeController.text}');
                log('Written content.');
              },
            ),
            ElevatedButton(
              child: const Text('delete'),
              onPressed: () async {
                log('deleting...');
                await widget.storageFile.delete();
                log('Deleted.');
              },
            ),
          ],
        ),
      ],
    );
  }
}
