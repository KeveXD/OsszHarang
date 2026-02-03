import 'dart:async';
import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osszharang_app/harangozas_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

// Saját fájlok importja
import 'beallitasok.dart';
import 'edit_page.dart';
import 'trianoni_harang_szerkesztes.dart';
import 'ido.dart';
import 'theme.dart';   // <--- ÚJ: Dizájn rendszer
import 'strings.dart'; // <--- ÚJ: Szövegek

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<AlarmSettings> harangok;
  static StreamSubscription<AlarmSettings>? subscription;
  bool isDescriptionVisible = false;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
    }

    harangokBetoltese();

    subscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
      navigateToRingScreen(alarmSettings);
    });
  }

  void harangokBetoltese() {
    setState(() {
      harangok = Alarm.getAlarms();
      harangok.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://osszharang.com');
    try {
      await launcher.launchUrl(
        url,
        mode: launcher.LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Hiba a weboldal megnyitásakor: $e');
    }
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HarangozasPage(alarmSettings: alarmSettings)),
    );
    harangokBetoltese();
  }

  Future<void> navigateToEditPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditPage()),
    );
    harangokBetoltese();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) await Permission.notification.request();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase, // Téma szín (Sötétzöld)
      body: Stack(
        children: [
          // --- HÁTTÉR ---
          Positioned.fill(
            child: Image.asset(
              'assets/hatter.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                // Téma szín (Halvány zöld fólia)
                color: AppTheme.backgroundOverlay.withOpacity(0.4),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // FELSŐ SÁV (Link + Ikonok)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Link Gomb
                      InkWell(
                        onTap: _launchUrl,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          // MÓDOSÍTÁS: Sötétzöld keret hozzáadva
                          decoration: AppTheme.glassDecoration(
                              opacity: 0.4,
                              borderColor: AppTheme.borderDarkGreen
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.public, color: AppTheme.accentRed, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                "osszharang.com",
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Jobb oldali ikonok
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BeallitasokPage()),
                              );
                              harangokBetoltese();
                            },
                            icon: const Icon(Icons.settings, color: AppTheme.textPrimary),
                            tooltip: "Beállítások",
                          ),
                          IconButton(
                            onPressed: navigateToEditPage,
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.textPrimary, size: 30),
                            tooltip: "Új harangozás",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- ÓRA (GLOWING RED) ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),

                  // Itt hívjuk meg az új, sötétvörös stílust a theme.dart-ból
                  decoration: AppTheme.glowingRedDecoration(),

                  child: Center(
                    // Ez pedig az új, vagány óra widget az ido.dart-ból
                    child: Realtime(),
                  ),
                ),

                // Leírás gomb
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextButton.icon(
                    onPressed: () => setState(() => isDescriptionVisible = !isDescriptionVisible),
                    icon: Icon(
                      isDescriptionVisible ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textPrimary,
                    ),
                    label: Text(
                      isDescriptionVisible ? "Leírás elrejtése" : "Miért szól a harang?",
                      style: const TextStyle(color: AppTheme.textPrimary, letterSpacing: 1),
                    ),
                  ),
                ),

                // TARTALOM
                Expanded(
                  child: isDescriptionVisible
                      ? _buildDescription()
                      : (harangok.isEmpty ? _buildEmptyState() : _buildAlarmList()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI ÉPÍTŐ ELEMEK ---
  Widget _buildAlarmList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: harangok.length,
      itemBuilder: (context, index) => _buildHarangKartya(harangok[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: AppTheme.textPrimary.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            "Nincs beállított harangozás",
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                shadows: [Shadow(blurRadius: 5, color: Colors.black)]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(25),
      // MÓDOSÍTÁS: Sötétzöld keret hozzáadva
      decoration: AppTheme.glassDecoration(
          opacity: 0.7,
          borderColor: AppTheme.borderDarkGreen
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.history_edu, color: AppTheme.accentRed, size: 36),
              const SizedBox(height: 20),
              Text(
                AppStrings.trianonDescription,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHarangKartya(AlarmSettings alarm) {
    String time = DateFormat('HH:mm').format(alarm.dateTime);
    String date = DateFormat('EEEE, dd MMM', 'hu_HU').format(alarm.dateTime);

    // Kártya helyett Container-t használunk, hogy rátehessük a saját üveg-dekorációnkat
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      // MÓDOSÍTÁS: Sötétzöld keret hozzáadva
      decoration: AppTheme.glassDecoration(
          opacity: 0.5,
          borderColor: AppTheme.borderDarkGreen
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: 2)),
                  Text(date, style: const TextStyle(color: AppTheme.accentRed, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24)
                    ),
                    child: const Text("EMLÉKHARANGOZÁS", style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 2)]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/harang.jpg', width: 85, height: 85, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}