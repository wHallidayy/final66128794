import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../models/violation.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';
import '../helpers/firestore_helper.dart';

class AllIncidentScreen extends StatefulWidget {
  @override
  _AllIncidentScreenState createState() => _AllIncidentScreenState();
}

class _AllIncidentScreenState extends State<AllIncidentScreen> {
  List<Report> reports = [];
  List<Report> filteredReports = [];
  final _searchController = TextEditingController();
  Map<int, Violation> violations = {};
  Map<int, Station> stations = {};
  String? _selectedSeverity;

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
    final query = _searchController.text.toLowerCase();
    filteredReports = query.isEmpty
        ? reports
        : reports
              .where(
                (r) =>
                    _getViolationName(r.typeId).toLowerCase().contains(query) ||
                    _getStationName(
                      r.stationId,
                    ).toLowerCase().contains(query) ||
                    r.reporterName.toLowerCase().contains(query) ||
                    r.description.toLowerCase().contains(query),
              )
              .toList();
    if (_selectedSeverity != null && _selectedSeverity!.isNotEmpty) {
      filteredReports = filteredReports
          .where((r) => _getSeverity(r.typeId) == _selectedSeverity)
          .toList();
    }
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
      _loadFilteredReports();
    });
  }

  Future<void> _loadFilteredReports() async {
    final searchQuery = _searchController.text.isEmpty
        ? null
        : _searchController.text;
    final results = await _db.getFilteredReports(
      searchQuery: searchQuery,
      severity: _selectedSeverity,
    );
    violations = {for (var v in (await _db.getViolations())) v.typeId!: v};
    stations = {for (var s in (await _db.getStations())) s.stationId!: s};
    setState(() {
      filteredReports = results;
    });
  }

  void _onSeverityChanged(String? value) {
    setState(() {
      _selectedSeverity = value;
      _loadFilteredReports();
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
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey300, width: 1),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSeverity,
                    hint: const Text('ทั้งหมด', style: TextStyle(fontSize: 14)),
                    underline: const SizedBox(),
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                    ],
                    onChanged: _onSeverityChanged,
                  ),
                ),
              ],
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
            _navItem(
              CupertinoIcons.add,
              'รายงานเหตุการณ์',
              false,
              () => Navigator.pushReplacementNamed(context, '/select_station'),
            ),
            _navItem(CupertinoIcons.list_bullet, 'เหตุการณ์', true, () {}),
            _navItem(
              CupertinoIcons.location_solid,
              'หน่วยเลือกตั้ง',
              false,
              () => Navigator.pushReplacementNamed(context, '/polling_station'),
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
