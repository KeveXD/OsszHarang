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

DateTime valasztottDatum = DateTime.now();

class _EditPageState extends State<EditPage> {
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String hang;
  int hour = 0;
  int minute = 0;
  FixedExtentScrollController _minuteController = FixedExtentScrollController();
  FixedExtentScrollController _hourController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    valasztottDatum = DateTime.now().add(const Duration(minutes: 1));
    valasztottDatum = valasztottDatum.copyWith(second: 0, millisecond: 0);
    loopAudio = false;
    vibrate = false;
    volume = null;
    hang = 'assets/harang.mp3';

    _minuteController = FixedExtentScrollController(initialItem: valasztottDatum.minute);
    _hourController = FixedExtentScrollController(initialItem: valasztottDatum.hour);
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = valasztottDatum.difference(today).inDays;

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
    final id = DateTime.now().millisecondsSinceEpoch % 10000;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: valasztottDatum,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: hang,
      notificationTitle: 'Összetartozás Harangja',
      notificationBody: 'trianoni évforduló',
    );
    return alarmSettings;
  }

  void saveAlarm() {
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) {
        // itt allitjuk hogy meddig szoljon
        Future.delayed(const Duration(seconds: 5), () {
          Alarm.stop(buildAlarmSettings().id).then((_) => Navigator.pop(context));
        });
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: CupertinoPicker(
                    squeeze: 0.8,
                    diameterRatio: 5,
                    useMagnifier: true,
                    looping: true,
                    itemExtent: 100,
                    scrollController: _hourController,
                    selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Colors.transparent, capEndEdge: true),
                    onSelectedItemChanged: ((value) {
                      setState(() {
                        hour = value;
                      });
                      _time();
                    }),
                    children: [
                      for (int i = 0; i < 24; i++) ...[Center(child: Text('$i', style: const TextStyle(fontSize: 50)))],
                    ],
                  ),
                ),
                const Text(":", style: TextStyle(fontSize: 50)),
                Flexible(
                  flex: 1,
                  child: CupertinoPicker(
                    squeeze: 0.8,
                    diameterRatio: 5,
                    looping: true,
                    itemExtent: 100,
                    scrollController: _minuteController,
                    selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Colors.transparent, capEndEdge: true),
                    onSelectedItemChanged: ((value) {
                      setState(() {
                        minute = value;
                        _time();
                      });
                    }),
                    children: [
                      for (int i = 0; i <= 59; i++) ...[Center(child: Text(i.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 50)))],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(getDay()),
                      trailing: IconButton(onPressed: () => _selectDate(context), icon: const Icon(Icons.calendar_month_outlined)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Mégsem", style: TextStyle(color: Colors.blue)))),
              SizedBox(child: ElevatedButton(onPressed: saveAlarm, child: Text("Mentés", style: TextStyle(color: Colors.blue)))),
            ],
          ),
        ],
      ),
    );
  }

  //egy adott idopontot allit be String->DateTime
  //valasztottDatum frissul
  void _time() {
    String timeString = "$hour:$minute";

    DateTime dateTime = convertStringToDateTime(timeString);
    //frissiti a widgetet egy callback fuggvennyel
    setState(() {
      valasztottDatum = dateTime;
      if (valasztottDatum.isBefore(DateTime.now())) {
        valasztottDatum = valasztottDatum.add(const Duration(days: 1));
      }
      getDay();
    });
  }

  DateTime convertStringToDateTime(String timeString) {
    DateFormat format = DateFormat('HH:mm');
    DateTime dateTime = format.parse(timeString);

    DateTime today = DateTime.now();
    dateTime = DateTime(today.year, today.month, today.day, dateTime.hour, dateTime.minute);

    return dateTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? now = await showDatePicker(context: context, firstDate: DateTime.now(), currentDate: valasztottDatum, lastDate: DateTime(2030, 12, 31));

    if (now != null) {
      setState(() {
        valasztottDatum = now;
        if (valasztottDatum.isBefore(DateTime.now())) {
          valasztottDatum = valasztottDatum.add(const Duration(days: 1));
        }
        getDay();
      });
    }
  }
}
