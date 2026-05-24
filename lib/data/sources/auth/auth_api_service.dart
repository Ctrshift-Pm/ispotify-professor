import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_with_flutter/core/constants/app_urls.dart';
import 'package:spotify_with_flutter/data/models/auth/create_user_req.dart';
import 'package:spotify_with_flutter/data/models/auth/signin_user_req.dart';
import 'package:spotify_with_flutter/data/models/auth/user.dart';
import 'package:spotify_with_flutter/domain/entities/auth/user.dart';

abstract class AuthApiService {
  Future<String> signup(CreateUserReq createUserReq);
  Future<String> signin(SigninUserReq signinUserReq);
  Future<UserEntity> getUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
}

class AuthApiServiceImpl extends AuthApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Local storage keys
  static const String _userPrefix = "custom_auth_user_";
  static const String _sessionTokenKey = "custom_auth_session_token";
  static const String _activeUserEmailKey = "custom_auth_active_email";

  @override
  Future<String> signup(CreateUserReq createUserReq) async {
    try {
      // Simulate real POST request to register user using Dio (N2)
      await _dio.post(
        "https://raw.githubusercontent.com/gabrielgpavan/mock-api/main/auth/signup",
        data: {
          "email": createUserReq.email,
          "password": createUserReq.password,
          "name": createUserReq.fullName,
        },
      );
      
      throw Exception("Falha ao registrar usuário no servidor remoto.");
    } catch (e) {
      // Robust Local Simulation using SharedPreferences (N1 & N2 Fallback)
      final prefs = await SharedPreferences.getInstance();
      final userKey = "$_userPrefix${createUserReq.email.trim().toLowerCase()}";
      
      if (prefs.containsKey(userKey)) {
        throw Exception("Uma conta com este e-mail já existe.");
      }

      await prefs.setString(userKey, createUserReq.password);
      await prefs.setString("${userKey}_name", createUserReq.fullName);
      
      await prefs.setString(_sessionTokenKey, "mock_jwt_token_${createUserReq.email}");
      await prefs.setString(_activeUserEmailKey, createUserReq.email.trim().toLowerCase());

      return "Cadastro efetuado com sucesso!";
    }
  }

  @override
  Future<String> signin(SigninUserReq signinUserReq) async {
    try {
      // Simulate real POST request to sign in user using Dio (N2)
      await _dio.post(
        "https://raw.githubusercontent.com/gabrielgpavan/mock-api/main/auth/signin",
        data: {
          "email": signinUserReq.email,
          "password": signinUserReq.password,
        },
      );
      
      throw Exception("Falha ao autenticar no servidor remoto.");
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final email = signinUserReq.email.trim().toLowerCase();
      final userKey = "$_userPrefix$email";

      if (!prefs.containsKey(userKey)) {
        throw Exception("E-mail não cadastrado.");
      }

      final savedPassword = prefs.getString(userKey);
      if (savedPassword != signinUserReq.password) {
        throw Exception("Senha incorreta.");
      }

      await prefs.setString(_sessionTokenKey, "mock_jwt_token_$email");
      await prefs.setString(_activeUserEmailKey, email);

      return "Login efetuado com sucesso!";
    }
  }

  @override
  Future<UserEntity> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final activeEmail = prefs.getString(_activeUserEmailKey);

    if (activeEmail == null) {
      throw Exception("Nenhum usuário logado.");
    }

    final userKey = "$_userPrefix$activeEmail";
    final name = prefs.getString("${userKey}_name") ?? "Estudante ESW438";

    final userModel = UserModel(
      email: activeEmail,
      fullName: name,
      imageURL: AppUrls.defaultAvatar,
    );

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_activeUserEmailKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionTokenKey);
  }
}
