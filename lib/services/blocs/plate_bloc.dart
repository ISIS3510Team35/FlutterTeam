import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';
import '../models/plate_model.dart';

/// Business Logic Component (BLoC) for managing Plate-related functionality.
class PlateBloc {
  final _repository = Repository();

  final _plateTop3Fetcher = PublishSubject<PlateList>();
  final _plateOfferFetcher = PublishSubject<PlateList>();
  final _plateIdFetcher = PublishSubject<Plate>();
  final _isFavFetcher = PublishSubject<bool>();
  final _isRemAddFetcher = PublishSubject<bool>();
  final _favoritiesFetcher = PublishSubject<PlateList>();
  final _filterFetcher = PublishSubject<Map<num, List>>();
  final _recomendationFetcher = PublishSubject<PlateList>();
  final _categoryOrRestaurantFetcher = PublishSubject<PlateList>();
  final _MinMaxPriceRestaurant = PublishSubject<PlateList>();

  /// Stream for accessing the list of plates offered.
  Stream<PlateList> get offerPlates => _plateOfferFetcher.stream;

  /// Stream for accessing the top 3 plates.
  Stream<PlateList> get top3Plates => _plateTop3Fetcher.stream;

  /// Stream for accessing the details of a specific plate by ID.
  Stream<Plate> get idPlate => _plateIdFetcher.stream;

  /// Stream for checking if a plate is marked as a favorite.
  Stream<bool> get isFav => _isFavFetcher.stream;

  /// Stream for checking if a plate is added or removed from favorites.
  Stream<bool> get isAddRemFav => _isRemAddFetcher.stream;

  /// Stream for accessing the list of favorite plates.
  Stream<PlateList> get favPlates => _favoritiesFetcher.stream;

  /// Stream for accessing filter information based on maxPrice, vegetariano, and vegano.
  Stream<Map<num, List>> get filterPlates => _filterFetcher.stream;

  /// Stream for accessing recomendations
  Stream<PlateList> get recomendationPlates => _recomendationFetcher.stream;

  /// Stream for categry or restaurant plates
  Stream<PlateList> get categoryPlates => _categoryOrRestaurantFetcher.stream;

  Stream<PlateList> get minmaxPlates => _MinMaxPriceRestaurant.stream;

  /// Fetches the list of plates offered.
  Future<void> fetchOfferPlates() async {
    try {
      PlateList plateOfferList = await _repository.fetchOfferPlates();
      _plateOfferFetcher.sink.add(plateOfferList);
    } catch (error) {
      _plateOfferFetcher.addError(error.toString());
    }
  }

  /// Fetches the top 3 plates.
  Future<void> fetchTop3Plates() async {
    try {
      PlateList plateTop3List = await _repository.fetchTop3Plates();
      _plateTop3Fetcher.sink.add(plateTop3List);
    } catch (error) {
      _plateTop3Fetcher.addError(error.toString());
    }
  }

  /// Fetches the details of a specific plate by ID.
  Future<void> fetchPlate(num id) async {
    try {
      Plate? plate = await _repository.fetchPlate(id);
      if (plate != null) {
        _plateIdFetcher.sink.add(plate);
      }
    } catch (error) {
      _plateIdFetcher.addError(error.toString());
    }
  }

  /// Fetches whether a plate is marked as a favorite.
  Future<void> fetchIsFavorite(num id) async {
    try {
      bool isFav = await _repository.fetchIsFavorite(id);
      _isFavFetcher.sink.add(isFav);
    } catch (error) {
      _isFavFetcher.addError(error.toString());
    }
  }

  /// Fetches whether a plate is added or removed from favorites.
  Future<void> fetchAddRemoveFavorite(num id) async {
    try {
      bool isAddRemFav = await _repository.fetchAddRemoveFavorite(id);
      _isRemAddFetcher.sink.add(isAddRemFav);
    } catch (error) {
      _isRemAddFetcher.addError(error.toString());
    }
  }

  /// Fetches the list of favorite plates.
  Future<void> fetchFavoritePlates() async {
    try {
      PlateList plateFavList = await _repository.fetchFavorites();
      _favoritiesFetcher.sink.add(plateFavList);
    } catch (error) {
      _favoritiesFetcher.addError(error.toString());
    }
  }

  /// Fetches analytic data for favorite plates.
  Future<void> fetchAnalyticFavorite(bool now, bool startTime) async {
    try {
      await _repository.fetchAnalyticFavorite(now, startTime);
    } catch (error) {
      _favoritiesFetcher.addError(error.toString());
    }
  }

  /// Fetches filter information based on maxPrice, vegetariano, and vegano.
  Future<void> fetchFilterInfo(
      double maxPrice, bool vegetariano, bool vegano) async {
    try {
      Map<num, List> filterInfo =
          await _repository.fetchFilterInfo(maxPrice, vegetariano, vegano);
      _filterFetcher.sink.add(filterInfo);
    } catch (error) {
      _filterFetcher.addError(error.toString());
    }
  }

  /// Fetches recomended plates based on maxPrice, vegetariano, and vegano.
  Future<void> fetchRecomendedPlates() async {
    try {
      PlateList platerecomendationList =
          await _repository.fetchRecomendations();
      _recomendationFetcher.sink.add(platerecomendationList);
    } catch (error) {
      _recomendationFetcher.addError(error.toString());
    }
  }

  /// Fetches the list of plates offered.
  Future<void> fetchCategoryOrRestaurantPlates(
      String category, num restaurantId) {
    return _repository
        .fetchPlatesCategoryOrRestaurant(category, restaurantId)
        .then((PlateList plateCategoryOrRestaurantsList) {
      _categoryOrRestaurantFetcher.sink.add(plateCategoryOrRestaurantsList);
    }).catchError((error) {
      print(error);
      _categoryOrRestaurantFetcher.addError(error.toString());
    });
  }

  Future<void> fetchMinMaxPrice(num rest){
    return _repository
        .fetchMinMaxPrice(rest)
        .then((PlateList plates) {
      _MinMaxPriceRestaurant.sink.add(plates);
    }).catchError((error) {
      print(error);
      _MinMaxPriceRestaurant.addError(error.toString());
    });
  }

  /// Disposes the BLoC by closing all the streams.
  void dispose() {
    _plateTop3Fetcher.close();
    _plateOfferFetcher.close();
    _plateIdFetcher.close();
    _isFavFetcher.close();
    _isRemAddFetcher.close();
    _favoritiesFetcher.close();
    _filterFetcher.close();
    _categoryOrRestaurantFetcher.close();
    _MinMaxPriceRestaurant.close();
  }
}
