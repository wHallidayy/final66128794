import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station.dart';
import '../models/violation.dart';
import '../models/report.dart';
import 'mock_data.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;
  FirestoreHelper._internal();

  final _db = FirebaseFirestore.instance;

  CollectionReference get _stations => _db.collection('polling_station');
  CollectionReference get _violations => _db.collection('violation_type');
  CollectionReference get _reports => _db.collection('incident_report');

  // ──────────────── Seed (ครั้งแรก) ────────────────

  /// Seed ข้อมูลเริ่มต้นถ้า Firestore ยังว่าง
  Future<void> seedIfEmpty() async {
    final snap = await _stations.limit(1).get();
    if (snap.docs.isNotEmpty) return; // มีข้อมูลแล้ว ไม่ต้อง seed

    final batch = _db.batch();

    // Seed stations
    for (final s in MockData.getStations()) {
      batch.set(_stations.doc('${s.stationId}'), s.toMap());
    }
    // Seed violations
    for (final v in MockData.getViolations()) {
      batch.set(_violations.doc('${v.typeId}'), v.toMap());
    }
    // Seed reports
    for (final r in MockData.getReports()) {
      batch.set(_reports.doc('${r.reportId}'), r.toMap());
    }

    await batch.commit();
  }

  // ──────────────── Station ────────────────

  Future<List<Station>> getStations() async {
    final snap = await _stations.orderBy('station_id').get();
    return snap.docs.map((d) =>
        Station.fromMap(d.data() as Map<String, dynamic>)).toList();
  }

  Future<Station?> getStationById(int stationId) async {
    final doc = await _stations.doc('$stationId').get();
    if (!doc.exists) return null;
    return Station.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ──────────────── Violation ────────────────

  Future<List<Violation>> getViolations() async {
    final snap = await _violations.orderBy('type_id').get();
    return snap.docs.map((d) =>
        Violation.fromMap(d.data() as Map<String, dynamic>)).toList();
  }

  Future<Violation?> getViolationById(int typeId) async {
    final doc = await _violations.doc('$typeId').get();
    if (!doc.exists) return null;
    return Violation.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ──────────────── Report ────────────────

  Future<List<Report>> getReports() async {
    final snap = await _reports.orderBy('report_id', descending: true).get();
    return snap.docs.map((d) =>
        Report.fromMap(d.data() as Map<String, dynamic>)).toList();
  }

  Future<String> insertReport(Report report) async {
    // Auto-generate report_id
    final snap = await _reports.orderBy('report_id', descending: true).limit(1).get();
    final nextId = snap.docs.isEmpty ? 1
        : ((snap.docs.first.data() as Map<String, dynamic>)['report_id'] as int) + 1;

    final map = report.toMap();
    map['report_id'] = nextId;

    final docRef = _reports.doc('$nextId');
    await docRef.set(map);
    return docRef.id;
  }

  Future<void> deleteReport(int reportId) async {
    await _reports.doc('$reportId').delete();
  }
}
