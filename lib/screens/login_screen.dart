import 'dart:convert';
import 'home_screen.dart';
// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_final_fields, no_leading_underscores_for_local_identifiers, unused_element
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:activity_app/components/loader_component.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../helpers/constans.dart';
import '../models/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = ''; //para pruebas
  String _emailError = '';
  bool _emailShowError = false;

  String _password = ''; //para pruebas
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ACTIVITY APP')),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                _showLogo(),
                SizedBox(
                  height: 20,
                ),
                _showEmail(),
                _showPassword(),
                _showRememberme(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Loading...') : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage("images/logo.jpg"),
      width: 300,
      fit: BoxFit.fill,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Ingresa tu email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Ingresa tu password...',
          labelText: 'Password',
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme'),
      value: _rememberme,
      onChanged: (value) {
        setState(() {
          _rememberme = value!;
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showLoginButton(),
              SizedBox(
                width: 20,
              ),
              _showRegisterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showLoginButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Login'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _login(),
      ),
    );
  }

  Widget _showRegisterButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Registrar'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.indigo;
          }),
        ),
        onPressed: () => _register(),
      ),
    );
  }

  bool _validateField() {
    bool _isValid = true;

    if (_email.isEmpty) {
      _isValid = false;
      _emailShowError = true;
      _emailError = "Email is required";
    } else if (!EmailValidator.validate(_email)) {
      _isValid = false;
      _emailShowError = true;
      _emailError = "Email is invalid";
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      _isValid = false;
      _passwordShowError = true;
      _passwordError = "Password is required";
    } else if (_password.length <= 6) {
      _isValid = false;
      _passwordShowError = true;
      _passwordError = "Password must be at least 6 characters";
    } else {
      _passwordShowError = false;
    }
    setState(() {});
    return _isValid;
  }

  void _register() async {}

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if (!_validateField()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'email': _email,
      'password': _password,
    };

    print('${Constans.apiUrl}/api/cuentas/login');

    var url = Uri.parse('${Constans.apiUrl}/api/cuentas/login');

    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });
    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Email o contraseña incorrectos";
      });
      return;
    }

    void _storeUser(String body) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRemembered', true);
      await prefs.setString('userBody', body);
    }

    var body = response.body;
    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          token: token,
        ),
      ),
    );
  }
}
