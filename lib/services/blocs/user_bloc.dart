import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

final logger = Logger();

class UserBloc {
  final _repository = Repository();
  final _userFetcher = PublishSubject<bool>();

  Stream<bool> get userResult => _userFetcher.stream;

  Future<void> fetchUserExistence(String username, String password) async {
    try {
      bool userExists = await _repository.doesUserExist(username, password);
      _userFetcher.sink.add(userExists);
    } catch (error) {
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> fetchOnlyUserExistence(String username) async {
    try {
      bool userExists = await _repository.doesOnlyUserExist(username);
      _userFetcher.sink.add(userExists);
    } catch (error) {
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> registerUser(
      String username, String name, String phone, String password) async {
    try {
      bool registrationSuccessful =
          await _repository.addUser(username, name, phone, password);
      _userFetcher.sink.add(registrationSuccessful);
    } catch (error) {
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> timeView(int duration, String view) async {
    try {
      bool registrationSuccessful =
          await _repository.addTimeView(duration, view);
      _userFetcher.sink.add(registrationSuccessful);
    } catch (error) {
      try {
        _userFetcher.addError(error.toString());
      } catch (error) {
        logger.d(error);
      }
    }
  }

  Future<void> changeUserInfo(String newUser, String newNumber) async {
    try {
      await _repository.changeUserInfo(newUser, newNumber);
    } catch (error) {
      logger.d(error);
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> changePassword(String username, String newPassword) async {
    try {
      await _repository.changePassword(username, newPassword);
    } catch (error) {
      logger.d(error);
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _repository.deleteInfo();
    } catch (error) {
      logger.d(error);
      _userFetcher.addError(error.toString());
    }
  }

  void dispose() {
    _userFetcher.close();
  }
}
