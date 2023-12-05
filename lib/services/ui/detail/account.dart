import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fud/services/blocs/user_bloc.dart';
import 'package:fud/services/ui/detail/appHeaderNoFilter.dart';
import 'package:fud/services/ui/login/forgot_password.dart';
import 'package:fud/services/ui/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  static const routeName = '/account';

  
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final UserBloc _userBloc = UserBloc();
  
  final TextEditingController  number = TextEditingController();
  final TextEditingController  user =TextEditingController();
  bool edit = false;

  @override
  void dispose() {
    number.dispose();
    user.dispose();
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppHeaderNoFilter(),
        backgroundColor: const Color.fromRGBO(255, 247, 235, 1),
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back,size: 30,
                    color:  Color.fromARGB(255, 146, 146, 146)),
                    onPressed: (){
                      Navigator.pop(context);
                    },),
                    const Icon(Icons.account_circle,size: 80,color:  Color.fromARGB(255, 146, 146, 146)),
                    IconButton(onPressed: (){
                      if(!edit){
                      setState(() {
                        edit=!edit;
                      });}
                      else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Borrar cuenta!😨'),
                              content: const Text(
                                  'Oh no, vas a eliminar tu cuenta por completo 😥. ¿Estás seguro?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (Route<dynamic> route) => false);
                                    await _userBloc.deleteAccount();
                                    //Funcion de eliminar cuenta
                                  },
                                  child: const Text('Eliminar Cuenta'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }, icon: Icon(!edit?Icons.edit:Icons.delete_forever ,size: 30,
                    color:  !edit?Color.fromARGB(255, 146, 146, 146):Colors.red,))
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: FutureBuilder(
                      future: SharedPreferences.getInstance(),
                      builder: (context,snapshot) {
                        if (snapshot.hasData){
                        if(!edit)  {number.text = snapshot.data!.getString('number')!;
                          user.text = snapshot.data!.getString('username')!;}
                        return 
                        Column(
                        children : [
                          Text(snapshot.data!.getString('name')!,style: TextStyle(fontSize: 30),),
                          const SizedBox(height: 30),
                          Container( 
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: !edit?const Color.fromARGB(255, 224, 224, 224):Colors.white,
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
                            child :TextField(
                              readOnly: !edit,
                              controller: user,
                              autocorrect: true,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: !edit?const Color.fromARGB(255, 224, 224, 224):Colors.white,
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
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ),
                          const SizedBox(height: 30),
                  
                          Container( 
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: !edit?const Color.fromARGB(255, 224, 224, 224):Colors.white,
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
                            child :TextFormField(
                              readOnly: !edit,
                              controller: number,
                              autocorrect: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: !edit?const Color.fromARGB(255, 224, 224, 224):Colors.white,
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
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ),
                          const SizedBox(height: 120),
                          edit? Column(children : 
                          [Align(
                        alignment: Alignment.center,
                        child: FutureBuilder(
                            future: Connectivity().checkConnectivity(),
                            builder: (BuildContext context,
                                AsyncSnapshot<ConnectivityResult> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data != ConnectivityResult.none) {
                                  return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(255, 146, 45, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(190, 50),
                            ),
                            onPressed: ()async{
                              
                              await _userBloc.changeUserInfo(user.text, number.text);
                              setState(() {
                                edit=!edit;
                              });
                            }, 
                            child: const Text(
                              'GUARDAR CAMBIOS',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            )
                          );
                                } else {
                                  return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 253, 179, 110),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(190, 50),
                            ),
                            onPressed: ()async{
                              
                              setState(() {
                                edit=!edit;
                              });
                              _showToast('No se guardaron los cambios, no hay conexión', 0xFFFFD2D2);
                            }, 
                            child: const Text(
                                    'No hay conexión 😨',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Manrope",
                                        color: Colors
                                            .white), // Cambia el tamaño del texto
                                  ),
                            );
                                }
                              } else {
                                return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 253, 179, 110),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(190, 50),
                              maximumSize: const Size(300, 100)
                            ),
                            onPressed: ()async{
                              
                              setState(() {
                                edit=!edit;
                              });
                            }, 
                            child: const Text(
                                    'No hay conexión 😨',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Manrope",
                                        color: Colors
                                            .white), // Cambia el tamaño del texto
                                  ),
                            );
                              }
                            })),
                            
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 224, 224, 224),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(190, 50),
                            ),
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ForgotPage()),
                              );
                            }, 
                            child: const Text(
                              'CAMBIAR CONTRASEÑA',
                              style: TextStyle(fontSize: 18,color: Colors.black ),
                            )
                          )])
                          : 
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(245, 90, 81, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(190, 50),
                            ),
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Cerrar sesión!'),
                                      content: const Text(
                                          '¿Seguro que quieres cerrar sesión? Te extrañaremos 😪'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            //Funcion de cerrar sesión
                                            
                                            Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (Route<dynamic> route) => false);
                                          },
                                          child: const Text('Cerrar sesión'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                            }, 
                            child: const Text(
                              'CERRAR SESIÓN',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            )
                          )
                          ]
                          );}else{
                          return Text('No es posible acceder a tu cuenta, intenta de nuevo más tarde');
                        }
                        
                        }

                  )),                                  
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showToast(String message, int backgroundColorHex) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      fontSize: 16.0,
      backgroundColor: Color(backgroundColorHex),
      textColor: Colors.white,
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
  
}
