import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:intl/intl.dart';
import 'package:osszharang_app/harangozas_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'edit_page.dart';
import 'trianoni_harang_szerkesztes.dart';
import 'ido.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<AlarmSettings> harangok;
  static StreamSubscription<AlarmSettings>? subscription;
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  bool isDescriptionVisible = false;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
    }

    harangokBetoltese();
    //figyeli a streamet es ha uj adat erkezik a stream-re akkor meghivja a fuggvenyt
    subscription ??= Alarm.ringStream.stream.listen((alarmSettings) => navigateToRingScreen(alarmSettings));
  }

  // Hang leállítása
  void _stopAudio() async {
    await _audioPlayer.stopPlayer();
  }

  void harangokBetoltese() {
    setState(() {
      harangok = Alarm.getAlarms();
      //teszthez kell
      harangok.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => HarangozasPage(alarmSettings: alarmSettings)));
    harangokBetoltese();
  }

  Future<void> navigateToEditPage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage()));
    harangokBetoltese();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint('Notification permission ${res.isGranted ? '' : 'not'} granted.');
    }
  }

  @override
  void dispose() {
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.white54.withOpacity(0.3), BlendMode.modulate),
            child: Image.asset('assets/hatter.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),
          Container(color: Colors.black.withOpacity(0.2)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(child: Realtime()),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [IconButton(onPressed: () => navigateToEditPage(), icon: const Icon(Icons.add))],
                ),
                harangok.isNotEmpty
                    ? Expanded(
                      child: ListView.builder(
                        itemCount: harangok.length,
                        itemBuilder: (context, index) {
                          return _buildHarangKartya(harangok[index], index);
                        },
                      ),
                    )
                    : Expanded(
                      child: Column(
                        children: [
                          Text("Összetartozás harangja", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              TrianoniHarangSzerkesztes.trianoniHarangHozzaadasa();
                              harangokBetoltese();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("ÖsszHarang", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDescriptionVisible = !isDescriptionVisible; // Toggle description visibility
                              });
                            },
                            child: Text("Leírás", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16)),
                          ),
                          const SizedBox(height: 10),
                          // Only show description text if 'isDescriptionVisible' is true
                          Visibility(
                            visible: isDescriptionVisible,
                            child: Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      """Vegyük kezünkbe a trianoni emlékharangozást! 

1920. június 4-én 16:32 perckor aláírták a trianoni békediktátumot a versailles-i Nagy-Trianon kastély 52 méter hosszú és 7 méter széles folyosóján, a La galérie des Cotelle-ben. Ezen a napon Magyarország elveszítette területének kétharmadát, a magyar népesség egyharmada pedig a határokon kívülre került. 

Ennek emlékére évekig országszerte megszólaltak a templomharangok ebben az időben. Ez a hagyomány azonban 1945 után teljesen megszűnt. 

2012-ben a három, nagy keresztény egyház visszautasította azt a kormányzati kérést, hogy június 4-én, a Nemzeti Összetartozás Napján délután, a trianoni szerződés aláírásának időpontjában konduljanak meg a templomok harangjai, s szóljanak egy percig a megemlékezés részeként. Ezért gondoltuk úgy, hogy saját kezünkbe kell venni ennek a harangozásnak a feladatát. 

Ez az applikáció nem tesz mást, mint minden évben figyelmezteti használóját az emlékezés szükségességére azzal, hogy június 4-én, 16:32-kor automatikusan megszólaltatja ezt az emlékharangot annyi másodpercre, amennyi az adott trianoni évforduló. Szintén megszólítja tulajdonosát, figyelmeztetve az esemény fontosságára. 

Miután a trianoni emléknapját és a Nemzeti Összetartozás Napját együtt kell reprezentálnia, ezért ez az applikáció az ÖSSZHARANG nevet kapta. Egyszerre szól az emlékezés és a jövőbe vetett hitünk, összetartozásunk hangján. 

Bárhol is érjen ezen harangozás pillanata, állj meg egy percre és tartsd magasba a telefonod. Lesznek, akik majd megkérdezik, mire vélhetik ezt a jelenetet. Akkor lehet-kell elmondani, hogy 1920-ban, ebben a pillanatban veszített el Magyarország területének háromnegyedét. Kifejthetjük a szükséges részletességig nemzeti tragédiánk hátterét. Ugyanakkor a harang azokért is szól, akik kint rekedtek a magyar határokon túl és idegen hatalmak, országok polgáraiként élik azóta is életüket. 

Nem felejtjük el, hogy mindezek ellenére mi összetartozunk. Magyarország, a magyar nemzet egy és oszthatatlan. 

Ezt az applikációt ki lehet kapcsolni, ha valaki előre látja, hogy a harangozás idején, zavarná az aktuális programjában. A telefon egy héttel, és később egy nappal a harangozást megelőzően még rákérdez a kikapcsolás szükségességére. 

Kérlek add tovább ennek az applikációnak hírét, hogy minél több honfitárunkkal együtt emlékezhessünk és emlékeztethessünk! 

Szilágyi Ákos – 56 Lángja Alapítvány""",
                                      textAlign: TextAlign.justify,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildHarangKartya(AlarmSettings alarm, int index) {
    TimeOfDay time = TimeOfDay.fromDateTime(alarm.dateTime);
    String formattedDate = DateFormat('EEEE, dd MMM', 'hu_HU').format(alarm.dateTime);
    DateTime now = DateTime.now();
    Duration difference = alarm.dateTime.difference(now);

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    return GestureDetector(
      child: Slidable(
        closeOnScroll: true,
        endActionPane: ActionPane(
          extentRatio: 0.4,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              onPressed: (context) {
                Alarm.stop(alarm.id);
                harangokBetoltese();
              },
              icon: Icons.delete_forever,
              backgroundColor: Colors.red.shade700,
            ),
          ],
        ),
        child: Card(
          color: Colors.grey.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(formattedDate, style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Text("Harangozás", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text("${days} nap ${hours} óra ${minutes} perc múlva", style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: AssetImage('assets/harang.jpg'), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
