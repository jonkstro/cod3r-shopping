// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String BASE_URL = dotenv.env['BASE_URL'] ?? '';
  static String AUTH_URL = dotenv.env['AUTH_URL'] ?? '';
  static String CHAVE_PROJETO = dotenv.env['CHAVE_PROJETO'] ?? '';
}
