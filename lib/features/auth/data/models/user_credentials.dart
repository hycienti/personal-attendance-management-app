import 'package:equatable/equatable.dart';

/// Credentials for login. Replace with secure storage when integrating API.
class UserCredentials extends Equatable {
  const UserCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
