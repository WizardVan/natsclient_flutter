import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dart_nats/dart_nats.dart' as nats;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final natsC = nats.Client();
  late nats.Subscription fooSub;
  final messageController = TextEditingController();

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    natsC.connect(Uri.parse('nats://localhost:4222'));
    fooSub = natsC.sub('SonarBackendOutChannel');
  }

  @override
  void dispose() {
    natsC.close();
    super.dispose();
  }

  void sendMessage() {
    natsC.pubString('SonarBackendInChannel', messageController.text);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('foo message:'),
            StreamBuilder(
              stream: fooSub.stream,
              builder: (context, AsyncSnapshot<nats.Message> snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data!.string}' : '');
              },
            ),
            TextField(
              controller: messageController,
            ),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
