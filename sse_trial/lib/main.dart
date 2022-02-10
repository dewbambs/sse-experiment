import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sse_trial/sse_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SSEWithoutDelayPage(title: 'SSE Without Delay'),
    );
  }
}

// ======================================================================
// SSE without delay
//
// the flushheader is triggered as soon as client calls the API from backend.
// Hence when _client.close() is called the SSE event stops immediately.
// and server triggers relevant function and releases the server resource, example shown below
//
// ```
// res.socket.on('end', e => {
//     console.log('event source closed');
// });
// ```
// ======================================================================
class SSEWithoutDelayPage extends StatefulWidget {
  const SSEWithoutDelayPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SSEWithoutDelayPage> createState() => _SSEWithoutDelayPageState();
}

class _SSEWithoutDelayPageState extends State<SSEWithoutDelayPage> {
  String data = "start sse without delay";
  late SSEWithoutDelayService sse;
  StreamSubscription<StreamedResponse>? stream;

  @override
  void initState() {
    super.initState();
    sse = SSEWithoutDelayService();
  }

  void _startCounter() async {
    sse.unsubscribe();
    sse.subscribeNewEvents();

    setState(() {
      data = "start sse without delay";
    });

    stream = SSEWithoutDelayService.stream?.listen((event) {
      event.stream.listen((value) {
        var output = utf8.decode(value);

        setState(() {
          data = output;
        });
      });
    });
  }

  void _stopCounter() {
    setState(() {
      data = "reset complete";
    });

    stream?.cancel();
    sse.unsubscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              data,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sse.unsubscribe();

                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SSEWithDelayPage()));
              },
              child: const Text("Go to SSE with delay Screen"),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        children: [
          const Spacer(),
          FloatingActionButton(
            onPressed: _startCounter,
            tooltip: 'Start',
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _stopCounter,
            tooltip: 'Stop',
            child: const Icon(Icons.stop),
          )
        ],
      ),
    );
  }
}

// ======================================================================
// SSE with delay
//
// the flushheader is triggered after 10 seconds when client calls the API from backend.
//
// the client do not receive the headers, hence client keeps the call as PENDING for 10s.
// If _client.close() is called in PENDING state the _client do not closes the sse at server level.
//
// After 10s when the API headers are flushed or if we have received first data from server
// then _client.close() stops SSE event immediately.
// and server triggers relevant function and releases the server resource, example shown below
//
// ```
// res.socket.on('end', e => {
//     console.log('event source closed');
// });
// ```
// ======================================================================
class SSEWithDelayPage extends StatefulWidget {
  const SSEWithDelayPage({Key? key}) : super(key: key);

  @override
  State<SSEWithDelayPage> createState() => _SSEWithDelayPageState();
}

class _SSEWithDelayPageState extends State<SSEWithDelayPage> {
  String data = "start sse with delay";
  SSEWithDelayService sse = SSEWithDelayService();
  StreamSubscription<StreamedResponse>? stream;

  void _startCounter() async {
    sse.unsubscribe();
    sse.subscribeNewEvents();

    setState(() {
      data = "start sse with delay";
    });

    stream = SSEWithDelayService.stream?.listen((event) {
      event.stream.listen((value) {
        var output = utf8.decode(value);

        setState(() {
          data = output;
        });
      });
    });
  }

  void _stopCounter() {
    setState(() {
      data = "reset complete";
    });

    stream?.cancel();
    sse.unsubscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SSE with Delay"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              data,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        children: [
          const Spacer(),
          FloatingActionButton(
            onPressed: _startCounter,
            tooltip: 'Start',
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _stopCounter,
            tooltip: 'Stop',
            child: const Icon(Icons.stop),
          )
        ],
      ),
    );
  }
}
