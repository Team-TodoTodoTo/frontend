import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 데이터 초기화
  runApp(const MyApp());
}
