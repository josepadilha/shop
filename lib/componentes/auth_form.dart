import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exceptions.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with TickerProviderStateMixin {
  bool isLoading = false;

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final _isValid = _formKey.currentState?.validate() ?? false;
    print('chamando a função de autenticação');
    if (!_isValid) {
      return;
    }
    setState(() => isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of<Auth>(context, listen: false);
    try {
      if (isLogin()) {
        await auth.login(_authdata['email']!, _authdata['password']!);
      } else {
        await auth.signup(_authdata['email']!, _authdata['password']!);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() => isLoading = false);
  }

  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authdata = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<Size>? _heightAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _heightAnimation = Tween(
      begin: Size(double.infinity, 310),
      end: Size(double.infinity, 400),
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.linear),
    );

    _heightAnimation?.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool isLogin() => _authMode == AuthMode.Login;
  bool isSignup() => _authMode == AuthMode.Signup;

  _switchAuthMode() {
    setState(() {
      if (isLogin()) {
        _authMode = AuthMode.Signup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: _heightAnimation?.value.height ?? (isLogin() ? 320 : 400),
        width: deviceSize.width * 0.75,
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (email) => _authdata['email'] = email ?? '',
                    validator: (_email) {
                      final email = _email ?? '';
                      if (email.trim().isEmpty || !email.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    }),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha'),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onSaved: (password) => _authdata['password'] = password ?? '',
                  controller: _passwordController,
                  validator: (_password) {
                    final password = _password ?? '';
                    if (password.isEmpty || password.length < 5) {
                      return 'Senha inválida';
                    }
                    return null;
                  },
                ),
                if (isSignup())
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Confirmar senha'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (_password) {
                      final password = _password;
                      if (password != _passwordController.text) {
                        return 'Senha não confere';
                      }
                      return null;
                    },
                  ),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_authMode == AuthMode.Login
                            ? 'Entrar'
                            : 'Registrar'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 30,
                            )),
                      ),
                Spacer(),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    isLogin() ? 'Deseja se cadastrar?' : 'Já possui uma conta?',
                  ),
                )
              ],
            )),
      ),
    );
  }
}
