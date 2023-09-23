import 'package:flutter/material.dart';
import 'package:fud/appHeader.dart';

class ResultsPage extends StatefulWidget {
  static const routeName = '/results';

  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Ordenar por: ", style: TextStyle(fontSize: 18,color: Colors.grey),),
                Text("Mejor calificados ", style: TextStyle(fontSize: 18,color: Colors.black),)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Divider(),
          ),
          RestaurantResume(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            vertical: 25/2.5,
            ),
            child: Divider(),
          ),
          RestaurantResume(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            vertical: 25/2.5,
            ),
            child: Divider(),
          ),
          RestaurantResume(),
            
        ],
      ),
    );
  }
}

class RestaurantResume extends StatelessWidget{
  const RestaurantResume({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(
              horizontal: 25,
            vertical: 25/2.5,
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 60,
                child: ClipOval( child: Image.asset('assets/5.png',height: 140,  fit: BoxFit.cover,)),
                  ),
                Row(
                children: [
                  const Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Restaurante", style: TextStyle(fontSize: 20),),
                    Text("Dirección", style: TextStyle(fontSize: 16),)
                  ],
                ) ,
                TextButton.icon(onPressed: () {}, icon: Icon(Icons.star), label: Text("4.3"))]
                )
            ],
          ),
          OthersSection(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text("Añadir a favoritos", style: TextStyle(fontSize: 16, color: Colors.white ), ),
                    Icon(Icons.favorite_border, color: Colors.white,)
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(255, 146, 45, 1)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        
                      )),)),
              TextButton(onPressed: () {}, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text("Como llegar", style: TextStyle(fontSize: 16, color: Colors.white ), ),
                    Icon(Icons.favorite_border, color: Colors.white,)
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(255, 146, 45,1)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        
                      )),))
            ],
          )

        ],
      ),
    );
  }
} 
class OthersSection extends StatelessWidget {
  const OthersSection({Key? key});

  @override
  Widget build(BuildContext context) {
    const items = 6;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items,
              itemBuilder: (context, index) => OtherWidget(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class OtherWidget extends StatelessWidget {
  const OtherWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(75.0),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Container(
          width: 120,
          color: Colors.white,
          //padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/$index.png',
                  height: 80,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Hamburguesa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Manrope',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  ' ${index + 1 * 10} K',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                      color: Color.fromRGBO(255, 146, 45, 1)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
