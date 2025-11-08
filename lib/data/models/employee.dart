class Employee {
  final String id;
  final String employeeId;
  final String fullName;
  final String? email;
  final String? department;
  final bool isActive;

  Employee({
    required this.id,
    required this.employeeId,
    required this.fullName,
    this.email,
    this.department,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      department: json['department'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'email': email,
      'department': department,
      'is_active': isActive,
    };
  }
}
