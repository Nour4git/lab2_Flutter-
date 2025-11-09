import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  bool _showRegister = false;
  final _nameController = TextEditingController();

  Future<void> _login() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      await _login();
    } catch (e) {
      setState(() {
        _error = 'Erreur d\'inscription: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _showRegister = !_showRegister;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showRegister ? 'Créer un compte' : 'Connexion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            if (_error != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (_showRegister) ...[
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : (_showRegister ? _register : _login),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading 
                  ? CircularProgressIndicator()
                  : Text(_showRegister ? 'S\'inscrire' : 'Se connecter'),
            ),
            SizedBox(height: 10),
            
            TextButton(
              onPressed: _isLoading ? null : _toggleAuthMode,
              child: Text(_showRegister 
                  ? 'Déjà un compte? Se connecter' 
                  : 'Pas de compte? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}