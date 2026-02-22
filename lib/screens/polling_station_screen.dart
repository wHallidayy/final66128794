import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../models/violation.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';

class PollingStationScreen extends StatefulWidget {
  @override
  _PollingStationScreenState createState() => _PollingStationScreenState();
}

class _PollingStationScreenState extends State<PollingStationScreen> {
  List<Report> reports = [];
  Map<int, Violation> violations = {};
  Map<int, Station> stations = {};

  final _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reportsData = await _db.getReports();
    final violationsData = await _db.getViolations();
    final stationsData = await _db.getStations();

    violations = {for (var v in violationsData) v.typeId!: v};
    stations = {for (var s in stationsData) s.stationId!: s};

    setState(() => reports = reportsData);
  }

  String _getSeverity(int typeId) => violations[typeId]?.severity ?? 'Low';
  String _getViolationName(int typeId) => violations[typeId]?.typeName ?? '-';
  String _getZone(int stationId) => stations[stationId]?.zone ?? '-';

  int get highCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'High').length;
  int get medCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'Medium').length;
  int get lowCount =>
      reports.where((r) => _getSeverity(r.typeId) == 'Low').length;

  /// Group reports by violation typeName
  Map<String, int> get _byViolation {
    final map = <String, int>{};
    for (final r in reports) {
      final name = _getViolationName(r.typeId);
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  /// Group reports by zone
  Map<String, int> get _byZone {
    final map = <String, int>{};
    for (final r in reports) {
      final zone = _getZone(r.stationId);
      map[zone] = (map[zone] ?? 0) + 1;
    }
    // Sort by zone name
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
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
                Text(
                  'หน่วยเลือกตั้ง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Severity stat cards
                    Row(
                      children: [
                        _statCard('$highCount', 'ร้ายแรง', AppColors.red),
                        const SizedBox(width: 10),
                        _statCard('$medCount', 'ปานกลาง', AppColors.orange),
                        const SizedBox(width: 10),
                        _statCard('$lowCount', 'เล็กน้อย', AppColors.green),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Total card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.chart_bar_alt_fill,
                            size: 40,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'รายงานทั้งหมดวันนี้',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey500,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${reports.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'เหตุการณ์',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Accordion: By Violation Type
                    _accordionCard(
                      icon: CupertinoIcons.exclamationmark_triangle_fill,
                      title: 'แบ่งตามประเภทความผิด',
                      data: _byViolation,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 14),
                    // Accordion: By Zone
                    _accordionCard(
                      icon: CupertinoIcons.map_fill,
                      title: 'แบ่งตามเขต',
                      data: _byZone,
                      color: AppColors.orange,
                      suffix: 'เหตุการณ์',
                    ),
                    const SizedBox(height: 14),
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

  Widget _statCard(String num, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
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
                Icon(CupertinoIcons.circle_fill, size: 8, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _accordionCard({
    required IconData icon,
    required String title,
    required Map<String, int> data,
    required Color color,
    String? suffix,
  }) {
    final maxVal = data.values.fold<int>(1, (p, v) => v > p ? v : p);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Icon(icon, size: 16, color: AppColors.grey500),
            title: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.grey500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${data.length} รายการ',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 14,
                  color: AppColors.grey500,
                ),
              ],
            ),
            children: data.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                e.key,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              suffix != null
                                  ? '${e.value} $suffix'
                                  : '${e.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: suffix != null
                                    ? AppColors.grey900
                                    : color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maxVal > 0 ? e.value / maxVal : 0,
                            backgroundColor: AppColors.grey200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
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
              () => Navigator.pushNamed(context, '/select_station'),
            ),
            _navItem(
              CupertinoIcons.list_bullet,
              'เหตุการณ์',
              false,
              () => Navigator.pushReplacementNamed(context, '/all_incident'),
            ),
            _navItem(CupertinoIcons.location_solid, 'หน่วยเลือกตั้ง', true, () {}),
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
