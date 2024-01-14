class Utilisateur {
  String nom;
  String prenom;
  String email;
  String password;

  Utilisateur({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
    };
  }
}
