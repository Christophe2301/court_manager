class Adherent {
  final String firstName;
  final String lastName;
  bool present;

  Adherent({
    required this.firstName,
    required this.lastName,
    this.present = false,
  });

  String get fullName => '$firstName $lastName';
}