class UserRegister {
  // final String id;
  // final int statusCategoryId;
  // final int claimTypeId;
  // final String picture;
  final String lastName;
  final String firstName; 
  final String? midName;
  final String? extName;
  // final String position;
  // final String department;
  // final String unit;
  // final String? email;
  final int mobile;
  // final String createdAt;

  UserRegister({required this.lastName, required this.firstName, this.midName, this.extName, required this.mobile});

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(lastName: json['last_name'], firstName: json['first_name'], midName: json['mid_name'], extName: json['ext_name'], mobile: int.parse(json['mobile']));
  }

}