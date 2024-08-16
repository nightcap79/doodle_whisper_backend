import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'model/player.dart';

part 'handles.dart';

// Configure routes.
final _router = Router()
  ..get('/', static)
  ..get('/test', static)
  ..get('/new', newHandler)
  ..get('/add/<id>/', addPlayerHandler) //_addPlayerHandler
  ..post('/add/<id>/submit', answerHandler) // ?name=<name>&answer=<answer>
  ..get('/get/<id>/', getResultHandler);

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // final handler = Cascade().add(_router.call).add(static).handler;

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
