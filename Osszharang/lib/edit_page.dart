import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPage extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const EditPage({Key? key, this.alarmSettings}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late DateTime valasztottDatum;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String hang;

  int hour = 0;
  int minute = 0;

  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _hourController;

  @override
  void initState() {
    super.initState();

    valasztottDatum = DateTime.now().add(const Duration(minutes: 1));
    valasztottDatum = valasztottDatum.copyWith(second: 0, millisecond: 0);

    hour = valasztottDatum.hour;
    minute = valasztottDatum.minute;

    loopAudio = false;
    vibrate = false;
    volume = 0.1;
    hang = 'assets/harangozas2.mp3';

    _minuteController = FixedExtentScrollController(initialItem: minute);
    _hourController = FixedExtentScrollController(initialItem: hour);
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  // Segédfüggvény az AlarmSettings összeállításához
  AlarmSettings _createSettings(DateTime scheduledTime, {bool isTest = false}) {
    final id = widget.alarmSettings?.id ?? DateTime.now().millisecondsSinceEpoch % 10000;
    return AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: hang,
      notificationTitle: isTest ? 'Teszt harangozás' : 'Összetartozás Harangja',
      notificationBody: isTest ? 'A teszt sikeres!' : 'trianoni évforduló',

      // --- EZEK KELLENEK A HÁTTÉRBŐL INDULÁSHOZ ---
      androidFullScreenIntent: true,   // Ez nyitja meg az appot a háttérből
      enableNotificationOnKill: true,  // Ez tartja életben a rendszert kilövés után
    );
  }

  // Normál mentés (a picker értékei alapján)
  void saveAlarm() {
    Alarm.set(alarmSettings: _createSettings(valasztottDatum)).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  // GYORS TESZT: Azonnali mentés +5 másodpercre
  void quickTest() {
    final testTime = DateTime.now().add(const Duration(seconds: 6));
    Alarm.set(alarmSettings: _createSettings(testTime, isTest: true)).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    DateTime tempDate = DateTime(valasztottDatum.year, valasztottDatum.month, valasztottDatum.day, hour, minute);
    if (tempDate.isBefore(now)) tempDate = tempDate.add(const Duration(days: 1));
    setState(() => valasztottDatum = tempDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. IDŐVÁLASZTÓ
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(_hourController, 24, (value) {
                    hour = value;
                    _updateTime();
                  }),
                  const Text(":", style: TextStyle(fontSize: 50, color: Colors.white)),
                  _buildPicker(_minuteController, 60, (value) {
                    minute = value;
                    _updateTime();
                  }, isMinute: true),
                ],
              ),
            ),

            // 2. GYORS TESZT GOMB (Kiemelve)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: OutlinedButton.icon(
                onPressed: quickTest,
                icon: const Icon(Icons.flash_on, color: Colors.orangeAccent),
                label: const Text("GYORS TESZT (+5 mp)", style: TextStyle(color: Colors.orangeAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orangeAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            // 3. MENTÉS ÉS MÉGSEM GOMBOK
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Mégsem", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: saveAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text("MENTÉS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // 4. DÁTUMVÁLASZTÓ KÁRTYA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.blueGrey.shade800,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: Text(
                    DateFormat('EEEE, MMMM d', 'hu_HU').format(valasztottDatum),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(FixedExtentScrollController controller, int count, ValueChanged<int> onChanged, {bool isMinute = false}) {
    return Flexible(
      child: CupertinoPicker(
        itemExtent: 80,
        scrollController: controller,
        onSelectedItemChanged: onChanged,
        children: List.generate(count, (i) => Center(
          child: Text(
            isMinute ? i.toString().padLeft(2, '0') : i.toString(),
            style: const TextStyle(fontSize: 45, color: Colors.white),
          ),
        )),
      ),
    );
  }
}