import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/pages/auth_page.dart';
import 'package:shop/pages/products_overview_page.dart';

/*
Vai servir para poder redirecionar o usuário após a tela de login.
 - Se o user tiver autenticado, com todas validações da model auth, ele vai direcionar para
 a tela inicial da plataforma
 - Se o user não estiver autenticado, ele vai direcionar para a tela de formulário de login
 e senha
*/
class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context);
    // return auth.isAuth ? const ProductsOverviewPage() : const AuthPage();
    return FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('Ocorreu um erro!'),
            );
          } else {
            return auth.isAuth
                ? const ProductsOverviewPage()
                : const AuthPage();
          }
        });
  }
}
