part of 'server.dart';

Map<String, List<Player>> gameSession = {};

// CORS Settings
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
  "content-type": 'application/json'
};

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
    jsonEncode('${req.requestedUri.host}:${req.requestedUri.port}/add/$id/'),
    headers: corsHeaders,
  );
}

Future<Response> playerLandingHandler(Request request) async {
  final id = request.params['id'];
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  // gameSession[id]!.add(Player(timeCreated: DateTime.now()));
  // Future.delayed(
  //   Duration(minutes: 5),
  //   () => gameSession.remove(id),
  // );

  return Response.ok(
    await File('${Directory.current.path}/public/index.html').readAsString(),
    headers: {"content-type": 'text/html'},
  );
}

Future<Response> nameHandler(Request req, String id) async {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");
  if (gameSession[id] == null) return Response.notFound("Game not found");
  List<Player> list = gameSession[id]!;
  if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  final String query = await req.readAsString();
  // var querySplit = query.split("&");
  //querySplit[0].substring(5); //name=nightcap79&answer=hackerone
  // querySplit[1].substring(7);
  Map queryParams = Uri(query: query).queryParameters; // {name: nightcap79, answer: hackerone}
  if (!queryParams.containsKey("name")) {
    return Response.badRequest(body: 'Test OK\n');
  }
  var name = queryParams["name"];
  for (var i = 0; i < list.length; i++) {
    if (name == list[i].name) {
      name = "$name${DateTime.now().millisecondsSinceEpoch}";
      gameSession[id]!.add(Player(name: name));

      return Response(401, body: jsonEncode(name));
    }
  }

  gameSession[id]!.add(Player(name: name));

  return Response.ok(
    jsonEncode('Your game id is $id  \nname=$name'),
    headers: corsHeaders,
  );
}

Future<Response> answerHandler(Request req, String id) async {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");
  if (gameSession[id] == null) return Response.notFound("Game not found");
  List<Player> list = gameSession[id]!;
  if (req.method != "POST") return Response.badRequest(body: 'Test OK\n');
  final String query = await req.readAsString();
  // var querySplit = query.split("&");
  //querySplit[0].substring(5); //name=nightcap79&answer=hackerone
  // querySplit[1].substring(7);

  Map queryParams = Uri(query: query).queryParameters; // {name: nightcap79, answer: hackerone}
  if (!queryParams.containsKey("name") || !queryParams.containsKey("answer")) {
    return Response.badRequest(body: 'Test OK\n');
  }
  var name = queryParams["name"];
  for (var i = 0; i < list.length; i++) {
    if (name == list[i].name && (list[i].answer != null)) {
      return Response(401, body: "Game not Started Yet");
    }
  }
  var answer = queryParams["answer"];
  int now = DateTime.now().millisecondsSinceEpoch;

  list.firstWhere(
    (e) => e.name == name,
  )
    ..answer = answer
    ..timeOfSubmittion = now;

  return Response.ok(
    jsonEncode('Your game id is $id  \nname=$name  answer=$answer submissionTime=$now'),
    headers: corsHeaders,
  );
}

Response getResultHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  return Response.ok(
    jsonEncode(gameSession[id]),
    headers: corsHeaders,
  );
}

Response getUsersResultHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  return Response.ok(
    jsonEncode(gameSession[id]!
        .map(
          (e) => e.name,
        )
        .toList()),
    headers: corsHeaders,
  );
}

Response continueGameHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");

  var list = gameSession[id];

  for (var i = 0; i < list!.length; i++) {
    list[i].answer = null;
  }

  return Response.ok(
    jsonEncode('Ready for getting Answers'),
    headers: corsHeaders,
  );
}

Response deleteGameHandler(Request req, String id) {
  if (!gameSession.containsKey(id)) return Response.notFound("Game not found");
  gameSession.remove(id);
  return Response.ok(
    jsonEncode('Deleted'),
    headers: corsHeaders,
  );
}
