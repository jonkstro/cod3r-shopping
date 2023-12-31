import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/utils/constants.dart';

class Auth with ChangeNotifier {
  ///https://firebase.google.com/docs/reference/rest/auth?hl=pt
  // static const _urlSignup =
  //     '${Constants.AUTH_URL}:signUp?key=${Constants.CHAVE_PROJETO}';
  // static const _urlSignin =
  //     '${Constants.AUTH_URL}:signInWithPassword?key=${Constants.CHAVE_PROJETO}';

  Future<void> _authenticate(
      String email, String password, String urlFragment) async {
    final url =
        '${Constants.AUTH_URL}:$urlFragment?key=${Constants.CHAVE_PROJETO}';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    final body = jsonDecode(response.body);
    print(body);
    if (body['error'] != null) {
      throw AuthException(key: body['error']['message']);
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
