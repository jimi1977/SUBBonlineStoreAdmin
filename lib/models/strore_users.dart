

import 'package:subbonline_storeadmin/utility/utility_functions.dart';

class StoreUsers {

  final String uid;
  final String userId;
  final String password;
  final String name;
  final String storeId;
  final String branchId;
  final int    roleCode;
  final String status;
  final DateTime dateCreated;
  final DateTime dateInactivated;

  StoreUsers({this.uid, this.userId, this.password, this.name, this.storeId, this.branchId, this.roleCode, this.status, this.dateCreated,
      this.dateInactivated});

  factory StoreUsers.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return null;
    return new StoreUsers(
      uid:  map['uid'] as String,
      userId: map['userId'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      storeId: map['storeId'] as String,
      branchId: map['branchId'] as String,
      roleCode: map['roleCode'] as int,
      status: map['status'] as String,
      dateCreated: convertTimeStampToDatetime(map['dateCreated']),
      dateInactivated: convertTimeStampToDatetimeWithNull(map['dateInactivated']),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'userId': this.userId,
      'password': this.password,
      'name': this.name,
      'storeId': this.storeId,
      'branchId': this.branchId,
      'roleCode': this.roleCode,
      'status': this.status,
      'dateCreated': this.dateCreated,
      'dateInactivated': this.dateInactivated,
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreUsers &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          userId == other.userId &&
          password == other.password &&
          name == other.name &&
          storeId == other.storeId &&
          branchId == other.branchId &&
          roleCode == other.roleCode &&
          status == other.status &&
          dateCreated == other.dateCreated &&
          dateInactivated == other.dateInactivated;

  @override
  int get hashCode =>
      uid.hashCode ^
      userId.hashCode ^
      password.hashCode ^
      name.hashCode ^
      storeId.hashCode ^
      branchId.hashCode ^
      roleCode.hashCode ^
      status.hashCode ^
      dateCreated.hashCode ^
      dateInactivated.hashCode;
}