import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const localUrl = "http://192.168.0.192:3000";

class SSEWithoutDelayService {
  http.Client? _client;
  static Stream<StreamedResponse>? stream;

  void subscribeNewEvents() {
    String url = "$localUrl/events";

    _client = http.Client();
    var request = http.Request("GET", Uri.parse(url));
    request.headers["Cache-Control"] = "no-cache";
    request.headers["Accept"] = "text/event-stream";

    Future<http.StreamedResponse>? response = _client?.send(request);
    stream = response?.asStream();
  }

  unsubscribe() {
    if (_client != null) {
      _client?.close();
    }
  }
}

class SSEWithDelayService {
  http.Client? _client;
  static Stream<StreamedResponse>? stream;

  void subscribeNewEvents() {
    String url = "$localUrl/eventWithDelay";

    _client = http.Client();
    var request = http.Request("GET", Uri.parse(url));
    request.headers["Cache-Control"] = "no-cache";
    request.headers["Accept"] = "text/event-stream";

    Future<http.StreamedResponse>? response = _client?.send(request);
    stream = response?.asStream();
  }

  unsubscribe() {
    if (_client != null) {
      _client?.close();
    }
  }
}
