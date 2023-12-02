import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fud/services/blocs/user_bloc.dart';
import 'package:fud/services/ui/login/login.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserBloc _userBloc = UserBloc();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 247, 235, 1),
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/Logo.svg'),
                const SizedBox(height: 50),
                _buildTextField('USUARIO', Icons.person, _usernameController),
                const SizedBox(height: 15),
                _buildTextField('NOMBRE', Icons.person, _nameController),
                const SizedBox(height: 15),
                _buildTextField('TELÉFONO', Icons.phone, _phoneController),
                const SizedBox(height: 15),
                _buildTextField('CONTRASEÑA', Icons.lock, _passwordController,
                    obscureText: true),
                const SizedBox(height: 15),
                _buildTextField('CONFIRMAR LA CONTRASEÑA', Icons.lock,
                    _confirmPasswordController,
                    obscureText: true),
                const SizedBox(height: 30),
                _buildElevatedButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '                 $label',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            autocorrect: true,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: obscureText
                  ? '************'
                  : (label == 'USUARIO'
                      ? 'Usuario'
                      : (label == 'NOMBRE'
                          ? 'Nombre'
                          : (label == 'TELÉFONO'
                              ? '3123456789'
                              : 'Texto por defecto'))),
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10), // Espaciado entre el enlace y el botón
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String username = _usernameController.text;
                  String name = _nameController.text;
                  String phone = _phoneController.text;
                  String password = _passwordController.text;
                  String confirmPassword = _confirmPasswordController.text;
                  if (password != confirmPassword) {
                    // Passwords do not match
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('🤔'),
                          content: const Text('Las contraseñas no coinciden.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  }
                  logger.d("Entro _userBloc.registerUser");
                  _userBloc.registerUser(username, name, phone, password);
                  _userBloc.userResult.listen((bool response) {
                    if (mounted) {
                      if (!response) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('🤔'),
                              content: const Text(
                                  'Por favor ingrese todos los campos.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Contraseña cambiada con éxito
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Registro exitoso 🥳'),
                              content: const Text(
                                  'Ya eres usuario. Ingresa tu nuevo usuario y contraseña para disfrutar de la aplicación.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pop(); // Cerrar la página actual
                                    Navigator.pushReplacementNamed(
                                      context,
                                      LoginPage.routeName,
                                    ); // Ir a la página de inicio de sesión
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(255, 146, 45, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            minimumSize: const Size(190, 50),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  'REGISTRATE',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ],
    );
  }
}
