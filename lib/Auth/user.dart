class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  @override
  
  String toString() {
    return 'User(username: $username, password: $password)!';
  }

}