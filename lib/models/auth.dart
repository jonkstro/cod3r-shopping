import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/utils/constants.dart';

///https://firebase.google.com/docs/reference/rest/auth?hl=pt
class Auth with ChangeNotifier {
  // Variáveis que irão vir na resposta do Firebase
  String? _token;
  String? _email;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    // Validar se a data de expiração tá depois de data de agora, senão bota false
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    // Retorna true se tiver isValid e o token diferente de vazio
    return _token != null && isValid;
  }

  // Getter do token, só vai retornar o token se o user tiver autenticado
  String? get token {
    return isAuth ? _token : null;
  }

  // Getter do email, só vai retornar o email se o user tiver autenticado
  String? get email {
    return isAuth ? _email : null;
  }

  // Getter do userId (id do usuário), só vai retornar o userId se o user tiver autenticado
  String? get userId {
    return isAuth ? _userId : null;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlFragment,
  ) async {
    final url =
        '${Constants.AUTH_URL}$urlFragment?key=${Constants.CHAVE_PROJETO}';

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
    // print(body);
    if (body['error'] != null) {
      // Se retornar erro:
      throw AuthException(key: body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _userId = body['localId'];
      // O Firebase só traz os segundos que valem o token, então vamos adicionar na data
      // de agora os segundos que ele retornou no response.
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(body['expiresIn']),
        ),
      );
      // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - INICIO
      // Quando autenticar (login ou registrar) vai guardar os dados retornados em memória
      Store.saveMap('userData', {
        'token': _token,
        'email': _email,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - FINAL

      // OPCIONAL ADICIONANDO TIMER DE LOGOUT - INICIO
      // Se a token não for mais válida [depois do tempo de expiração do] vai deslogar
      _autoLogout();
      // OPCIONAL ADICIONANDO TIMER DE LOGOUT - FINAL

      notifyListeners(); // Atualizar aos interessados
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - INICIO
  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap('userData');
    // Se userData for vazio (não tiver no storage), faz nada
    if (userData.isEmpty) return;

    // Se a data de expiração for antes de agora [no passado], faz nada
    // pois expirou o token
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return;

    // Se chegou até aqui, vai ser atualizado os dados com o que tá no storage
    _token = userData['token'];
    _email = userData['email'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    // OPCIONAL ADICIONANDO TIMER DE LOGOUT - INICIO
    _autoLogout();
    // OPCIONAL ADICIONANDO TIMER DE LOGOUT - FINAL
    notifyListeners();
  }
  // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - FINAL

  // Método que vai ser chamado no Drawer, ao clicar no botão de sair
  void logout() {
    _token = null;
    _email = null;
    _userId = null;
    _expiryDate = null;
    // OPCIONAL ADICIONANDO TIMER DE LOGOUT - INICIO
    // Zerar o timer de logout automatico
    _clearLogoutTimer();
    // OPCIONAL ADICIONANDO TIMER DE LOGOUT - FINAL

    // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - INICIO
    // Remover os dados do usuário quando fizer logout
    Store.remove('userData').then((_) {
      // Só vai atualizar os interessados quando tiver certeza que apagou no storage
      notifyListeners();
    });
    // SALVAR OS DADOS DO LOGIN EM MEMÓRIA - FINAL
  }

  // OPCIONAL ADICIONANDO TIMER DE LOGOUT - INICIO
  // Vai limpar o timer de logout
  void _clearLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  // Método que vai deslogar automaticamente após a token não ser mais válida
  void _autoLogout() {
    _clearLogoutTimer();
    final timeToLogout = _expiryDate?.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout ?? 0), logout);
  }
  // OPCIONAL ADICIONANDO TIMER DE LOGOUT - FINAL
}
