import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/station.dart';
import '../models/violation.dart';
import '../models/report.dart';
import 'SeedData.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static void initFfi() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  //มีคำสั่งตรวจสอบว่าเครื่องมีไฟล์ฐานข้อมูล SQLite แล้วหรือไม่ ตอนเข้าแอปครั้งแรก
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'election_fraud.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create polling_station table
    await db.execute('''
      CREATE TABLE polling_station (
        station_id INTEGER PRIMARY KEY,
        station_name TEXT NOT NULL,
        zone TEXT NOT NULL,
        province TEXT NOT NULL
      )
    ''');

    // Create violation_type table
    await db.execute('''
      CREATE TABLE violation_type (
        type_id INTEGER PRIMARY KEY,
        type_name TEXT NOT NULL,
        severity TEXT NOT NULL
      )
    ''');

    // Create incident_report table
    await db.execute('''
      CREATE TABLE incident_report (
        report_id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_id INTEGER NOT NULL,
        type_id INTEGER NOT NULL,
        reporter_name TEXT NOT NULL,
        description TEXT NOT NULL,
        evidence_photo TEXT,
        timestamp TEXT NOT NULL,
        ai_result TEXT,
        ai_confidence REAL,
        FOREIGN KEY (station_id) REFERENCES polling_station(station_id),
        FOREIGN KEY (type_id) REFERENCES violation_type(type_id)
      )
    ''');

    // Seed initial data
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed stations
    for (final s in SeedData.getStations()) {
      await db.insert('polling_station', s.toMap());
    }
    // Seed violations
    for (final v in SeedData.getViolations()) {
      await db.insert('violation_type', v.toMap());
    }
    // Seed reports
    for (final r in SeedData.getReports()) {
      final map = r.toMap();
      map.remove('report_id'); // Let autoincrement handle it
      await db.insert('incident_report', map);
    }
  }

  Future<List<Station>> getStations() async {
    final db = await database;
    final maps = await db.query('polling_station');
    return maps.map((m) => Station.fromMap(m)).toList();
  }

  Future<Station?> getStationById(int stationId) async {
    final db = await database;
    final maps = await db.query(
      'polling_station',
      where: 'station_id = ?',
      whereArgs: [stationId],
    );
    if (maps.isEmpty) return null;
    return Station.fromMap(maps.first);
  }

  Future<List<Violation>> getViolations() async {
    final db = await database;
    final maps = await db.query('violation_type');
    return maps.map((m) => Violation.fromMap(m)).toList();
  }

  Future<Violation?> getViolationById(int typeId) async {
    final db = await database;
    final maps = await db.query(
      'violation_type',
      where: 'type_id = ?',
      whereArgs: [typeId],
    );
    if (maps.isEmpty) return null;
    return Violation.fromMap(maps.first);
  }

  Future<List<Report>> getReports() async {
    final db = await database;
    final maps = await db.query('incident_report', orderBy: 'report_id DESC');
    return maps.map((m) => Report.fromMap(m)).toList();
  }

  Future<int> insertReport(Report report) async {
    final db = await database;
    final map = report.toMap();
    map.remove('report_id'); // autoincrement
    return await db.insert('incident_report', map);
  }

  Future<Report?> getReportById(int reportId) async {
    final db = await database;
    final maps = await db.query(
      'incident_report',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
    if (maps.isEmpty) return null;
    return Report.fromMap(maps.first);
  }

  Future<int> deleteReport(int reportId) async {
    final db = await database;
    return await db.delete(
      'incident_report',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  Future<List<Map<String, dynamic>>> getTopComplaintedStations({
    int limit = 3,
  }) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        ps.station_id,
        ps.station_name,
        ps.zone,
        ps.province,
        COUNT(ir.report_id) as complaint_count
      FROM polling_station ps
      INNER JOIN incident_report ir ON ps.station_id = ir.station_id
      GROUP BY ps.station_id
      ORDER BY complaint_count DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  Future<int> getOfflineReportsCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM incident_report
    ''');
    return result.first['count'] as int;
  }
}
