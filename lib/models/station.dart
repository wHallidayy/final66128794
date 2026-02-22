// Field Name	Type	Key	Description
// station_id	INTEGER	PK	รหัสหน่วยเลือกตั้ง (ระบุเอง ไม่ใช่ Auto)
// station_name	TEXT		ชื่อสถานที่ (เช่น โรงเรียนวัด..., เต็นท์หน้า...)
// zone	TEXT		เขตเลือกตั้ง (เช่น เขต 1)
// province	TEXT		จังหวัด

class Station {
  int? stationId;
  String stationName;
  String zone;
  String province;

  Station({
    this.stationId,
    required this.stationName,
    required this.zone,
    required this.province,
  });

  Map<String, dynamic> toMap() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'zone': zone,
      'province': province,
    };
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      stationId: map['station_id'],
      stationName: map['station_name'],
      zone: map['zone'],
      province: map['province'],
    );
  }
}

