import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'model/player.dart';

Map<String, List<Player>> gameSession = {};
// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/new', _newHandler)
  ..get('/add/<id>/', _addPlayerHandler)
  ..post('/add/<id>/submit', _answerHandler) // ?name=<name>&answer=<answer>
  ..get('/get/<id>/', _getResultHandler);

Response _rootHandler(Request req) {
  return Response.ok(
    '<html><h1>Hello, World!</h1></html>',
    headers: {
      "content-type": 'text/html'
    }, // text/html   text/plain    application/json  text/javascript
  );
}

Response _newHandler(Request req) {
  // if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  int id = DateTime.now().millisecondsSinceEpoch;

  gameSession['$id'] = [];
  return Response.ok(
    'https://vigilant-capybara-5g564qvjfpg9r-8080.app.github.dev/add/$id/',
    headers: {"content-type": 'text/plain'},
  );
}

Future<Response> _addPlayerHandler(Request request) async {
  final id = request.params['id'];
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  // gameSession[id]!.add(Player(timeCreated: DateTime.now()));
  Future.delayed(
    Duration(minutes: 2),
    () => gameSession.remove(id),
  );
  return Response.ok(
    await File('${Directory.current.path}/html/input.html').readAsString(),
    headers: {"content-type": 'text/html'},
  );
}

Future<Response> _answerHandler(Request req, String id) async {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");
  final String query = await req.readAsString();
  // var querySplit = query.split("&");
  //querySplit[0].substring(5); //name=nightcap79&answer=hackerone
  // querySplit[1].substring(7);
  Map queryParams = Uri(query: query)
      .queryParameters; // {name: nightcap79, answer: hackerone}

  if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  var name = queryParams["name"];
  var answer = queryParams["answer"];
  int now = DateTime.now().millisecondsSinceEpoch;

  gameSession[id]!
      .add(Player(timeOfSubmittion: now, answer: answer, name: name));

  return Response.ok(
    'Your game id is $id  \nname=$name  answer=$answer submissionTime=$now',
    headers: {"content-type": 'text/plain'},
  );
}

Response _getResultHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  return Response.ok(
    jsonEncode(gameSession[id]),
    headers: {"content-type": 'application/json'},
  );
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
