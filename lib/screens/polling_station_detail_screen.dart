import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../models/violation.dart';
import '../models/station.dart';
import '../helpers/database_helper.dart';
import '../helpers/firestore_helper.dart';

class PollingStationDetailScreen extends StatefulWidget {
  @override
  _PollingStationDetailScreenState createState() =>
      _PollingStationDetailScreenState();
}

class _PollingStationDetailScreenState
    extends State<PollingStationDetailScreen> {
  Report? report;
  bool _isInitialized = false;
  Violation? violation;
  Station? station;

  final _db = DatabaseHelper();
  final _firestore = FirestoreHelper();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      report = ModalRoute.of(context)?.settings.arguments as Report?;
      _loadRelatedData();
      _isInitialized = true;
    }
  }

  Future<void> _loadRelatedData() async {
    if (report == null) return;
    final v = await _db.getViolationById(report!.typeId);
    final s = await _db.getStationById(report!.stationId);
    setState(() {
      violation = v;
      station = s;
    });
  }

  String _getViolationName(int typeId) => violation?.typeName ?? '-';
  String _getStationName(int stationId) => station?.stationName ?? '-';
  String _getZone(int stationId) => station?.zone ?? '-';
  String _getProvince(int stationId) => station?.province ?? '-';

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียด')),
        body: const Center(child: CupertinoActivityIndicator()),
      );
    }
    final r = report!;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 14),
            color: AppColors.red,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'รายงาน #${r.reportId.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptionsDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      CupertinoIcons.delete_solid,
                      color: Colors.white,
                      size: 20,
                    ),
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
                  children: [
                    _buildHero(r),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _violationCard(r),
                          const SizedBox(height: 14),
                          _locationCard(r),
                          const SizedBox(height: 14),
                          _reportCard(r),
                          const SizedBox(height: 14),
                          if (r.aiResult != null) _aiCard(r),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Report r) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF333333)],
            ),
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 96,
              color: Colors.white24,
            ),
          ),
        ),
        if (r.aiResult != null)
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),
                  const Text(
                    'ผลลัพธ์จาก AI: ',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    r.aiResult!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(r.aiConfidence! * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _violationCard(Report r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: AppColors.red, width: 4)),
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
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            size: 40,
            color: AppColors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ประเภทความผิด',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                Text(
                  _getViolationName(r.typeId),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard(Report r) {
    return _card(CupertinoIcons.location_solid, 'ข้อมูลสถานที่', [
      _detailRow('หน่วย', _getStationName(r.stationId)),
      _detailRow('เขต', _getZone(r.stationId)),
      _detailRow('จังหวัด', _getProvince(r.stationId)),
    ]);
  }

  Widget _reportCard(Report r) {
    return _card(CupertinoIcons.doc_text_fill, 'ข้อมูลการแจ้ง', [
      _detailRow('เวลา', r.timestamp),
      _detailRow('ผู้แจ้ง', r.reporterName),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รายละเอียด',
            style: TextStyle(fontSize: 13, color: AppColors.grey500),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.description,
              style: const TextStyle(fontSize: 13, color: AppColors.grey700),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _aiCard(Report r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF4CAF50), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(width: 6),
              Text(
                'ผลลัพธ์จาก AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('ผลลัพธ์', '${r.aiResult}', valColor: AppColors.green),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  'ความมั่นใจ',
                  style: TextStyle(fontSize: 13, color: AppColors.grey500),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: r.aiConfidence ?? 0,
                          backgroundColor: AppColors.grey200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${((r.aiConfidence ?? 0) * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF388E3C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.grey500),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.expand((w) => [w, const SizedBox(height: 10)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.grey500),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valColor ?? AppColors.grey900,
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายงาน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('คุณต้องการลบรายงานนี้หรือไม่?'),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              if (report != null && report!.reportId != null) {
                await _db.deleteReport(report!.reportId!);
                await _firestore.deleteReport(report!.reportId!);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
