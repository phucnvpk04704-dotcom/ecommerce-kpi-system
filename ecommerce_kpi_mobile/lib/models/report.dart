class Report {
  final String id;
  final String title;
  final String reportType; // e.g. Revenue, Orders, Products, General
  final String platform; // e.g. Shopee
  final String period; // e.g. Daily, Weekly, Monthly
  final String generatedAt;
  final double totalRevenue;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int returnOrders;
  final double averageOrderValue;
  final String topEmployee;
  final String topProduct;
  final String status; // e.g. Completed, Draft

  const Report({
    required this.id,
    required this.title,
    required this.reportType,
    required this.platform,
    required this.period,
    required this.generatedAt,
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.returnOrders,
    required this.averageOrderValue,
    required this.topEmployee,
    required this.topProduct,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Analytics Report',
      reportType: json['report_type']?.toString() ?? json['reportType']?.toString() ?? 'General',
      platform: json['platform']?.toString() ?? 'Shopee',
      period: json['period']?.toString() ?? 'Monthly',
      generatedAt: json['generated_at']?.toString() ?? json['generatedAt']?.toString() ?? '',
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? json['totalRevenue']?.toString() ?? '0.0') ?? 0.0,
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? json['totalOrders']?.toString() ?? '0') ?? 0,
      completedOrders: int.tryParse(json['completed_orders']?.toString() ?? json['completedOrders']?.toString() ?? '0') ?? 0,
      cancelledOrders: int.tryParse(json['cancelled_orders']?.toString() ?? json['cancelledOrders']?.toString() ?? '0') ?? 0,
      returnOrders: int.tryParse(json['return_orders']?.toString() ?? json['returnOrders']?.toString() ?? '0') ?? 0,
      averageOrderValue: double.tryParse(json['average_order_value']?.toString() ?? json['averageOrderValue']?.toString() ?? '0.0') ?? 0.0,
      topEmployee: json['top_employee']?.toString() ?? json['topEmployee']?.toString() ?? 'None',
      topProduct: json['top_product']?.toString() ?? json['topProduct']?.toString() ?? 'None',
      status: json['status']?.toString() ?? 'Completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'report_type': reportType,
      'platform': platform,
      'period': period,
      'generated_at': generatedAt,
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'return_orders': returnOrders,
      'average_order_value': averageOrderValue,
      'top_employee': topEmployee,
      'top_product': topProduct,
      'status': status,
    };
  }

  Report copyWith({
    String? id,
    String? title,
    String? reportType,
    String? platform,
    String? period,
    String? generatedAt,
    double? totalRevenue,
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    int? returnOrders,
    double? averageOrderValue,
    String? topEmployee,
    String? topProduct,
    String? status,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      platform: platform ?? this.platform,
      period: period ?? this.period,
      generatedAt: generatedAt ?? this.generatedAt,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      returnOrders: returnOrders ?? this.returnOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      topEmployee: topEmployee ?? this.topEmployee,
      topProduct: topProduct ?? this.topProduct,
      status: status ?? this.status,
    );
  }
}
