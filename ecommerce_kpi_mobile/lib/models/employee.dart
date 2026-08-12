class Employee {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String platform;
  final String status;
  final double todayRevenue;
  final int todayOrders;
  final double todayKpi;
  final double bonus;
  final String avatar;
  final String? createdAt;
  final String? updatedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.platform,
    required this.status,
    required this.todayRevenue,
    required this.todayOrders,
    required this.todayKpi,
    required this.bonus,
    required this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Determine avatar
    final name = json['full_name'] ?? json['name'] ?? '';
    String parsedAvatar = json['avatar'] ?? '';
    if (parsedAvatar.isEmpty && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        parsedAvatar = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else {
        parsedAvatar = name.substring(0, mathMin(2, name.length)).toUpperCase();
      }
    }

    return Employee(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? json['username']?.toString() ?? '',
      fullName: name,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Employee',
      department: json['department']?.toString() ?? 'Marketing',
      platform: json['platform']?.toString() ?? 'Shopee',
      status: json['status']?.toString() ?? 'Active',
      todayRevenue: double.tryParse(json['today_revenue']?.toString() ?? json['sales']?.toString() ?? '0.0') ?? 0.0,
      todayOrders: json['today_orders'] as int? ?? json['orders_today'] as int? ?? 0,
      todayKpi: double.tryParse(json['today_kpi']?.toString() ?? json['kpi']?.toString() ?? '0.0') ?? 0.0,
      bonus: double.tryParse(json['bonus']?.toString() ?? '0.0') ?? 0.0,
      avatar: parsedAvatar.isEmpty ? 'EM' : parsedAvatar,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'department': department,
      'platform': platform,
      'status': status,
      'today_revenue': todayRevenue,
      'today_orders': todayOrders,
      'today_kpi': todayKpi,
      'bonus': bonus,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? department,
    String? platform,
    String? status,
    double? todayRevenue,
    int? todayOrders,
    double? todayKpi,
    double? bonus,
    String? avatar,
    String? createdAt,
    String? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      todayKpi: todayKpi ?? this.todayKpi,
      bonus: bonus ?? this.bonus,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int mathMin(int a, int b) => a < b ? a : b;
}
