import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(255, 247, 235, 1),
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Logo.png'),
                const SizedBox(
                    height: 70), // Espacio entre la imagen y el cuadro de texto
                const Align(
                  alignment:
                      Alignment.topLeft, // Cambia esto según tu preferencia
                  child: Text(
                    "                 USUARIO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Cuadro de texto con sombra
                Container(
                  width: 300,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 3,
                        offset: const Offset(
                            0, 3), // Cambia la dirección de la sombra
                      ),
                    ],
                  ),
                  child: const TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: 'df.gomezb',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      // Agregar una imagen dentro del cuadro de texto
                      prefixIcon: Icon(
                        Icons
                            .person, // Cambia este ícono por la imagen que desees
                        color: Colors.black, // Color del ícono
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 50), // Espacio entre los cuadros de texto
                const Align(
                  alignment:
                      Alignment.topLeft, // Cambia esto según tu preferencia
                  child: Text(
                    "                 CONTRASEÑA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Cuadro de texto con sombra
                Container(
                  width: 300,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 3,
                        offset: const Offset(
                            0, 3), // Cambia la dirección de la sombra
                      ),
                    ],
                  ),
                  child: const TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: '************',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      // Agregar una imagen dentro del cuadro de texto
                      prefixIcon: Icon(
                        Icons
                            .lock, // Cambia este ícono por la imagen que desees
                        color: Colors.black, // Color del ícono
                      ),
                    ),
                  ),
                ),
                // Otros elementos de inicio de sesión (contraseña, botón de inicio de sesión, etc.)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
