import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../models/violation.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';
import '../helpers/firestore_helper.dart';

class AllEventsScreen extends StatefulWidget {
  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<Report> reports = [];
  List<Report> filteredReports = [];
  final _searchController = TextEditingController();
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
        _applyFilter();
      });
    });
  }

  Future<void> _loadData() async {
    final violationsData = await _db.getViolations();
    final stationsData = await _db.getStations();

    violations = {for (var v in violationsData) v.typeId!: v};
    stations = {for (var s in stationsData) s.stationId!: s};
  }

  void _applyFilter() {
    final query = _searchController.text;
    filteredReports = query.isEmpty
        ? reports
        : reports
              .where(
                (r) =>
                    _getViolationName(r.typeId).contains(query) ||
                    _getStationName(r.stationId).contains(query),
              )
              .toList();
  }

  String _getViolationName(int typeId) => violations[typeId]?.typeName ?? '-';
  String _getSeverity(int typeId) => violations[typeId]?.severity ?? 'Low';
  String _getStationName(int stationId) =>
      stations[stationId]?.stationName ?? '-';
  String _getZone(int stationId) => stations[stationId]?.zone ?? '-';

  Color _sevColor(String s) => s == 'High'
      ? AppColors.red
      : s == 'Medium'
      ? AppColors.orange
      : AppColors.green;

  void _filterReports(String query) {
    setState(() {
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 14),
            color: AppColors.red,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'เหตุการณ์ทั้งหมด',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterReports,
              decoration: InputDecoration(
                hintText: 'ค้นหาเหตุการณ์...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(
                    color: AppColors.grey300,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(
                    color: AppColors.grey300,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(
                    color: AppColors.red,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredReports.length,
                itemBuilder: (ctx, i) => _buildReportCard(filteredReports[i]),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final sev = _getSeverity(report.typeId);
    Color sevColor = _sevColor(sev);
    String sevLabel = sev == 'High'
        ? 'HIGH'
        : sev == 'Medium'
        ? 'MED'
        : 'LOW';
    Color sevBg = sev == 'High'
        ? AppColors.redLight
        : sev == 'Medium'
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/report_detail', arguments: report),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
          children: [
            Container(
              width: 10,
              height: 10,
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
                    '#${report.reportId.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getViolationName(report.typeId),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: 11,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_getStationName(report.stationId)} · ${_getZone(report.stationId)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.clock,
                        size: 11,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.timestamp,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sevBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    sevLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sevColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.grey300,
                  size: 16,
                ),
              ],
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
            _navItem(
              CupertinoIcons.house_fill,
              'หน้าหลัก',
              false,
              () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            _navItem(CupertinoIcons.list_bullet, 'เหตุการณ์', true, () {}),
            _navItem(
              CupertinoIcons.chart_bar_fill,
              'สถิติ',
              false,
              () => Navigator.pushReplacementNamed(context, '/stats'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? AppColors.red : AppColors.grey500,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? AppColors.red : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
