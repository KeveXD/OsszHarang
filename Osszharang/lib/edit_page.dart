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

    // Kezdő dátum beállítása (következő perc eleje)
    valasztottDatum = DateTime.now().add(const Duration(minutes: 1));
    valasztottDatum = valasztottDatum.copyWith(second: 0, millisecond: 0);

    hour = valasztottDatum.hour;
    minute = valasztottDatum.minute;

    loopAudio = false;
    vibrate = false;
    volume = null;
    hang = 'assets/harang.mp3';

    _minuteController = FixedExtentScrollController(initialItem: minute);
    _hourController = FixedExtentScrollController(initialItem: hour);
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = DateTime(valasztottDatum.year, valasztottDatum.month, valasztottDatum.day).difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Ma - ${DateFormat('EEEE, MMMM d', 'hu_HU').format(valasztottDatum)}';
      case 1:
        return 'Holnap - ${DateFormat('EEEE, MMMM d', 'hu_HU').format(valasztottDatum)}';
      default:
        return DateFormat('EEEE, MMMM d', 'hu_HU').format(valasztottDatum);
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = widget.alarmSettings?.id ?? DateTime.now().millisecondsSinceEpoch % 10000;

    return AlarmSettings(
      id: id,
      dateTime: valasztottDatum,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: hang,
      notificationTitle: 'Összetartozás Harangja',
      notificationBody: 'trianoni évforduló',
    );
  }

  void saveAlarm() {
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) {
        Navigator.pop(context, true);
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    DateTime tempDate = DateTime(
      valasztottDatum.year,
      valasztottDatum.month,
      valasztottDatum.day,
      hour,
      minute,
    );

    // Ha a beállított idő már elmúlt a mai napon, tegye át holnapra
    if (tempDate.isBefore(now)) {
      tempDate = tempDate.add(const Duration(days: 1));
    }

    setState(() {
      valasztottDatum = tempDate;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: valasztottDatum,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
    );

    if (picked != null) {
      setState(() {
        valasztottDatum = DateTime(
          picked.year,
          picked.month,
          picked.day,
          hour,
          minute,
        );
        _updateTime(); // Ellenőrizzük, hogy az idő érvényes-e így is
      });
    }
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

            // 2. MENTÉS ÉS MÉGSEM GOMBOK (Feljebb hozva)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text("Mégsem", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: saveAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text("Mentés", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // 3. DÁTUMVÁLASZTÓ KÁRTYA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.blueGrey.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: Text(
                    getDay(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.white54, size: 20),
                  onTap: () => _selectDate(context),
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
        squeeze: 0.9,
        diameterRatio: 1.5,
        useMagnifier: true,
        looping: true,
        itemExtent: 80,
        scrollController: controller,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Colors.transparent),
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