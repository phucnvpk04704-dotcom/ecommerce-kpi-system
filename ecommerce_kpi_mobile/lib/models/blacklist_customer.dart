class BlacklistCustomer {
  final String id;
  final String customerName;
  final String phone;
  final String platform;
  final String riskLevel; // High, Warning, Safe/Low
  final int cancelCount;
  final int returnCount;
  final int complaintCount;
  final String? lastOrderDate;
  final String? lastViolationDate;
  final String status; // Active, Resolved
  final String note;
  final String? createdAt;
  final String? updatedAt;

  const BlacklistCustomer({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.platform,
    required this.riskLevel,
    required this.cancelCount,
    required this.returnCount,
    required this.complaintCount,
    this.lastOrderDate,
    this.lastViolationDate,
    required this.status,
    required this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory BlacklistCustomer.fromJson(Map<String, dynamic> json) {
    return BlacklistCustomer(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? json['customerName']?.toString() ?? json['name']?.toString() ?? 'Customer',
      phone: json['phone']?.toString() ?? '',
      platform: json['platform']?.toString() ?? 'Shopee',
      riskLevel: json['risk_level']?.toString() ?? json['riskLevel']?.toString() ?? 'Warning',
      cancelCount: int.tryParse(json['cancel_count']?.toString() ?? json['cancelCount']?.toString() ?? '0') ?? 0,
      returnCount: int.tryParse(json['return_count']?.toString() ?? json['returnCount']?.toString() ?? '0') ?? 0,
      complaintCount: int.tryParse(json['complaint_count']?.toString() ?? json['complaintCount']?.toString() ?? '0') ?? 0,
      lastOrderDate: json['last_order_date']?.toString() ?? json['lastOrderDate']?.toString(),
      lastViolationDate: json['last_violation_date']?.toString() ?? json['lastViolationDate']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      note: json['note']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'phone': phone,
      'platform': platform,
      'risk_level': riskLevel,
      'cancel_count': cancelCount,
      'return_count': returnCount,
      'complaint_count': complaintCount,
      'last_order_date': lastOrderDate,
      'last_violation_date': lastViolationDate,
      'status': status,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  BlacklistCustomer copyWith({
    String? id,
    String? customerName,
    String? phone,
    String? platform,
    String? riskLevel,
    int? cancelCount,
    int? returnCount,
    int? complaintCount,
    String? lastOrderDate,
    String? lastViolationDate,
    String? status,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return BlacklistCustomer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      platform: platform ?? this.platform,
      riskLevel: riskLevel ?? this.riskLevel,
      cancelCount: cancelCount ?? this.cancelCount,
      returnCount: returnCount ?? this.returnCount,
      complaintCount: complaintCount ?? this.complaintCount,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      lastViolationDate: lastViolationDate ?? this.lastViolationDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
