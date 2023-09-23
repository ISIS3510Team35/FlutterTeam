import 'package:flutter/material.dart';
import 'package:fud/appHeader.dart';

class PlateOfferPage extends StatefulWidget {
  static const routeName = '/PlateOffer';

  const PlateOfferPage({Key? key}) : super(key: key);

  @override
  State<PlateOfferPage> createState() => _PlateOfferPageState();
}

class _PlateOfferPageState extends State<PlateOfferPage> {
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
          ImageWithCaptionSection(),
          OneCardSection(),
          OthersSection()
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      color: Colors.deepOrange,
      child: const Text(
        'Header Title',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImageWithCaptionSection extends StatelessWidget {
  const ImageWithCaptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              'assets/1.png',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class OneCardSection extends StatelessWidget {
  const OneCardSection({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Almuerzo del Día',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Manrope',
                ),
              ),
              SizedBox(width: 50),
              Icon(
                Icons.star,
                color: Color.fromARGB(255, 188, 91, 1),
              ),
              Text(
                '4.3',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          const Text(
            'Cafeteria Central Uniandes',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 0),
          const Text(
            '13.9 K',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
              color: Color.fromRGBO(255, 146, 45, 1),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 0),
          Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
              height: 16), // Add some space between the card and the buttons
          ButtonRow(), // Include the ButtonRow widget here
        ],
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({Key? key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 135,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              label: const Text(
                'Añadir a favoritos',
                style: TextStyle(color: Colors.white), // White text color
              ),
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white, // White icon color
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 146, 45, 1), // Red background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Optional: Rounded corners
                ),
              ),
            )),
        const SizedBox(width: 8),
        SizedBox(
            width: 120,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              label: const Text(
                '¿Cómo llegar?',
                style: TextStyle(color: Colors.white), // White text color
              ),
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white, // White icon color
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 146, 45, 1), // Red background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Optional: Rounded corners
                ),
              ),
            )),
      ],
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
          const Text(
            'Otros Platos',
            style: TextStyle(
              fontSize: 18,
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
        margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
