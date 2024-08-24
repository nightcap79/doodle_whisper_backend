import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'model/player.dart';

part 'handles.dart';

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await createServer(ip, port);
  print('Server listening on port ${server.port}');
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(createStaticHandler("public")).add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()..mount('/', (context) => buildHandler()(context));
  return pipeline.addHandler(router.call);
}

Handler buildHandler() {
  final pipeline = const Pipeline().addMiddleware(logRequests());
  final router = Router()
    ..get('/', rootHandler)
    ..get('/new', newHandler)
    ..get('/add/<id>/', playerLandingHandler) //_addPlayerHandler
    ..post('/add/<id>/submitName', nameHandler) // ?name=<name>&answer=<answer>
    ..post('/add/<id>/submitAnswer', answerHandler) // ?name=<name>&answer=<answer>
    ..get('/new/<id>/', continueGameHandler)
    ..get('/get/<id>/', getResultHandler)
    ..get('/getUsers/<id>/', getUsersResultHandler)
    ..delete('/<id>/', deleteGameHandler);
  return pipeline.addHandler(router.call);
}
