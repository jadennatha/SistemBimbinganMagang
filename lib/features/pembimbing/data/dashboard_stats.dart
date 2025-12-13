/// Dashboard statistics model
class DashboardStats {
  final int totalLogbooks;
  final int approvedCount;
  final int revisionCount;
  final int pendingCount;
  final int studentCount;

  const DashboardStats({
    required this.totalLogbooks,
    required this.approvedCount,
    required this.revisionCount,
    required this.pendingCount,
    required this.studentCount,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalLogbooks: 0,
      approvedCount: 0,
      revisionCount: 0,
      pendingCount: 0,
      studentCount: 0,
    );
  }
}
