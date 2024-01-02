import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:workmanager/workmanager.dart';
import 'Views/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:order_booking_shop/Databases/DBHelper.dart';
import 'package:order_booking_shop/Databases/DBHelperRecoveryForm.dart';
import 'package:order_booking_shop/Databases/DBHelperReturnForm.dart';
import 'package:order_booking_shop/Databases/OrderDatabase/DBHelperOrderMaster.dart';
import 'Databases/OrderDatabase/DBProductCategory.dart';
import 'Views/splash_screen.dart';
import '../Databases/DBHelperShopVisit.dart';

//Flutter Background

final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "Background Tracking",
  notificationText: "Background Notification",
  notificationImportance: AndroidNotificationImportance.Default,
  notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable'), // Default is ic_launcher from folder mipmap
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize FlutterBackground plugin
  await FlutterBackground.initialize(androidConfig: androidConfig);

  // Enable background execution
  await FlutterBackground.enableBackgroundExecution();

  // Initialize Workmanager
  try {
    await Workmanager().initialize(callbackDispatcher);
    print('Workmanager initialized successfully.');
  } catch (e) {
    print('Workmanager initialization failed: $e');
  }

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    ),
  );
}
//
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      bool isConnected = await isInternetConnected();

      if (isConnected) {
        print('Internet connection is available. Initiating background data synchronization.');
        await synchronizeData();

        // Register one-off task with constraints
        await Workmanager().registerOneOffTask(
          "myTask",
          "simpleTask",
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
        );

        print('Background data synchronization completed.');
      } else {
        print('No internet connection available. Skipping background data synchronization.');
      }
    } catch (e) {
      print('Error in backgroundTask: $e');
    }

    return Future.value(true);
  });
}


Future<bool> isInternetConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isConnected = connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;

  print('Internet Connected: $isConnected');

  return isConnected;
}

Future<void> backgroundTask() async {
  try {
    bool isConnected = await isInternetConnected();

    if (isConnected) {
      print('Internet connection is available. Initiating background data synchronization.');
      await synchronizeData();
      print('Background data synchronization completed.');
    } else {
      print('No internet connection available. Skipping background data synchronization.');
    }
  } catch (e) {
    print('Error in backgroundTask: $e');
  }
}

Future<void> synchronizeData() async {
  print('Synchronizing data in the background.');

  await postAttendanceTable();
  await postAttendanceOutTable();
  await postShopTable();
  await postShopVisitData();
  await postStockCheckItems();
  await postMasterTable();
  await postOrderDetails();
  await postReturnFormTable();
  await postReturnFormDetails();
  await postRecoveryFormTable();
}

Future<void> postShopVisitData() async {
  DBHelperShopVisit dbHelper = DBHelperShopVisit();
  await dbHelper.postShopVisitData();
}

Future<void> postStockCheckItems() async {
  DBHelperShopVisit dbHelper = DBHelperShopVisit();
  await dbHelper.postStockCheckItems();
}

Future<void> postAttendanceOutTable() async {
  DBHelperProductCategory dbHelper = DBHelperProductCategory();
  await dbHelper.postAttendanceOutTable();
}

Future<void> postAttendanceTable() async {
  DBHelperProductCategory dbHelper = DBHelperProductCategory();
  await dbHelper.postAttendanceTable();
}

Future<void> postMasterTable() async {
  DBHelperOrderMaster dbHelper = DBHelperOrderMaster();
  await dbHelper.postMasterTable();
}

Future<void> postOrderDetails() async {
  DBHelperOrderMaster dbHelper = DBHelperOrderMaster();
  await dbHelper.postOrderDetails();
}

Future<void> postShopTable() async {
  DBHelper dbHelper = DBHelper();
  await dbHelper.postShopTable();
}

Future<void> postReturnFormTable() async {
  print('Attempting to post Return data');
  DBHelperReturnForm dbHelper = DBHelperReturnForm();
  await dbHelper.postReturnFormTable();
  print('Return data posted successfully');
}

Future<void> postReturnFormDetails() async {
  DBHelperReturnForm dbHelper = DBHelperReturnForm();
  await dbHelper.postReturnFormDetails();
}

Future<void> postRecoveryFormTable() async {
  DBHelperRecoveryForm dbHelper = DBHelperRecoveryForm();
  await dbHelper.postRecoveryFormTable();
}
