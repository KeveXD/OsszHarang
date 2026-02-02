import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:osszharang_app/harangozas_page.dart';
import 'package:osszharang_app/edit_page.dart';

// Saját erőforrás fájlok importálása
import 'theme.dart';
import 'strings.dart';

class BeallitasokPage extends StatefulWidget {
  const BeallitasokPage({Key? key}) : super(key: key);

  @override
  State<BeallitasokPage> createState() => _BeallitasokPageState();
}

class _BeallitasokPageState extends State<BeallitasokPage> {
  // Alapértelmezett értékek
  bool _vibration = true;
  double _volume = 0.8;

  // Ünnepek kapcsolói - ALAPÉRTELMEZETTEN MINDEN HAMIS (KIKAPCSOLVA)
  bool _jun4 = false;
  bool _mar15 = false;
  bool _aug20 = false;
  bool _okt6 = false;
  bool _okt23 = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibration = prefs.getBool('vibration') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.8;

      // Itt állítjuk be, hogy ha nincs mentett adat, akkor false legyen
      _jun4 = prefs.getBool('jun4') ?? false;
      _mar15 = prefs.getBool('mar15') ?? false;
      _aug20 = prefs.getBool('aug20') ?? false;
      _okt6 = prefs.getBool('okt6') ?? false;
      _okt23 = prefs.getBool('okt23') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  DateTime _getNextHolidayDate(int month, int day, int hour, int minute) {
    final now = DateTime.now();
    DateTime target = DateTime(now.year, month, day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 365));
    }
    return target;
  }

  Future<void> _toggleHolidayAlarm({
    required bool isEnabled,
    required int id,
    required String title,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    if (isEnabled) {
      final date = _getNextHolidayDate(month, day, hour, minute);

      await EditPage.harangozasMentese(
        idopont: date,
        vibrate: _vibration,
        volume: _volume,
        cim: title,
        szoveg: "Emlékharangozás",
        kotelezoId: id,
      );
    } else {
      await Alarm.stop(id);
    }
  }

  // --- PRÓBAHARANGOZÁS ---
  Future<void> _startTestRing() async {
    final now = DateTime.now();

    final dummyAlarm = AlarmSettings(
      id: 999,
      dateTime: now,
      assetAudioPath: 'assets/harangozas2.mp3',
      loopAudio: false,
      vibrate: _vibration,
      volume: _volume,
      notificationTitle: 'Próba Harangozás',
      notificationBody: 'A hangnak szólnia kell!',
      androidFullScreenIntent: true,
      enableNotificationOnKill: true,
    );

    await Alarm.stop(999);
    await Alarm.set(alarmSettings: dummyAlarm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase, // Mélyzöld háttér
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditPage()),
          );
        },
        backgroundColor: Colors.black.withOpacity(0.6),
        foregroundColor: AppTheme.textPrimary,
        elevation: 10,
        shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
        child: const Icon(Icons.add, size: 30),
      ),
      body: Stack(
        children: [
          // 1. HÁTTÉRKÉP
          Positioned.fill(
            child: Image.asset('assets/hatter.jpg', fit: BoxFit.cover),
          ),
          // 2. HOMÁLYOSÍTÁS ÉS SZÍN FÓLIA
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: AppTheme.backgroundOverlay.withOpacity(0.4),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Beállítások",
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSectionTitle("MEGBÍZHATÓ MŰKÖDÉS (FONTOS!)"),
                      Container(
                        decoration: AppTheme.glassDecoration(opacity: 0.5),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, color: AppTheme.accentRed, size: 28),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          AppStrings.reliableOperationTitle,
                                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          AppStrings.reliableOperationBody,
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDivider(),
                            InkWell(
                              onTap: () async {
                                await openAppSettings();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Center(
                                  child: Text(
                                    "ANDROID BEÁLLÍTÁSOK MEGNYITÁSA",
                                    style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildSectionTitle("HANG ÉS REZGÉS"),
                      Container(
                        decoration: AppTheme.glassDecoration(opacity: 0.5),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              title: "Rezgés harangozáskor",
                              icon: Icons.vibration,
                              value: _vibration,
                              onChanged: (val) {
                                setState(() => _vibration = val);
                                _saveBool('vibration', val);
                              },
                            ),
                            _buildDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.volume_up, color: AppTheme.textSecondary, size: 24),
                                      const SizedBox(width: 15),
                                      Text("Hangerő: ${(_volume * 100).toInt()}%", style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
                                    ],
                                  ),
                                  Slider(
                                    value: _volume,
                                    min: 0.0,
                                    max: 1.0,
                                    activeColor: AppTheme.accentRed,
                                    inactiveColor: AppTheme.textSecondary.withOpacity(0.3), // Halványzöld inaktív csík
                                    onChanged: (val) {
                                      setState(() => _volume = val);
                                      _saveDouble('volume', val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            _buildDivider(),
                            InkWell(
                              onTap: _startTestRing,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Center(
                                  child: Text(
                                    "PRÓBAHARANGOZÁS INDÍTÁSA",
                                    style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildSectionTitle("AUTOMATIKUS HARANGOZÁSOK"),
                      Container(
                        decoration: AppTheme.glassDecoration(opacity: 0.5),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              title: "Június 4. (16:32)",
                              subtitle: "Nemzeti Összetartozás Napja",
                              icon: Icons.notifications_active,
                              value: _jun4,
                              onChanged: (val) {
                                setState(() => _jun4 = val);
                                _saveBool('jun4', val);
                                _toggleHolidayAlarm(
                                    isEnabled: val, id: 604, title: "Trianoni Emlékharang",
                                    month: 6, day: 4, hour: 16, minute: 32
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: "Március 15. (12:00)",
                              subtitle: "Nemzeti ünnep",
                              icon: Icons.flag,
                              value: _mar15,
                              onChanged: (val) {
                                setState(() => _mar15 = val);
                                _saveBool('mar15', val);
                                _toggleHolidayAlarm(
                                    isEnabled: val, id: 315, title: "Március 15. Emlékharang",
                                    month: 3, day: 15, hour: 12, minute: 0
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: "Augusztus 20. (12:00)",
                              subtitle: "Államalapítás ünnepe",
                              icon: Icons.flag,
                              value: _aug20,
                              onChanged: (val) {
                                setState(() => _aug20 = val);
                                _saveBool('aug20', val);
                                _toggleHolidayAlarm(
                                    isEnabled: val, id: 820, title: "Augusztus 20. Emlékharang",
                                    month: 8, day: 20, hour: 12, minute: 0
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: "Október 6. (12:00)",
                              subtitle: "Aradi vértanúk emléknapja",
                              icon: Icons.history_edu,
                              value: _okt6,
                              onChanged: (val) {
                                setState(() => _okt6 = val);
                                _saveBool('okt6', val);
                                _toggleHolidayAlarm(
                                    isEnabled: val, id: 1006, title: "Aradi Vértanúk Harangja",
                                    month: 10, day: 6, hour: 12, minute: 0
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: "Október 23. (12:00)",
                              subtitle: "1956-os forradalom",
                              icon: Icons.flag,
                              value: _okt23,
                              onChanged: (val) {
                                setState(() => _okt23 = val);
                                _saveBool('okt23', val);
                                _toggleHolidayAlarm(
                                    isEnabled: val, id: 1023, title: "1956-os Emlékharang",
                                    month: 10, day: 23, hour: 12, minute: 0
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.textPrimary, // Gomb színe
      activeTrackColor: AppTheme.accentRed, // Sáv színe ha aktív
      inactiveThumbColor: AppTheme.textSecondary, // Gomb színe ha inaktív
      inactiveTrackColor: Colors.white10, // Sáv színe ha inaktív
      // Az ikon színe: Ha aktív -> PIROS, ha inaktív -> HALVÁNYZÖLD (téma másodlagos szín)
      secondary: Icon(icon, color: value ? AppTheme.accentRed : AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }
}