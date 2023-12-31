import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/components/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 0.5),
                  Color.fromRGBO(255, 188, 117, 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            // Vai quebrar quando deixar o celular deitado, se deixar sem ScrollView
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 10,
                      ),

                      /// Rotação de -8 graus (em sentido horário) em torno do eixo Z.
                      /// O uso de pi é necessário para converter de graus para radianos.
                      /// O operador de cascata (..) permite encadear chamadas de métodos
                      /// no mesmo objeto. Aqui, a transformação é encadeada com uma chamada
                      /// para translate que move o objeto após a rotação.
                      /// O valor -10.0 indica um deslocamento horizontal de -10 unidades
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Minha Loja',
                        style: TextStyle(
                          fontSize: 45,
                          fontFamily: 'Anton',
                          color:
                              Theme.of(context).textTheme.headlineLarge?.color,
                        ),
                      ),
                    ),
                    AuthForm(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
