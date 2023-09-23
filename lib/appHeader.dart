import 'package:flutter/material.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget{
  const AppHeader({Key? key}) : super(key: key);

  @override
  State<AppHeader> createState() => _AppHeaderState();
  
  @override
  Size get preferredSize => const Size.fromHeight(500);
} 


class _AppHeaderState extends State<AppHeader> {
  @override
  void initState() {
    super.initState();
  }
  double _price= 0.0;
  double _time= 0.0;
  bool vegano = false;
  bool vegetariano = false;
  bool filter = false;
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Container(  
        
      color:Color.fromRGBO(255, 247, 235, 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            vertical: 25/2.5,
            ),
            height: 80,
            color: Color.fromRGBO(255, 247, 235, 1),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.filter_list,size: 40,),
                Image.asset('assets/Logo.png', height: 40,),
                const Icon(Icons.location_on,size: 40,)],
          ),),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            vertical: 25/2.5,
            ),
            height: 80,
            color: Color.fromRGBO(255, 247, 235, 1),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: 'Busca tu almuerzo de hoy',
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
                        borderRadius: BorderRadius.all(Radius.circular(7.0))
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {setState(() {
                    filter = !filter;
                  });}, 
                  icon: const Icon(Icons.tune,),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)
                      ),
                      ),  
                  )) ,
                ],
          ),),
          if(filter == true)
            Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            vertical: 10,
            ),
            height: 300,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Filtrar por precio",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("10K",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                    Flexible(child:  Slider(max:100.0, min:0.0, value: _price,thumbColor: Color.fromRGBO(253, 218, 168, 1), activeColor: Color.fromRGBO(255, 188, 91, 1), onChanged: (double newValue) {  
                                  setState(() {  
                                    _price = newValue;  
                                    });})
                                    ),
                    const Text("100K", style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                  ],
                ),
                const Text("Filtrar por tipo de comida",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(value: vegano,
                      onChanged: (value) {
                        setState(() {
                        vegano = value;
                        });
                      },
                      thumbColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 188, 91, 1)), activeColor: Color.fromRGBO(253, 218, 168, 1) , trackOutlineColor: MaterialStateProperty.all<Color>(Colors.transparent),inactiveTrackColor: Color.fromRGBO(253, 218, 168, 0.4),
                    ),
                    const Text("Vegana",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                    Switch(value: vegetariano,
                      onChanged: (value) {
                        setState(() {
                        vegetariano = value;
                        });
                      },
                      thumbColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 188, 91, 1)), activeColor: Color.fromRGBO(253, 218, 168, 1) , trackOutlineColor: MaterialStateProperty.all<Color>(Colors.transparent),inactiveTrackColor: Color.fromRGBO(253, 218, 168, 0.4),
                    ),
                    const Text("Vegetariana",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                
                  ],
                ),
                const Text("Filtrar por tiempo de espera máximo",style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                  Flexible(child:  Slider(max:100.0, min:0.0, value: _time,thumbColor: Color.fromRGBO(253, 218, 168, 1), activeColor: Color.fromRGBO(255, 188, 91, 1), onChanged: (double newValue) {  
                                  setState(() {  
                                    _time = newValue;  
                                    });})
                                    ),
                    const Text("60 min", style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () {setState(() {
                      filter = !filter;
                      });},
                      style: ButtonStyle (foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                        ),)
                      ), child: const Text("Aplicar Filtros", style: TextStyle(fontSize: 18, fontFamily: "Manrope"),),)
                  ],
                )
                
              ],
            ),)
        ,
        ],
      ),),
    );
    
  }
  
}
