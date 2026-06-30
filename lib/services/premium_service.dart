import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumService {
  static const String boxName = 'premiumBox';
  static const String entitlement = 'Bubble Grammar Pro';

  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(
      Platform.isIOS
          ? 'appl_dXDIEgPZgFiVhhzuWGIebRiXOEV'
          : 'goog_StgqJBGZrVRByrqnmvZraizrkLL',
    );

    await Purchases.configure(configuration);
  }

  static Future<bool> purchasePremium() async {
    try {
      final offerings = await Purchases.getOfferings();

      final offering = offerings.current;

      if (offering == null) {
        throw Exception('No current offering found.');
      }

      final package = offering.sixMonth;

      if (package == null) {
        throw Exception('6 month package not found.');
      }

      final customerInfo = await Purchases.purchasePackage(package);

      return customerInfo.entitlements.active.containsKey(entitlement);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> activateCodePremium() async {
    final box = Hive.box(boxName);

    await box.put(
      'codePremium',
      true,
    );
  }

  static Future<bool> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();

    return customerInfo.entitlements.active.containsKey(entitlement);
  }

  static Future<bool> isPremium() async {
    final box = Hive.box(boxName);

    if (box.get('codePremium') == true) {
      return true;
    }

    final customerInfo = await Purchases.getCustomerInfo();

    return customerInfo.entitlements.active.containsKey(entitlement);
  }

  static Future<DateTime?> getExpiryDate() async {
    final customerInfo = await Purchases.getCustomerInfo();

    final entitlementInfo = customerInfo.entitlements.active[entitlement];

    if (entitlementInfo?.expirationDate == null) {
      return null;
    }

    return DateTime.parse(entitlementInfo!.expirationDate!);
  }
}
