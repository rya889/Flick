import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// RevenueCat + demo Plus entitlement.
///
/// Configure at build time:
/// `--dart-define=REVENUECAT_API_KEY=appl_…` (or goog_…)
/// Product ids default to Flick Plus catalog names from the backend spec.
class PlusService {
  static const entitlementId = 'flick_plus';
  static const monthlyProductId = 'flick_plus_monthly';
  static const yearlyProductId = 'flick_plus_yearly';

  static const _rcKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const _forceDemo = bool.fromEnvironment('FLICK_PLUS_DEMO', defaultValue: false);

  bool _configured = false;
  bool _demoActive = false;
  bool _entitled = false;
  String? _appUserId;
  Offerings? offerings;
  String? lastError;

  bool get isConfigured => _configured;
  bool get usesDemo => !_configured || _forceDemo || kIsWeb;
  bool get plusActive => _entitled || _demoActive;
  bool get demoActive => _demoActive;
  String? get appUserId => _appUserId;

  /// Header value for `/v1/tldr` Plus gate.
  String get entitlementHeader {
    if (_demoActive || usesDemo) {
      return plusActive ? 'demo' : '';
    }
    return plusActive ? 'revenuecat' : '';
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _demoActive = prefs.getBool('flick.plusDemo.v1') == true;

    var userId = prefs.getString('flick.appUserId.v1');
    if (userId == null || userId.isEmpty) {
      userId = const Uuid().v4();
      await prefs.setString('flick.appUserId.v1', userId);
    }
    _appUserId = userId;

    if (kIsWeb || _rcKey.isEmpty || _forceDemo) {
      _configured = false;
      _entitled = _demoActive;
      return;
    }

    try {
      final config = PurchasesConfiguration(_rcKey)..appUserID = userId;
      await Purchases.configure(config);
      _configured = true;
      await refresh();
      await loadOfferings();
    } catch (e) {
      lastError = e.toString();
      _configured = false;
      _entitled = _demoActive;
    }
  }

  Future<void> refresh() async {
    if (!_configured) {
      _entitled = _demoActive;
      return;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      _entitled = info.entitlements.active.containsKey(entitlementId);
      if (_entitled) {
        _demoActive = false;
      }
    } catch (e) {
      lastError = e.toString();
    }
  }

  Future<void> loadOfferings() async {
    if (!_configured) return;
    try {
      offerings = await Purchases.getOfferings();
    } catch (e) {
      lastError = e.toString();
    }
  }

  Package? get monthlyPackage {
    final current = offerings?.current;
    if (current == null) return null;
    return current.monthly ??
        current.getPackage(monthlyProductId) ??
        _findPackage(monthlyProductId);
  }

  Package? get yearlyPackage {
    final current = offerings?.current;
    if (current == null) return null;
    return current.annual ??
        current.getPackage(yearlyProductId) ??
        _findPackage(yearlyProductId);
  }

  Package? _findPackage(String id) {
    for (final o in offerings?.all.values ?? <Offering>[]) {
      for (final p in o.availablePackages) {
        if (p.storeProduct.identifier == id || p.identifier == id) return p;
      }
    }
    return null;
  }

  Future<bool> purchase(Package package) async {
    if (!_configured) {
      return setDemo(true);
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _entitled =
          result.customerInfo.entitlements.active.containsKey(entitlementId);
      _demoActive = false;
      lastError = null;
      return _entitled;
    } on PlatformException catch (e) {
      lastError = PurchasesErrorHelper.getErrorCode(e).name;
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> purchaseMonthly() async {
    final pkg = monthlyPackage;
    if (pkg != null) return purchase(pkg);
    if (usesDemo) return setDemo(true);
    lastError = 'Monthly package unavailable — check RevenueCat offerings';
    return false;
  }

  Future<bool> purchaseYearly() async {
    final pkg = yearlyPackage;
    if (pkg != null) return purchase(pkg);
    if (usesDemo) return setDemo(true);
    lastError = 'Yearly package unavailable — check RevenueCat offerings';
    return false;
  }

  Future<bool> restore() async {
    if (!_configured) return plusActive;
    try {
      final info = await Purchases.restorePurchases();
      _entitled = info.entitlements.active.containsKey(entitlementId);
      lastError = null;
      return _entitled;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> setDemo(bool value) async {
    _demoActive = value;
    if (value) {
      _entitled = true;
    } else if (!_configured) {
      _entitled = false;
    } else {
      await refresh();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flick.plusDemo.v1', value);
    return plusActive;
  }
}
