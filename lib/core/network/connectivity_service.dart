// lib/core/network/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _connectivity = Connectivity();

  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// بث حي لحالة الاتصال — يُستخدم عشان شريط "غير متصل" يختفي فورًا لما
  /// يرجع النت، بدون ما المستخدم يحتاج يسحب لتحديث الشاشة يدويًا.
  static Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}
