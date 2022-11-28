// ignore_for_file: prefer_const_constructors, deprecated_member_use, library_private_types_in_public_api

import 'package:activity_app/screens/activities.screen.dart';
import 'package:activity_app/screens/times_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:activity_app/models/token.dart';
import 'package:activity_app/screens/login_screen.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Activity App'),
        ),
        body: _getBody(),
        drawer: _getMenu());
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(150),
            // ignore: sort_child_properties_last
            child: Image(
              image: AssetImage('images/logot.png'),
              width: 300,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              'Bienvenid@ ${widget.token.nameUser} al gestor de actividades!!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Llamar al administrador'),
              SizedBox(
                width: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.blue,
                  child: IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    onPressed: () => launch("tel://+573108408327"),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Enviar mensaje al administrador'),
              SizedBox(
                width: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.green,
                  child: IconButton(
                    icon: Icon(
                      Icons.insert_comment,
                      color: Colors.white,
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMenu() {
    return Drawer(
      backgroundColor: Colors.blue[100],
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: Image(
            image: AssetImage('images/logo.png'),
          )),
          //!Aqui debemos poner el llamado a la pantalla de Actividades
          ListTile(
            leading: Icon(Icons.verified_sharp),
            title: const Text('Actividades'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivitiesScreen(
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
          //!Aqui debemos poner el llamado a la pantalla de Tareas
          ListTile(
            leading: Icon(Icons.access_alarm_outlined),
            title: const Text('Tiempos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimesScreen(
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
          Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+573108408327',
      text: 'Hola soy un usuario del gestor de actividades',
    );
    await launch('$link');
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
