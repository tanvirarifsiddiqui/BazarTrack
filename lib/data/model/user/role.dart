enum UserRole { owner, assistant }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String value) {
    return value.toLowerCase() == 'owner' ? UserRole.owner : UserRole.assistant;
  }

  String toApi() {
    return this == UserRole.owner ? 'owner' : 'assistant';
  }
}
