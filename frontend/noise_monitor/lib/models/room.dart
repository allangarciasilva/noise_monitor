import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Room {
  String name;
  int id;
  bool editable;
  int activeDevices;

  Room({
    required this.name,
    required this.id,
    required this.editable,
    required this.activeDevices,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
