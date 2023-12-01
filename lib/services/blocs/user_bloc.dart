import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class UserBloc {
  final _repository = Repository();
  final _userFetcher = PublishSubject<bool>();

  // Private constructor
  UserBloc._private();

  // Singleton instance
  static final UserBloc _instance = UserBloc._private();

  factory UserBloc() {
    return _instance;
  }

  Stream<bool> get userResult => _userFetcher.stream;

  Future<void> fetchUserExistence(String username, String password) async {
    try {
      bool userExists = await _repository.doesUserExist(username, password);
      _userFetcher.sink.add(userExists);
    } catch (error) {
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> changeUserInfo(String newUser, String newNumber) async {
    try{
      await _repository.changeUserInfo(newUser, newNumber);
    }
    catch(error){
      print(error);
      _userFetcher.addError(error.toString());
    }
  }

  Future<void> deleteAccount()async{
    try{
      await _repository.deleteInfo();
    }
    catch(error){
      print(error);
      _userFetcher.addError(error.toString());
    }
  }

  void dispose() {
    _userFetcher.close();
  }
}
