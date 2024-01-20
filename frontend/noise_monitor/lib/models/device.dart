import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable(fieldRename:FieldRename.snake)
class Device {
  int id;
  int roomId;
  String name;
  bool active;

  Device({
    required this.id,
    required this.roomId,
    required this.name,
    required this.active,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
