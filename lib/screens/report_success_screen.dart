import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/station.dart';
import '../models/violation.dart';

class ReportSuccessScreen extends StatefulWidget {
  @override
  _ReportSuccessScreenState createState() => _ReportSuccessScreenState();
}

class _ReportSuccessScreenState extends State<ReportSuccessScreen> {
  Station? station;
  Violation? violation;
  String reporterName = 'Anonymous';
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      station = args?['station'] as Station?;
      violation = args?['violation'] as Violation?;
      reporterName = args?['name'] as String? ?? 'Anonymous';
      _isInitialized = true;
    }
  }

  String get _sevLabel =>
      violation?.severity == 'High' ? 'HIGH'
          : violation?.severity == 'Medium' ? 'MED' : 'LOW';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top accent line
                    Container(
                      width: double.infinity, height: 4,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 48),

                    // Checkmark + Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(CupertinoIcons.checkmark,
                                  size: 24, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('แจ้งเหตุสำเร็จ',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                                  color: AppColors.grey900, letterSpacing: -0.5, height: 1.2)),
                          const SizedBox(height: 8),
                          Text('รหัส #0004 — ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year + 543}',
                              style: const TextStyle(fontSize: 13,
                                  color: AppColors.grey500, letterSpacing: 0.2)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      height: 1, color: AppColors.grey200,
                    ),

                    const SizedBox(height: 24),

                    // Data rows — label/value grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          _row('หน่วย', station?.stationName ?? '—'),
                          _row('เขต', station?.zone ?? '—'),
                          _row('จังหวัด', station?.province ?? '—'),
                          _rowWidget('ประเภท', Row(
                            children: [
                              Expanded(
                                child: Text(violation?.typeName ?? '—',
                                    style: const TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey900)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.grey300, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_sevLabel,
                                    style: const TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.grey700,
                                        letterSpacing: 1)),
                              ),
                            ],
                          )),
                          _row('ผู้แจ้ง', reporterName),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      height: 1, color: AppColors.grey200,
                    ),

                    const SizedBox(height: 24),

                    // Note
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'ข้อมูลของท่านถูกบันทึกเรียบร้อยแล้ว\nเจ้าหน้าที่จะดำเนินการตรวจสอบโดยเร็ว',
                        style: TextStyle(fontSize: 13, color: AppColors.grey500,
                            height: 1.6, letterSpacing: 0.1),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.grey200, width: 1)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (r) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey900,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('กลับหน้าหลัก',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/select_station'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.grey300, width: 1.5),
                        foregroundColor: AppColors.grey700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('แจ้งเหตุอีกครั้ง',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.grey500,
                    letterSpacing: 0.2))),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.grey900)),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.grey500,
                    letterSpacing: 0.2))),
          Expanded(child: child),
        ],
      ),
    );
  }
}
