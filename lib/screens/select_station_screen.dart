import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/station.dart';
import '../helpers/firestore_helper.dart';

class SelectStationScreen extends StatefulWidget {
  @override
  _SelectStationScreenState createState() => _SelectStationScreenState();
}

class _SelectStationScreenState extends State<SelectStationScreen> {
  List<Station> stations = [];
  Station? selectedStation;
  final _searchController = TextEditingController();
  String _query = '';

  final _db = FirestoreHelper();

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final data = await _db.getStations();
    setState(() => stations = data);
  }

  /// Group filtered stations by province
  Map<String, List<Station>> get _groupedStations {
    final filtered = _query.isEmpty
        ? stations
        : stations.where((s) =>
            s.stationName.contains(_query) ||
            s.zone.contains(_query) ||
            s.province.contains(_query)).toList();

    final map = <String, List<Station>>{};
    for (final s in filtered) {
      map.putIfAbsent(s.province, () => []).add(s);
    }
    return map;
  }

  int get _filteredCount =>
      _groupedStations.values.fold<int>(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedStations;
    final provinces = grouped.keys.toList();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 14),
            color: AppColors.red,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Center(
                        child: Icon(CupertinoIcons.back, color: Colors.white, size: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('เลือกหน่วยเลือกตั้ง',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _buildStepIndicator(1),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => setState(() => _query = q),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อหน่วย, จังหวัด หรือเขต...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                filled: true, fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(99),
                    borderSide: const BorderSide(color: AppColors.grey300, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(99),
                    borderSide: const BorderSide(color: AppColors.grey300, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(99),
                    borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          // Station count
          Container(
            width: double.infinity, color: AppColors.grey100,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text('${provinces.length} จังหวัด · $_filteredCount หน่วย',
                style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
          ),
          // Accordion list
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: provinces.length,
                itemBuilder: (ctx, i) {
                  final province = provinces[i];
                  final stationsInProvince = grouped[province]!;
                  return _provinceAccordion(province, stationsInProvince);
                },
              ),
            ),
          ),
          // Bottom button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Column(
              children: [
                if (selectedStation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.checkmark_circle_fill,
                            size: 14, color: AppColors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${selectedStation!.stationName} · ${selectedStation!.zone}',
                            style: const TextStyle(fontSize: 12, color: AppColors.red,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedStation != null
                        ? () => Navigator.pushNamed(context, '/select_violation',
                            arguments: selectedStation)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      disabledBackgroundColor: AppColors.grey300,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.grey500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: selectedStation != null ? 8 : 0,
                      shadowColor: AppColors.red.withOpacity(0.35)),
                    child: const Text('ถัดไป → เลือกประเภทความผิด',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(7, (i) {
          if (i.isEven) {
            int step = (i ~/ 2) + 1;
            bool isDone = step < currentStep;
            bool isCurrent = step == currentStep;
            return Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone || isCurrent ? AppColors.red : AppColors.grey200,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [BoxShadow(color: AppColors.red.withOpacity(0.2), spreadRadius: 4)]
                    : null),
              child: Center(
                child: isDone
                    ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 14)
                    : Text('$step', style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? Colors.white : AppColors.grey500)),
              ),
            );
          } else {
            return Expanded(
              child: Container(height: 2,
                  color: (i ~/ 2) < currentStep - 1 ? AppColors.red : AppColors.grey200),
            );
          }
        }),
      ),
    );
  }

  Widget _provinceAccordion(String province, List<Station> stationsInProvince) {
    // Auto-expand when searching or only 1 province
    final shouldAutoExpand = _query.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey<String>(province),
            initiallyExpanded: shouldAutoExpand,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.redLight, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Icon(CupertinoIcons.map_fill, size: 18, color: AppColors.red),
              ),
            ),
            title: Text(province,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.grey900)),
            subtitle: Text('${stationsInProvince.length} หน่วย',
                style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.grey100, borderRadius: BorderRadius.circular(99)),
                  child: Text('${stationsInProvince.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.grey500)),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.chevron_down, size: 14, color: AppColors.grey500),
              ],
            ),
            children: stationsInProvince.map((s) => _stationTile(s)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _stationTile(Station station) {
    final sel = selectedStation?.stationId == station.stationId &&
        selectedStation?.zone == station.zone;

    return GestureDetector(
      onTap: () => setState(() => selectedStation = station),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? AppColors.redLight : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? AppColors.red : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.location_solid,
                size: 14, color: sel ? AppColors.red : AppColors.grey500),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.stationName,
                      style: TextStyle(fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.red : AppColors.grey900)),
                  const SizedBox(height: 2),
                  Text(station.zone,
                      style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                ],
              ),
            ),
            if (sel)
              const Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}
