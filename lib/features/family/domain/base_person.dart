/// Base OOP entity abstraction representing a person in the family domain.
/// Follows OOP Interface Segregation and Liskov Substitution principles.
abstract interface class BasePerson {
  String get id;
  String get username;
  String get fullName;
  String? get photoUrl;
  String? get bio;
}

/// OOP Polymorphic extensions for [BasePerson].
extension BasePersonX on BasePerson {
  String get displayName => fullName.isNotEmpty ? fullName : username;
  String get initials => fullName.isNotEmpty
      ? fullName[0].toUpperCase()
      : (username.isNotEmpty ? username[0].toUpperCase() : '?');
  String get firstName =>
      fullName.isNotEmpty ? fullName.split(' ')[0] : (username.isNotEmpty ? username : 'Member');
}
