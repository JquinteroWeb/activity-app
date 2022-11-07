import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Activity App"),
        ),
        elevation: 0.5,
      ),
      body: PageView(children: const [
        //? Aqui se deben poner las pantallas de la app
      ]),

      //*Taps
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (value) => {
          //!con esta funcion manejamos la funcionalidad de los botones del button bart
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Liguin"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }
}
