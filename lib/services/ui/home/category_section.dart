import 'package:flutter/material.dart';
import 'package:fud/services/ui/detail/seeAll.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int currentHour = now.hour;

    List<CategoryItem> categoryItems = [
      CategoryItem(index: 0, currentHour: currentHour),
      CategoryItem(index: 1, currentHour: currentHour),
      CategoryItem(index: 2, currentHour: currentHour),
    ];

    List<CategoryItem> visibleItems =
        categoryItems.where((item) => item.shouldShowCard()).toList();

    return Container(
      padding: const EdgeInsets.all(3),
      alignment: Alignment.bottomLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Row(
            children: visibleItems,
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    Key? key,
    required this.index,
    required this.currentHour,
  }) : super(key: key);

  final int index;
  final int currentHour;

  @override
  Widget build(BuildContext context) {
    String category = getCategoryName(index);

    return GestureDetector(
      onTap: () {
        num restaurantId = 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllPlates(
              category: category,
              restaurantId: restaurantId,
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(245, 90, 81, 1),
          ),
          onPressed: () {
            num restaurantId = 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPlates(
                  category: category,
                  restaurantId: restaurantId,
                ),
              ),
            );
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hora de $category: Ver platos.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getCategoryName(int index) {
    List<String> categories = ['Desayuno', 'Almuerzo', 'Cena'];
    return categories[index];
  }

  bool shouldShowCard() {
    if (index == 0) {
      return currentHour >= 4 && currentHour < 11;
    } else if (index == 1) {
      return currentHour >= 11 && currentHour < 16;
    } else if (index == 2) {
      return currentHour >= 16 || currentHour < 4;
    }
    return false;
  }
}
