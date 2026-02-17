import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

@JsonSerializable()
class RegisterRequestDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;

  RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}