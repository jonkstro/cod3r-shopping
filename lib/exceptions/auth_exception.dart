class AuthException implements Exception {
  // Traduzir os erros gerados no firebase para uma msg mais amigável
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'Email já cadastrado',
    'OPERATION_NOT_ALLOWED': 'Operação não é permitida',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'Acesso bloqueado temporariamente, tente novamente mais tarde',
    'EMAIL_NOT_FOUND': 'Email não encontrado',
    'INVALID_PASSWORD': 'Senha informada não confere',
    'USER_DISABLED': 'A conta do usuário foi desabilitada',
    'INVALID_LOGIN_CREDENTIALS': 'Credenciais de login inválidas'
  };
  final String key;

  AuthException({required this.key});

  @override
  String toString() {
    return errors[key] ?? 'Ocorreu um erro no processo de autenticação!';
  }
}
