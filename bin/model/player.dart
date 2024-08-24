// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Player {
  String? name;
  String? answer;
  // DateTime timeCreated;
  int? timeOfSubmittion;
  Player({
    this.answer,
    this.name,
    this.timeOfSubmittion,
    // required this.timeCreated,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'answer': answer,
      'timeOfSubmittion': timeOfSubmittion,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'] != null ? map['name'] as String : null,
      answer: map['answer'] != null ? map['answer'] as String : null,
      timeOfSubmittion: map['timeOfSubmittion'] != null ? map['timeOfSubmittion'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Player other) {
    if (identical(this, other)) return true;

    return other.name == name;
  }

  @override
  int get hashCode => name.hashCode ^ answer.hashCode ^ timeOfSubmittion.hashCode;
}
