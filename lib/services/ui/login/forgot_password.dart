import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fud/services/blocs/user_bloc.dart';
import 'package:fud/services/ui/login/login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPage extends StatefulWidget {
  static const routeName = '/forgot';
  const ForgotPage({Key? key}) : super(key: key);
  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final UserBloc _userBloc = UserBloc();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  late DateTime entryTime;
  late bool _isConnected;
  bool _hasShownConnectivityToast = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    entryTime = DateTime.now();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);

    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'ForgotPW Screen');
    _userBloc.dispose();

    super.dispose();
  }

  // Function to check the current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result;
  }

  void _showConnectivityToast() async {
    if (_hasShownConnectivityToast) {
      return; // Si ya se mostró el toast, no hacer nada
    }

    ConnectivityResult result = await checkConnectivity();

    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });

    if (!_isConnected) {
      _showToast(
        'Sin conexión an Internet: ingresar más tarde',
        0xFFFFD2D2, // Red color
      );
    } else {
      _showToast(
        'Conectado a Internet: continue disfrutando de nuestros servicios.',
        0xFFC2FFC2, // Green color
      );

      // Cambiar el valor de la variable para que no se muestre el toast la próxima vez
      setState(() {
        _hasShownConnectivityToast = true;
      });
    }
  }

// Function to show toast notifications
  void _showToast(String message, int backgroundColorHex) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      fontSize: 16.0,
      backgroundColor: Color(backgroundColorHex),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    _showConnectivityToast();
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
                const SizedBox(height: 50),
                _buildTextField(
                  'CONFIRMAR LA CONTRASEÑA',
                  Icons.lock,
                  _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 40),
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
          onPressed: _isLoading || !_isConnected
              ? null
              : () async {
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  String confirmPassword = _confirmPasswordController.text;

                  _userBloc.fetchOnlyUserExistence(username);
                  _userBloc.userResult.listen((bool response) {
                    if (mounted) {
                      if (!response) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('🤔'),
                              content: const Text('El usuario no existe'),
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
                      }
                      if (password != confirmPassword) {
                        // Passwords do not match
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('🤔'),
                              content:
                                  const Text('Las contraseñas no coinciden.'),
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

                      // Check if username or password is blank
                      if (username.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
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
                        setState(() {
                          _isLoading = false;
                        });
                        return; // Exit the onPressed function if username or password is blank
                      } else {
                        _userBloc.changePassword(username, password);
                        // Contraseña cambiada con éxito
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Solicitud exitosa 😄'),
                              content: const Text(
                                  'Contraseña cambiada, ya puedes iniciar sesión'),
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
                        setState(() {
                          _isLoading = true;
                        });
                      }
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
                  'CAMBIAR CONTRASEÑA',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ],
    );
  }
}
