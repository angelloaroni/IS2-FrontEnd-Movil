import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/services/api_service.dart';
import 'package:http/http.dart' as http;

class DelayedBodyClient extends http.BaseClient {
  final body = StreamController<List<int>>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(body.stream, 200);
}

void main() {
  testWidgets(
    'times out the full response and identifies the server and path',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token'});
      final client = DelayedBodyClient();
      final service = http.runWithClient(
        () => ApiService.instance,
        () => client,
      );
      Object? failure;
      final request = service
          .get('/usuarios')
          .then<void>(
            (_) => fail('A stalled body must time out'),
            onError: (Object error) {
              failure = error;
            },
          );
      await tester.pump();
      await tester.pump(const Duration(seconds: 19));
      expect(failure, isNull);
      await tester.pump(const Duration(seconds: 1));
      await request;
      expect(failure, isA<ApiException>());
      expect('$failure', contains('GET http://localhost:3000/api/usuarios'));
      expect('$failure', contains('20 segundos'));

      // Complete the underlying stream after the deadline; it must not replace
      // the timeout with a late successful result.
      client.body.add(utf8.encode('{"ok":true,"data":{}}'));
      unawaited(client.body.close());
      await tester.pump();
      expect(failure, isA<ApiException>());
    },
  );
}
