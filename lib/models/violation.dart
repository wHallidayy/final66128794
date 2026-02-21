// Field Name	Type	Key	Description
// type_id	INTEGER	PK	รหัสประเภทความผิด
// type_name	TEXT		ชื่อประเภทความผิด (เช่น ซื้อเสียง, ทำลายป้าย)
// severity	TEXT		ระดับความรุนแรง (High, Medium, Low)

class Violation {
  int? typeId;
  String typeName;
  String severity; // 'High', 'Medium', 'Low'

  Violation({
    this.typeId,
    required this.typeName,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'type_id': typeId,
      'type_name': typeName,
      'severity': severity,
    };
  }

  factory Violation.fromMap(Map<String, dynamic> map) {
    return Violation(
      typeId: map['type_id'],
      typeName: map['type_name'],
      severity: map['severity'],
    );
  }
}
