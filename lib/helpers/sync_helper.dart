import '../models/report.dart';
import 'database_helper.dart';
import 'firestore_helper.dart';

enum SyncStatus { idle, syncing, error, success }

class SyncHelper {
  static final SyncHelper _instance = SyncHelper._internal();
  factory SyncHelper() => _instance;
  SyncHelper._internal();

  final _db = DatabaseHelper();
  final _firestore = FirestoreHelper();

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> syncAll() async {
    if (_status == SyncStatus.syncing) return;

    _status = SyncStatus.syncing;
    _lastError = null;

    try {
      await Future.wait([_syncStations(), _syncViolations(), _syncReports()]);

      _lastSyncTime = DateTime.now();
      _status = SyncStatus.success;
    } catch (e) {
      _lastError = e.toString();
      _status = SyncStatus.error;
      rethrow;
    }
  }

  Future<void> _syncStations() async {
    try {
      final localStations = await _db.getStations();
      final cloudStations = await _firestore.getStations();

      final cloudMap = {for (var s in cloudStations) s.stationId: s};

      for (final local in localStations) {
        final cloud = cloudMap[local.stationId];
        if (cloud == null) {
          await _firestore.stations
              .doc('${local.stationId}')
              .set(local.toMap());
        }
      }
    } catch (e) {
      // Stations sync optional, continue
    }
  }

  Future<void> _syncViolations() async {
    try {
      final localViolations = await _db.getViolations();
      final cloudViolations = await _firestore.getViolations();

      final cloudMap = {for (var v in cloudViolations) v.typeId: v};

      for (final local in localViolations) {
        final cloud = cloudMap[local.typeId];
        if (cloud == null) {
          await _firestore.violations.doc('${local.typeId}').set(local.toMap());
        }
      }
    } catch (e) {
      // Violations sync optional, continue
    }
  }

  Future<void> _syncReports() async {
    try {
      final localReports = await _db.getReports();
      final cloudReports = await _firestore.getReports();

      final localMap = {for (var r in localReports) r.reportId: r};
      final cloudMap = {for (var r in cloudReports) r.reportId: r};

      for (final local in localReports) {
        final cloud = cloudMap[local.reportId];
        if (cloud == null) {
          await _firestore.insertReport(local);
        }
      }

      for (final cloud in cloudReports) {
        final local = localMap[cloud.reportId];
        if (local == null) {
          await _db.insertReport(cloud);
        }
      }
    } catch (e) {
      _lastError = 'Report sync failed: $e';
    }
  }

  Future<void> pushReport(Report report) async {
    try {
      await _firestore.insertReport(report);
    } catch (e) {
      _lastError = 'Push report failed: $e';
    }
  }

  Future<void> deleteReport(int reportId) async {
    try {
      await _firestore.deleteReport(reportId);
      await _db.deleteReport(reportId);
    } catch (e) {
      _lastError = 'Delete report failed: $e';
    }
  }
}
