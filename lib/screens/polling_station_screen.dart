import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';

class PollingStationScreen extends StatefulWidget {
  @override
  _PollingStationScreenState createState() => _PollingStationScreenState();
}

class _PollingStationScreenState extends State<PollingStationScreen> {
  List<Station> stations = [];
  List<Station> filteredStations = [];
  final _searchController = TextEditingController();

  final _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stationsData = await _db.getStations();
    setState(() {
      stations = stationsData;
      filteredStations = stationsData;
    });
  }

  void _filterStations(String query) {
    setState(() {
      filteredStations = query.isEmpty
          ? stations
          : stations
                .where(
                  (s) =>
                      s.stationName.contains(query) ||
                      s.zone.contains(query) ||
                      s.province.contains(query),
                )
                .toList();
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
                    'หน่วยเลือกตั้ง',
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
              onChanged: _filterStations,
              decoration: InputDecoration(
                hintText: 'ค้นหาหน่วยเลือกตั้ง...',
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
                itemCount: filteredStations.length,
                itemBuilder: (ctx, i) => _buildStationCard(filteredStations[i]),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStationCard(Station station) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/polling_station_detail',
        arguments: station,
      ),
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.location_solid,
                color: AppColors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.stationName,
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
                        CupertinoIcons.square_list,
                        size: 11,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        station.zone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        CupertinoIcons.building_2_fill,
                        size: 11,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        station.province,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.grey300,
              size: 16,
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
              () => Navigator.pushNamed(context, '/select_station'),
            ),
            _navItem(
              CupertinoIcons.list_bullet,
              'เหตุการณ์',
              false,
              () => Navigator.pushReplacementNamed(context, '/all_incident'),
            ),
            _navItem(
              CupertinoIcons.location_solid,
              'หน่วยเลือกตั้ง',
              true,
              () {},
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
