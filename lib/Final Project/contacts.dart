class Contacts {
  final String id;
  final String email;
  final String image;
  final String name;
  final String phone;
  final String user;
  Contacts({
    required this.id,
    required this.email,
    required this.image,
    required this.name,
    required this.phone,
    required this.user,
  });

  static Contacts fromJson(Map<String, dynamic> json) => Contacts(
        id: json['id'],
        email: json['email'],
        image: json['image'],
        name: json['name'],
        phone: json['phone'],
        user: json['user'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'email': email,
        'name': name,
        'phone': phone,
        'user': user,
      };
}
