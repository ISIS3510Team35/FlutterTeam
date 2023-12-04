import 'package:fud/services/models/restaurant_model.dart';
import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

/// Business Logic Component (BLoC) for managing restaurant-related functionality.
class RestaurantBloc {
  final _repository = Repository();
  final _restaurantFetcher = PublishSubject<Restaurant>();
  
  final _mostInteractedR = PublishSubject<RestaurantList>();

  /// Stream for accessing the details of a specific restaurant by ID.
  Stream<Restaurant> get restaurantDetails => _restaurantFetcher.stream;
  Stream<RestaurantList> get offerMostInt => _mostInteractedR.stream;
  
  /// Fetches the details of a specific restaurant by ID.
  Future<void> fetchRestaurantDetails(num id) async {
    try {
      Restaurant? restaurant = await _repository.fetchRestaurant(id);
      if (restaurant != null) {
        _restaurantFetcher.sink.add(restaurant);
      }
    } catch (error) {
      _restaurantFetcher.addError(error.toString());
    }
  }

  Future<void> fetchRestaurantMostInteracted() async {
    try {
      RestaurantList? restaurantList = await _repository.fetchRestaurantMostInteracted();
       _mostInteractedR.sink.add(restaurantList!);
      
    } catch (error) {
      print(error);
      _mostInteractedR.addError(error.toString());
    }
  }

  Future<void> addInteraction(num id) async{
    try {
      await _repository.addInteraction(id);
    }
    catch(error){
      print(error);
    }
  }
  /// Disposes the BLoC by closing the stream.
  void dispose() {
    _restaurantFetcher.close();
  }
}
