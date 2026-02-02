import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ÚJ: Beállítások olvasásához

// Saját fájlok importja
import 'theme.dart';

class EditPage extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const EditPage({Key? key, this.alarmSettings}) : super(key: key);

  static Future<bool> harangozasMentese({
    required DateTime idopont,
    required bool vibrate,
    required double volume,
    String hang = 'assets/harang.mp3',
    String cim = 'Összetartozás Harangja',
    String szoveg = 'Emlékharangozás',
    int? kotelezoId,
  }) async {

    final id = kotelezoId ?? DateTime.now().millisecondsSinceEpoch % 10000;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: idopont,
      loopAudio: false,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: hang,
      notificationTitle: cim,
      notificationBody: szoveg,
      androidFullScreenIntent: true,
      enableNotificationOnKill: true,
    );

    return await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late DateTime valasztottDatum;

  // UI vezérlők
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _hourController;
  int hour = 0;
  int minute = 0;

  @override
  void initState() {
    super.initState();

    if (widget.alarmSettings != null) {
      valasztottDatum = widget.alarmSettings!.dateTime;
    } else {
      valasztottDatum = DateTime.now().add(const Duration(minutes: 1));
      valasztottDatum = valasztottDatum.copyWith(second: 0, millisecond: 0);
    }

    hour = valasztottDatum.hour;
    minute = valasztottDatum.minute;

    _minuteController = FixedExtentScrollController(initialItem: minute);
    _hourController = FixedExtentScrollController(initialItem: hour);
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    DateTime tempDate = DateTime(valasztottDatum.year, valasztottDatum.month, valasztottDatum.day, hour, minute);

    if (tempDate.isBefore(now)) {
      tempDate = tempDate.add(const Duration(days: 1));
    }

    setState(() => valasztottDatum = tempDate);
  }

  // --- ÚJ: GYORS TESZT (5 mp) + Beállítások betöltése ---
  Future<void> _quickTest() async {
    // 1. Beállítások kiolvasása
    final prefs = await SharedPreferences.getInstance();
    final bool vibrate = prefs.getBool('vibration') ?? true;
    final double volume = prefs.getDouble('volume') ?? 0.8;

    // 2. Idő beállítása (Most + 5 másodperc)
    final DateTime testTime = DateTime.now().add(const Duration(seconds: 5));

    // 3. Mentés
    await EditPage.harangozasMentese(
      idopont: testTime,
      vibrate: vibrate, // A mentett beállítás
      volume: volume,   // A mentett beállítás
      hang: 'assets/harang.mp3', // Vagy 'harangozas2.mp3' attól függően mi a fájl neve
      cim: 'Gyors Teszt',
      szoveg: 'Ez egy próba a beállított hangerővel.',
    );

    // 4. Bezárás
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Harangozás 5 másodperc múlva!", style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.accentRed
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // A normál mentésnél is érdemes lehet használni a mentett beállításokat,
  // vagy itt hagyhatod fixen, ha azt akarod, hogy ez felülírható legyen.
  // Most úgy írtam át, hogy ez is figyelembe vegye a beállításokat.
  Future<void> _saveFromUI() async {
    final prefs = await SharedPreferences.getInstance();
    final bool vibrate = prefs.getBool('vibration') ?? true;
    final double volume = prefs.getDouble('volume') ?? 0.8;

    await EditPage.harangozasMentese(
      idopont: valasztottDatum,
      vibrate: vibrate,
      volume: volume,
      hang: 'assets/harang.mp3',
      cim: 'Egyéni Harangozás',
      szoveg: 'A beállított időpont elérkezett',
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase, // Sötétzöld alap
      body: Stack(
        children: [
          // --- HÁTTÉR ---
          Positioned.fill(
            child: Image.asset('assets/hatter.jpg', fit: BoxFit.cover),
          ),
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
                // FELSŐ SÁV
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppTheme.textPrimary, size: 30),
                      ),
                      const Text(
                        "Új Időpont",
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _saveFromUI,
                        icon: const Icon(Icons.check, color: AppTheme.accentRed, size: 30),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // IDŐVÁLASZTÓ
                Container(
                  height: 200, // Kicsit kisebb, hogy elférjen a gomb
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: AppTheme.glassDecoration(opacity: 0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPicker(_hourController, 24, (value) {
                        hour = value;
                        _updateTime();
                      }),
                      const Text(":", style: TextStyle(fontSize: 50, color: AppTheme.textSecondary, fontWeight: FontWeight.w200)),
                      _buildPicker(_minuteController, 60, (value) {
                        minute = value;
                        _updateTime();
                      }, isMinute: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- ÚJ: GYORS TESZT GOMB ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _quickTest,
                    icon: const Icon(Icons.timer_outlined, color: AppTheme.accentRed),
                    label: const Text(
                        "GYORS TESZT (5 mp)",
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // DÁTUM KIJELZÉS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.accentRed, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM d, EEEE', 'hu_HU').format(valasztottDatum).toUpperCase(),
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // MENTÉS GOMB ALUL
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.accentRed.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 1
                          )
                        ]
                    ),
                    child: ElevatedButton(
                      onPressed: _saveFromUI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                          "IDŐZÍTÉS BEÁLLÍTÁSA",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker(FixedExtentScrollController controller, int count, ValueChanged<int> onChanged, {bool isMinute = false}) {
    return SizedBox(
      width: 80,
      child: CupertinoPicker(
        selectionOverlay: Container(
          decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(color: AppTheme.accentRed, width: 0.8)
              )
          ),
        ),
        itemExtent: 70,
        scrollController: controller,
        onSelectedItemChanged: onChanged,
        children: List.generate(count, (i) => Center(
          child: Text(
            isMinute ? i.toString().padLeft(2, '0') : i.toString(),
            style: const TextStyle(fontSize: 40, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
        )),
      ),
    );
  }
}