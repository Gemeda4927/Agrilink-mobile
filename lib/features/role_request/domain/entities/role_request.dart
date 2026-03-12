class RoleRequest {
  final String id;
  final String userId;
  final String requestedRole;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoleRequest({
    required this.id,
    required this.userId,
    required this.requestedRole,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}