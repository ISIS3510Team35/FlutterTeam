import 'package:flutter/material.dart';
import 'package:fud/appHeader.dart';
import 'package:fud/plateOffer.dart';

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
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        children: const [
          CategorySection(),
          SizedBox(height: 7),
          LunchSection(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------------ Almuerzos para ti

class LunchSection extends StatelessWidget {
  const LunchSection({Key? key});

  @override
  Widget build(BuildContext context) {
    const items = 3;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Almuerzos para ti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 321,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items,
              itemBuilder: (context, index) => ItemWidget(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la vista deseada aquí, por ejemplo:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const PlateOfferPage(), // Reemplaza 'TuOtraVista' con el nombre de tu vista
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(75.0),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Container(
            width: 200,
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/$index.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hamburguesa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Item $index',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${index + 1 * 10} K ',
                    style: const TextStyle(
                        fontSize: 20,
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
      ),
    );
  }
}

// ------------------------------------------------------------------------------ Categorias

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key});

  @override
  Widget build(BuildContext context) {
    const items = 6;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Categorias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
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
                const Text(
                  'Almuerzo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Manrope',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Image.asset(
                  'assets/$index.png',
                  height: 80,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
