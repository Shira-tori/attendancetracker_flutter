import 'dart:async';

import 'package:mysql1/mysql1.dart';

class Database {
  Future<MySqlConnection> getConnection() async {
    try {
      return await MySqlConnection.connect(
        ConnectionSettings(
          host: 'sql6.freemysqlhosting.net',
          port: 3306,
          user: 'sql6588996',
          db: 'sql6588996',
          password: 'S9DPyTQx87',
        ),
      );
    } catch (e) {
      print('Error connecting to MySQL server: $e');
      return Future.error(e);
    }
  }
}
