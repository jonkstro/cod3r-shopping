import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';

// Enum que vai alternar entre as telas de login e register
enum AuthMode { SignUp, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

// SingleTickerProviderStateMixin vai servir para as animações dentro de classe stateful
// vai chamar uma função a cada frame da tela (60 vezes por segundo)
class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confpasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': ''};

  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSignUp() => _authMode == AuthMode.SignUp;

  // Controller das animações
  AnimationController? _controller;
  // Variavel que vai animar a altura (Size) do formulario.
  // Cada tipo de animação deve ter uma
  // Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // this ta pegando o SingleTickerProviderStateMixin da classe
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    // Tween é a animação que vai trabalhar dentro de 2 intervalos
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      // tipo da animação que quero, se é bounce, se é elastic, etc...
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
    // animar os valores que vai descer e subir, botando 0,-1 inicial (está acima)
    // e final 0,0 (vai sair de onde já tá pra cima)
    _slideAnimation = Tween(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(
      // tipo da animação que quero, se é bounce, se é elastic, etc...
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _emailController.text = '';
      _confpasswordController.text = '';
      _passwordController.text = '';
      if (_isLogin()) {
        _authMode = AuthMode.SignUp;
        // Foward é pra ir de 310 pra 400 de altura
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        // Reverse é pra ir de 400 pra 310 de altura
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    // Validação dos campos do formulario: Se tiver o que validar ele valida,
    //se não tiver nada pra validar manda false pois deu algum erro
    final isValid = _formKey.currentState?.validate() ?? false;
    // Se não for válido (isValid = false) ele vai fazer nada, vai acabar aqui
    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    // Vai salvar cada um dos campos do form chamando o onSaved de cada um
    _formKey.currentState?.save();
    // listen = false pois tá fora do build, senão quebra a aplicação
    Auth auth = Provider.of<Auth>(context, listen: false);
    try {
      if (_isLogin()) {
        // Login
        // Os 2 valores já tão setados como '' no início do programa por isso o '!'
        await auth.signin(_authData['email']!, _authData['password']!);
      } else {
        // Registrar
        // Os 2 valores já tão setados como '' no início do programa por isso o '!'
        await auth.signup(_authData['email']!, _authData['password']!);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // A largura do form é 75% da largura do dispositivo
    final _deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        // Calcular o tamanho da tela com base na qtd de campos que for precisar
        height: _isLogin() ? 310 : 400,
        // A altura agora vai vir da animação, se não tiver disponível o callback
        // vai ser a altura que foi calculada acima
        // height: _heightAnimation?.value.height ?? (_isLogin() ? 310 : 400),
        width: _deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                // Vai adicionar o authData o valor do campo, se tiver vazio vai botar ''
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (value) {
                  final email = value ?? '';
                  // Remover espaços em branco no início e no final da string e ver se tem @
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um email válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => _submit(),
                keyboardType: TextInputType.text,
                obscureText: true,
                // Controller vai permitir comparar com senha
                controller: _passwordController,
                // Vai adicionar o authData o valor do campo, se tiver vazio vai botar ''
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Informe uma senha com mais de 5 letras';
                  }
                  return null;
                },
              ),
              // if (_isSignUp())
              AnimatedContainer(
                // O AnimatedContainer vai animar de 60 a 120 quando for registrar
                constraints: BoxConstraints(
                  minHeight: _isLogin() ? 0 : 60,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  // Vai fazer o campo descer
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Senha',
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      controller: _confpasswordController,
                      // Só chama o validador se for tela de Signup
                      validator: _isSignUp()
                          ? (value) {
                              final password = value ?? '';
                              if (password != _passwordController.text) {
                                return 'Senhas informadas não conferem';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => _submit(),
                  style: ElevatedButton.styleFrom(
                    // minimumSize: const Size(300, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISTRAR',
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => _switchAuthMode(),
                child: Text(
                  _isLogin() ? 'DESEJA REGISTRAR?' : 'JÁ POSSUI CONTA?',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
