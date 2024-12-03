// this class demonstrates what a 'User' is
class User {
  final int? id;
  final String name;
  final String pass;

  User({this.id, required this.name, required this.pass});
  User.fromMap(Map<String, dynamic> res)
    : id = res["id"],
      name = res["name"],
      pass = res["pass"];
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'pass': pass};
  }
}
