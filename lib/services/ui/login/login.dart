import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/user_bloc.dart';
import 'package:fud/services/ui/home/home_page.dart';
import 'package:fud/services/resources/gps_service.dart';
import 'package:fud/services/ui/login/forgot_password.dart';
import 'package:fud/services/ui/login/register.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  final PlateBloc plateBloc;
  const LoginPage({Key? key, required this.plateBloc}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserBloc _userBloc = UserBloc();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late DateTime entryTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    entryTime = DateTime.now();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _userBloc.dispose();

    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);

    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'Login Screen');

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
                const SizedBox(height: 70),
                _buildTextField('USUARIO', Icons.person, _usernameController),
                const SizedBox(height: 50),
                _buildTextField(
                  'CONTRASEÑA',
                  Icons.lock,
                  _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.only(left: 140),
                  child: GestureDetector(
                    onTap: () {
                      // Navegar a la pantalla de recuperación de contraseña
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: const Text(
                        'Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
              hintText: obscureText ? '************' : 'Usuario',
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
                  String password = _passwordController.text;
                  // Check if username or password is blank
                  if (username.isEmpty || password.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('🤔'),
                          content: const Text(
                              'Por favor ingrese el usuario y contraseña.'),
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
                    return; // Exit the onPressed function if username or password is blank
                  }
                  _userBloc.fetchUserExistence(username, password);
                  _userBloc.userResult.listen((bool response) {
                    if (mounted) {
                      if (response) {
                        GPS().getCurrentLocation();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePage(plateBloc: widget.plateBloc),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('🤔'),
                              content: const Text(
                                  'El usuario no existe o la contraseña es incorrecta.'),
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
                  'INICIAR SESIÓN',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
        const SizedBox(
            height: 50), // Espaciado entre el botón y el nuevo enlace
        GestureDetector(
          onTap: () {
            // Navegar a la pantalla de registro (RegisterPage)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16, // Puedes ajustar el tamaño del texto aquí
                color: Colors.black, // Puedes ajustar el color del texto aquí
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'No tienes cuenta? ',
                ),
                TextSpan(
                  text: 'REGISTRATE',
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
