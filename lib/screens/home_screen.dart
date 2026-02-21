import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../models/violation.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';
import '../helpers/firestore_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Report> reports = [];
  int _currentNavIndex = 0;
  Map<int, Violation> violations = {};
  Map<int, Station> stations = {};

  final _db = DatabaseHelper();
  final _firestore = FirestoreHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startListening();
  }

  @override
  void dispose() {
    _firestore.stopListeningToReports();
    super.dispose();
  }

  void _startListening() {
    _firestore.listenToReports((newReports) {
      setState(() {
        reports = newReports;
      });
    });
  }

  Future<void> _loadData() async {
    final reportsData = await _db.getReports();
    final violationsData = await _db.getViolations();
    final stationsData = await _db.getStations();

    violations = {for (var v in violationsData) v.typeId!: v};
    stations = {for (var s in stationsData) s.stationId!: s};

    setState(() => reports = reportsData);
  }

  String _getViolationName(int typeId) {
    return violations[typeId]?.typeName ?? '-';
  }

  String _getSeverity(int typeId) {
    return violations[typeId]?.severity ?? 'Low';
  }

  String _getStationName(int stationId) {
    return stations[stationId]?.stationName ?? '-';
  }

  String _getZone(int stationId) {
    return stations[stationId]?.zone ?? '-';
  }

  int get highCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'High').length;
  int get medCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'Medium').length;
  int get lowCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'Low').length;

  Color _sevColor(String s) => s == 'High'
      ? AppColors.red
      : s == 'Medium'
      ? AppColors.orange
      : AppColors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.red, AppColors.redDark],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รายงานทุจริตเลือกตั้ง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/select_station'),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.red.withOpacity(0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.red.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_bubble_fill,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'แจ้งเหตุใหม่',
                                      style: TextStyle(
                                        color: AppColors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'แตะเพื่อเริ่มรายงานเหตุทุจริต',
                                      style: TextStyle(
                                        color: AppColors.grey500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_right,
                                color: AppColors.grey300,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                CupertinoIcons.chart_bar_fill,
                                size: 16,
                                color: AppColors.grey700,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'สถิติวันนี้',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/stats'),
                            child: const Text(
                              'ดูทั้งหมด',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildStatCard(
                            '$highCount',
                            'ร้ายแรง',
                            AppColors.red,
                            CupertinoIcons.circle_fill,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            '$medCount',
                            'ปานกลาง',
                            AppColors.orange,
                            CupertinoIcons.circle_fill,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            '$lowCount',
                            'เล็กน้อย',
                            AppColors.green,
                            CupertinoIcons.circle_fill,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                CupertinoIcons.circle_fill,
                                size: 10,
                                color: AppColors.red,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'เหตุการณ์ล่าสุด',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/all_events'),
                            child: const Text(
                              'ดูทั้งหมด',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...reports.map((report) => _buildFeedCard(report)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String num, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              num,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 8, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(Report report) {
    final sev = _getSeverity(report.typeId);
    Color sevColor = _sevColor(sev);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/report_detail', arguments: report),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: sevColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: sevColor.withOpacity(0.15), spreadRadius: 3),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getViolationName(report.typeId),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getStationName(report.stationId)} · ${_getZone(report.stationId)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              report.timestamp.substring(11, 16),
              style: const TextStyle(fontSize: 11, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey200, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(0, CupertinoIcons.house_fill, 'หน้าหลัก', () {}),
            _buildNavItem(1, CupertinoIcons.list_bullet, 'เหตุการณ์', () {
              Navigator.pushNamed(context, '/all_events');
            }),
            _buildNavItem(2, CupertinoIcons.chart_bar_fill, 'สถิติ', () {
              Navigator.pushNamed(context, '/stats');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isActive = _currentNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.red : AppColors.grey500,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppColors.red : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
