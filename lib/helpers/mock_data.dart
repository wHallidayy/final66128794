import '../models/report.dart';
import '../models/station.dart';
import '../models/violation.dart';

class MockData {
  static List<Station> getStations() {
    return [
      Station(stationId: 101, stationName: 'โรงเรียนวัดพระมหาธาตุ',
          zone: 'เขต 1', province: 'นครศรีธรรมราช'),
      Station(stationId: 102, stationName: 'เต็นท์หน้าตลาดท่าวัง',
          zone: 'เขต 1', province: 'นครศรีธรรมราช'),
      Station(stationId: 103, stationName: 'ศาลากลางหมู่บ้านคีรีวง',
          zone: 'เขต 2', province: 'นครศรีธรรมราช'),
      Station(stationId: 104, stationName: 'หอประชุมอำเภอทุ่งสง',
          zone: 'เขต 3', province: 'นครศรีธรรมราช'),
    ];
  }

  static List<Violation> getViolations() {
    return [
      Violation(typeId: 1, typeName: 'ซื้อสิทธิ์ขายเสียง',
          severity: 'High'),
      Violation(typeId: 2, typeName: 'ขนคนไปลงคะแนน',
          severity: 'High'),
      Violation(typeId: 3, typeName: 'หาเสียงเกินเวลา',
          severity: 'Medium'),
      Violation(typeId: 4, typeName: 'ทำลายป้ายหาเสียง',
          severity: 'Low'),
      Violation(typeId: 5, typeName: 'เจ้าหน้าที่วางตัวไม่เป็นกลาง',
          severity: 'High'),
    ];
  }

  static List<Report> getReports() {
    return [
      Report(
        reportId: 1, stationId: 101, typeId: 1,
        reporterName: 'พลเมืองดี 01',
        description: 'พบเห็นการแจกเงินบริเวณหน้าหน่วย',
        evidencePhoto: null,
        timestamp: '2026-02-08 09:30:00',
        aiResult: 'Money', aiConfidence: 0.95,
      ),
      Report(
        reportId: 2, stationId: 102, typeId: 3,
        reporterName: 'สมชาย ใจกล้า',
        description: 'มีการเปิดรถแห่เสียงดังรบกวน',
        evidencePhoto: null,
        timestamp: '2026-02-08 10:15:00',
        aiResult: 'Crowd', aiConfidence: 0.75,
      ),
      Report(
        reportId: 3, stationId: 103, typeId: 5,
        reporterName: 'Anonymous',
        description: 'เจ้าหน้าที่พูดจาชี้นำผู้ลงคะแนน',
        evidencePhoto: null,
        timestamp: '2026-02-08 11:00:00',
        aiResult: null, aiConfidence: 0.0,
      ),
    ];
  }

  static Station? getStationById(int stationId) {
    try {
      return getStations().firstWhere((s) => s.stationId == stationId);
    } catch (_) {
      return null;
    }
  }
  
  static Violation? getViolationById(int typeId) {
    try {
      return getViolations().firstWhere((v) => v.typeId == typeId);
    } catch (_) {
      return null;
    }
  }
}
