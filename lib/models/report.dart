// Field Name	Type	Key	Description
// report_id	INTEGER	PK	รหัสการแจ้งเหตุ (Auto Increment)
// station_id	INTEGER	FK	อ้างอิงจากตาราง polling_station
// type_id	INTEGER	FK	อ้างอิงจากตาราง violation_type
// reporter_name	TEXT		ชื่อผู้แจ้งเหตุ
// description	TEXT		รายละเอียดเพิ่มเติม
// evidence_photo	TEXT		Path ของรูปภาพหลักฐาน
// timestamp	TEXT		วันเวลาที่แจ้ง (Format: YYYY-MM-DD HH:MM:SS)
// ai_result	TEXT		(สำหรับ AI) ผลการทำนายจากรูปภาพ (เช่น Money, Crowd, Poster)
// ai_confidence	REAL		(สำหรับ AI) ค่าความมั่นใจเป็นทศนิยม (เช่น 0.95)


class Report {
  int? reportId;
  int stationId;
  int typeId;
  String reporterName;
  String description;
  String? evidencePhoto;
  String timestamp; // Format: YYYY-MM-DD HH:MM:SS
  String? aiResult;
  double? aiConfidence;

  Report({
    this.reportId,
    required this.stationId,
    required this.typeId,
    required this.reporterName,
    required this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    this.aiConfidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'station_id': stationId,
      'type_id': typeId,
      'reporter_name': reporterName,
      'description': description,
      'evidence_photo': evidencePhoto,
      'timestamp': timestamp,
      'ai_result': aiResult,
      'ai_confidence': aiConfidence,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['report_id'],
      stationId: map['station_id'],
      typeId: map['type_id'],
      reporterName: map['reporter_name'],
      description: map['description'],
      evidencePhoto: map['evidence_photo'],
      timestamp: map['timestamp'],
      aiResult: map['ai_result'],
      aiConfidence: map['ai_confidence'],
    );
  }
}
