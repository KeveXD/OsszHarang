import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart'; // Importáld az új osztályt
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Alarm.init(showDebugLogs: true);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey, brightness: Brightness.dark),
      ),
      home: const PermissionCheckWrapper(),
    ),
  );
}

class PermissionCheckWrapper extends StatefulWidget {
  const PermissionCheckWrapper({super.key});

  @override
  State<PermissionCheckWrapper> createState() => _PermissionCheckWrapperState();
}

class _PermissionCheckWrapperState extends State<PermissionCheckWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLogic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAfterReturning();
    }
  }

  // Fő logika az indításkor
  Future<void> _initLogic() async {
    // 1. Alapvető engedélyek (ezek nem zavaróak, mehetnek minden indításkor)
    await [
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    // 2. Csak akkor mutatjuk a nagy Overlay popupot, ha még nem látta
    bool firstTime = await PermissionService.shouldShowDialog();
    bool isGranted = await Permission.systemAlertWindow.isGranted;

    if (firstTime && !isGranted) {
      _showRequestDialog();
    }
  }

  Future<void> _checkAfterReturning() async {
    if (await Permission.systemAlertWindow.isGranted) {
      _showSuccessDialog();
    }
  }

  void _showRequestDialog() {
    // Mentés: Többször nem fog megjelenni
    PermissionService.setDialogShown();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Első indítás"),
          ],
        ),
        content: const Text(
            "Üdvözöl az ÖsszHarang! A megbízható működéshez kérlek engedélyezd a 'Megjelenítés más alkalmazások felett' opciót."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("KÉSŐBB"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("BEÁLLÍTÁS"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: const Text("Sikeres beállítás! Most már minden kész."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("RENDBEN")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const HomePage();
}