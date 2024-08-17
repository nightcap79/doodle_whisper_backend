part of 'server.dart';

Map<String, List<Player>> gameSession = {};

var static = createStaticHandler('public', defaultDocument: 'index.html', serveFilesOutsidePath: true); //

Response rootHandler(Request req) {
  return Response.ok(
    '<html><h1>Hello, World!</h1></html>',
    headers: {"content-type": 'text/html'}, // text/html   text/plain    application/json  text/javascript
  );
}

Response newHandler(Request req) {
  // if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  int id = DateTime.now().millisecondsSinceEpoch;

  gameSession['$id'] = [];
  return Response.ok(
    '${req.requestedUri.host}:${req.requestedUri.port}/add/$id/',
    headers: {"content-type": 'text/plain'},
  );
}

Future<Response> addPlayerHandler(Request request) async {
  final id = request.params['id'];
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  // gameSession[id]!.add(Player(timeCreated: DateTime.now()));
  Future.delayed(
    Duration(minutes: 5),
    () => gameSession.remove(id),
  );

  return Response.ok(
    await File('${Directory.current.path}/public/index.html').readAsString(),
    headers: {"content-type": 'text/html'},
  );
}

Future<Response> answerHandler(Request req, String id) async {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");
  final String query = await req.readAsString();
  // var querySplit = query.split("&");
  //querySplit[0].substring(5); //name=nightcap79&answer=hackerone
  // querySplit[1].substring(7);
  Map queryParams = Uri(query: query).queryParameters; // {name: nightcap79, answer: hackerone}

  if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  var name = queryParams["name"];
  var answer = queryParams["answer"];
  int now = DateTime.now().millisecondsSinceEpoch;

  gameSession[id]!.add(Player(timeOfSubmittion: now, answer: answer, name: name));

  return Response.ok(
    'Your game id is $id  \nname=$name  answer=$answer submissionTime=$now',
    headers: {"content-type": 'text/plain'},
  );
}

Response getResultHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  return Response.ok(
    jsonEncode(gameSession[id]),
    headers: {"content-type": 'application/json'},
  );
}
