import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:googleapis_auth/auth_io.dart' as auth;



Future<String> _getAccessToken() async {
  final file = File('lib/credentials/firebase_service_account.json');

  if (!await file.exists()) {
    throw Exception('Service account JSON file not found.');
  }

  final serviceAccountJson = json.decode(await file.readAsString());

  final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final client = await auth.clientViaServiceAccount(credentials, scopes);

  final accessToken = client.credentials.accessToken.data;

  client.close();

  return accessToken;
}
Future<void> sendNotification(String token, String title, String body) async {
  const fcmUrl = 'https://fcm.googleapis.com/v1/projects/inventory-4f728/messages:send';

  final String accessToken = await _getAccessToken();

  final payload = {
    'message': {
      'notification': {
        'title': title,
        'body': body,
      },
      'token': token,

    },
  };

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200) {
    throw Exception('Error sending notification: ${response.statusCode}');
  }
}

void main() async {
  final router = Router();

  router.post('/send-notification', (Request request) async {
    final payload = json.decode(await request.readAsString());
    final token = payload['token'];
    final title = payload['title'];
    final body = payload['body'];

    try {
      await sendNotification(token, title, body);
      return Response.ok('Notification sent successfully');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  });

  final handler = const Pipeline().addHandler(router.call);

  final server = await shelf_io.serve(handler, 'localhost', 3000);
  print('Server running on http://${server.address.host}:${server.port}');
}
