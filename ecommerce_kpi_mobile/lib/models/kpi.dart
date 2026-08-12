class Kpi {
  final String employeeId;
  final String employeeName;
  final String department;
  final double todayRevenue;
  final int todayOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int lateOrders;
  final double responseRate;
  final double responseTime; // in minutes
  final int newProducts;
  final int updatedProducts;
  final double kpiOrder;
  final double kpiChat;
  final double kpiProduct;
  final double kpiRevenue;
  final double totalKpi;
  final int rank;
  final double rewardEstimate;
  final String? createdAt;
  final String? updatedAt;

  const Kpi({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.todayRevenue,
    required this.todayOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.lateOrders,
    required this.responseRate,
    required this.responseTime,
    required this.newProducts,
    required this.updatedProducts,
    required this.kpiOrder,
    required this.kpiChat,
    required this.kpiProduct,
    required this.kpiRevenue,
    required this.totalKpi,
    required this.rank,
    required this.rewardEstimate,
    this.createdAt,
    this.updatedAt,
  });

  factory Kpi.fromJson(Map<String, dynamic> json) {
    return Kpi(
      employeeId: json['employee_id']?.toString() ?? json['id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? json['full_name']?.toString() ?? 'Employee',
      department: json['department']?.toString() ?? 'Marketing',
      todayRevenue: double.tryParse(json['today_revenue']?.toString() ?? json['sales']?.toString() ?? '0.0') ?? 0.0,
      todayOrders: json['today_orders'] as int? ?? json['orders_today'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? json['orders_completed'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? json['orders_cancelled'] as int? ?? 0,
      lateOrders: json['late_orders'] as int? ?? json['orders_late'] as int? ?? 0,
      responseRate: double.tryParse(json['response_rate']?.toString() ?? '100.0') ?? 100.0,
      responseTime: double.tryParse(json['response_time']?.toString() ?? '0.0') ?? 0.0,
      newProducts: json['new_products'] as int? ?? 0,
      updatedProducts: json['updated_products'] as int? ?? 0,
      kpiOrder: double.tryParse(json['kpi_order']?.toString() ?? '0.0') ?? 0.0,
      kpiChat: double.tryParse(json['kpi_chat']?.toString() ?? '0.0') ?? 0.0,
      kpiProduct: double.tryParse(json['kpi_product']?.toString() ?? '0.0') ?? 0.0,
      kpiRevenue: double.tryParse(json['kpi_revenue']?.toString() ?? '0.0') ?? 0.0,
      totalKpi: double.tryParse(json['total_kpi']?.toString() ?? json['kpi']?.toString() ?? '0.0') ?? 0.0,
      rank: json['rank'] as int? ?? 1,
      rewardEstimate: double.tryParse(json['reward_estimate']?.toString() ?? json['bonus']?.toString() ?? '0.0') ?? 0.0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'department': department,
      'today_revenue': todayRevenue,
      'today_orders': todayOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'late_orders': lateOrders,
      'response_rate': responseRate,
      'response_time': responseTime,
      'new_products': newProducts,
      'updated_products': updatedProducts,
      'kpi_order': kpiOrder,
      'kpi_chat': kpiChat,
      'kpi_product': kpiProduct,
      'kpi_revenue': kpiRevenue,
      'total_kpi': totalKpi,
      'rank': rank,
      'reward_estimate': rewardEstimate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Kpi copyWith({
    String? employeeId,
    String? employeeName,
    String? department,
    double? todayRevenue,
    int? todayOrders,
    int? completedOrders,
    int? cancelledOrders,
    int? lateOrders,
    double? responseRate,
    double? responseTime,
    int? newProducts,
    int? updatedProducts,
    double? kpiOrder,
    double? kpiChat,
    double? kpiProduct,
    double? kpiRevenue,
    double? totalKpi,
    int? rank,
    double? rewardEstimate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Kpi(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      lateOrders: lateOrders ?? this.lateOrders,
      responseRate: responseRate ?? this.responseRate,
      responseTime: responseTime ?? this.responseTime,
      newProducts: newProducts ?? this.newProducts,
      updatedProducts: updatedProducts ?? this.updatedProducts,
      kpiOrder: kpiOrder ?? this.kpiOrder,
      kpiChat: kpiChat ?? this.kpiChat,
      kpiProduct: kpiProduct ?? this.kpiProduct,
      kpiRevenue: kpiRevenue ?? this.kpiRevenue,
      totalKpi: totalKpi ?? this.totalKpi,
      rank: rank ?? this.rank,
      rewardEstimate: rewardEstimate ?? this.rewardEstimate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
