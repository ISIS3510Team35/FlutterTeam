import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

/// Business Logic Component (BLoC) for managing user-related functionality.
class UserBloc {
  final _repository = Repository();
  final _userFetcher = PublishSubject<bool>();

  /// Stream for accessing the result of the user existence check.
  Stream<bool> get userResult => _userFetcher.stream;

  /// Fetches information about the existence of a user with the provided credentials.
  Future<void> fetchUserExistence(String username, String password) async {
    try {
      bool userExists = await _repository.doesUserExist(username, password);
      _userFetcher.sink.add(userExists);
    } catch (error) {
      _userFetcher.addError(error.toString());
    }
  }

  /// Disposes the BLoC by closing the stream.
  void dispose() {
    _userFetcher.close();
  }
}
