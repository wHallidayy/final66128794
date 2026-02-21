import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/station.dart';
import '../models/violation.dart';
import '../models/report.dart';
import '../helpers/firestore_helper.dart';


class ReportFormScreen extends StatefulWidget {
  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  Station? station;
  Violation? violation;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      station = args?['station'] as Station?;
      violation = args?['violation'] as Violation?;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
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
                const Text('รายละเอียดเหตุการณ์',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _buildStepIndicator(3),
          Expanded(
            child: Container(
              color: AppColors.grey100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (station != null)
                        _infoChip(CupertinoIcons.location_solid,
                            '${station!.stationName} · ${station!.zone}', AppColors.redDark),
                      if (violation != null) ...[
                        const SizedBox(height: 8),
                        _violationChip(),
                      ],
                      const SizedBox(height: 14),
                      _label('ชื่อผู้แจ้ง (ไม่บังคับ)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDeco('ระบุชื่อ หรือปล่อยว่างไว้ (Anonymous)'),
                      ),
                      const SizedBox(height: 14),
                      _label('รายละเอียดเหตุการณ์ *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController, maxLines: 4,
                        validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
                        decoration: _inputDeco('อธิบายสิ่งที่พบเห็น เช่น เวลา ลักษณะ ผู้เกี่ยวข้อง...'),
                      ),
                      const SizedBox(height: 14),
                      _label('ภาพหลักฐาน'),
                      const SizedBox(height: 6),
                      _buildPhotoSection(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final name = _nameController.text.isEmpty
                                  ? 'Anonymous' : _nameController.text;
                              final report = Report(
                                stationId: station!.stationId!,
                                typeId: violation!.typeId!,
                                reporterName: name,
                                description: _descController.text,
                                evidencePhoto: null,
                                timestamp: DateTime.now()
                                    .toIso8601String()
                                    .replaceFirst('T', ' ')
                                    .substring(0, 19),
                                aiResult: null,
                                aiConfidence: 0.0,
                              );
                              await FirestoreHelper().insertReport(report);
                              if (!mounted) return;
                              Navigator.pushNamed(context, '/report_success',
                                  arguments: {
                                    'station': station, 'violation': violation,
                                    'name': name,
                                  });
                            }
                          },
                          icon: const Icon(CupertinoIcons.checkmark_alt, size: 18),
                          label: const Text('ส่งรายงาน',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8, shadowColor: AppColors.red.withOpacity(0.35)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
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

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.redLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: color))),
        ],
      ),
    );
  }

  Widget _violationChip() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.redLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text(violation!.typeName,
              style: const TextStyle(fontSize: 13, color: AppColors.redDark)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.redLight, borderRadius: BorderRadius.circular(99)),
            child: Text(
              violation!.severity == 'High' ? 'HIGH' : violation!.severity == 'Medium' ? 'MED' : 'LOW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: _sevColor(violation!.severity))),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: AppColors.grey700));
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey500),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey300, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Container(
          width: double.infinity, height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
                colors: [Color(0xFF2D2D2D), Color(0xFF555555)])),
          child: Stack(
            children: [
              const Center(
                child: Icon(CupertinoIcons.photo, size: 64, color: Colors.white54)),
              Positioned(
                bottom: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(99)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.circle_fill, size: 6, color: Color(0xFF4CAF50)),
                      SizedBox(width: 6),
                      Icon(CupertinoIcons.bolt_fill, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('AI ตรวจพบ: ',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      Text('Money',
                          style: TextStyle(color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('95%',
                          style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _photoBtn(CupertinoIcons.camera_fill, 'ถ่ายรูป')),
            const SizedBox(width: 8),
            Expanded(child: _photoBtn(CupertinoIcons.photo_on_rectangle, 'เลือกจากอัลบั้ม')),
          ],
        ),
      ],
    );
  }

  Widget _photoBtn(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300, width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.grey700),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
