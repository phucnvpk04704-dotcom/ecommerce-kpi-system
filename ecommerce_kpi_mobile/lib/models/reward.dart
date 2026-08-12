class Reward {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String period; // e.g. monthly, weekly
  final double kpiScore;
  final double rewardAmount;
  final String rewardType; // e.g. Cash Bonus, Gift Card, Extra Leave
  final String rewardStatus; // e.g. Pending, Approved, Rejected
  final String? approvedBy;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;

  const Reward({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.period,
    required this.kpiScore,
    required this.rewardAmount,
    required this.rewardType,
    required this.rewardStatus,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? json['employeeId']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? json['employeeName']?.toString() ?? json['full_name']?.toString() ?? 'Employee',
      department: json['department']?.toString() ?? 'Marketing',
      period: json['period']?.toString() ?? 'monthly',
      kpiScore: double.tryParse(json['kpi_score']?.toString() ?? json['kpiScore']?.toString() ?? json['kpi']?.toString() ?? '0.0') ?? 0.0,
      rewardAmount: double.tryParse(json['reward_amount']?.toString() ?? json['rewardAmount']?.toString() ?? json['bonus']?.toString() ?? '0.0') ?? 0.0,
      rewardType: json['reward_type']?.toString() ?? json['rewardType']?.toString() ?? 'Cash Bonus',
      rewardStatus: json['reward_status']?.toString() ?? json['rewardStatus']?.toString() ?? json['status']?.toString() ?? 'Pending',
      approvedBy: json['approved_by']?.toString() ?? json['approvedBy']?.toString(),
      approvedAt: json['approved_at']?.toString() ?? json['approvedAt']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'department': department,
      'period': period,
      'kpi_score': kpiScore,
      'reward_amount': rewardAmount,
      'reward_type': rewardType,
      'reward_status': rewardStatus,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Reward copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? department,
    String? period,
    double? kpiScore,
    double? rewardAmount,
    String? rewardType,
    String? rewardStatus,
    String? approvedBy,
    String? approvedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return Reward(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      period: period ?? this.period,
      kpiScore: kpiScore ?? this.kpiScore,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      rewardType: rewardType ?? this.rewardType,
      rewardStatus: rewardStatus ?? this.rewardStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
