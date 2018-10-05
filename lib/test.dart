import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sqljocky5/connection/connection.dart';

class Test {
  aa() async {
    var s = ConnectionSettings(
      user: "root",
      password: "Da123!@#",
      host: "192.168.100.235",
      port: 3306,
      db: "test",
    );
    var conn = await MySqlConnection.connect(s);
    print("dddd");
  }
}
