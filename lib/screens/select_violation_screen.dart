import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/station.dart';
import '../models/violation.dart';
import '../helpers/firestore_helper.dart';


class SelectViolationScreen extends StatefulWidget {
  @override
  _SelectViolationScreenState createState() => _SelectViolationScreenState();
}

class _SelectViolationScreenState extends State<SelectViolationScreen> {
  List<Violation> violations = [];
  Violation? selectedViolation;
  Station? station;
  bool _isInitialized = false;

  final _db = FirestoreHelper();

  @override
  void initState() {
    super.initState();
    _loadViolations();
  }

  Future<void> _loadViolations() async {
    final data = await _db.getViolations();
    setState(() => violations = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      station = ModalRoute.of(context)?.settings.arguments as Station?;
      _isInitialized = true;
    }
  }

  Color _sevColor(String s) =>
      s == 'High' ? AppColors.red : s == 'Medium' ? AppColors.orange : AppColors.green;

  @override
  Widget build(BuildContext context) {
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
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Center(
                        child: Icon(CupertinoIcons.back, color: Colors.white, size: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('เลือกประเภทความผิด',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _buildStepIndicator(2),
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('แตะเพื่อเลือกประเภทที่พบเห็น',
                      style: TextStyle(fontSize: 12, color: AppColors.grey500)),
                  const SizedBox(height: 10),
                  ...violations.map((v) => _violationCard(v)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedViolation != null
                    ? () => Navigator.pushNamed(context, '/report_form',
                        arguments: {'station': station, 'violation': selectedViolation})
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  disabledBackgroundColor: AppColors.grey300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppColors.grey500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: selectedViolation != null ? 8 : 0,
                  shadowColor: AppColors.red.withOpacity(0.35)),
                child: const Text('ถัดไป → กรอกรายละเอียด',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
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

  Widget _violationCard(Violation v) {
    bool sel = selectedViolation?.typeId == v.typeId;
    String sevLabel = v.severity == 'High' ? 'HIGH' : v.severity == 'Medium' ? 'MED' : 'LOW';
    Color sevBg = v.severity == 'High' ? AppColors.redLight
        : v.severity == 'Medium' ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);

    return GestureDetector(
      onTap: () => setState(() => selectedViolation = v),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.red : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
              blurRadius: 12, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.typeName, style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.grey900)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: sevBg, borderRadius: BorderRadius.circular(99)),
              child: Text(sevLabel, style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: _sevColor(v.severity))),
            ),
          ],
        ),
      ),
    );
  }
}
