class UserRegister {
  final String lastName;
  final String firstName; 
  final String? midName;
  final String? extName;
  final int mobile;

  UserRegister({required this.lastName, required this.firstName, this.midName, this.extName, required this.mobile});

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(lastName: json['last_name'], firstName: json['first_name'], midName: json['mid_name'], extName: json['ext_name'], mobile: int.parse(json['mobile']));
  }

}