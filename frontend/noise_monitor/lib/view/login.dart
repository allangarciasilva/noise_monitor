import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_monitor/providers/current_user.dart';
import 'package:noise_monitor/utils/func.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  static const minimumPasswordLength = 0;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _submitEnabled = true;
  bool _passwordVisible = false;
  bool _isLogin = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  Future<void> _onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitEnabled = false);

    await executeOrShowError(
      context,
      () => ref
          .read(currentUserProvider.notifier)
          .login(_emailController.text, _passwordController.text, !_isLogin),
    );

    setState(() => _submitEnabled = true);
  }

  Widget _buildBottomText() {
    if (_isLogin) {
      return TextButton(
        onPressed: () => setState(() => _isLogin = false),
        child: Text("Do not have an account yet? Signup here."),
      );
    }
    return TextButton(
      onPressed: () => setState(() => _isLogin = true),
      child: Text("Already have an account? Login here."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 10,
                child: _buildBottomText(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const Center(
                      child: Text(
                        "Noise Monitor",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      validator: (value) {
                        if (!EmailValidator.validate(value ?? "")) {
                          return "Email is not valid.";
                        }
                        return null;
                      },
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Email'),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value == null ||
                            value.length < minimumPasswordLength) {
                          return "Password must have at least $minimumPasswordLength characters.";
                        }
                        return null;
                      },
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Password'),
                        suffixIcon: Container(
                          margin: const EdgeInsets.only(right: 2.0),
                          child: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () {
                                _passwordVisible = !_passwordVisible;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                          ),
                          onPressed: _submitEnabled ? _onSubmitPressed : null,
                          child: Text(_isLogin ? "Login" : "Signup"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
