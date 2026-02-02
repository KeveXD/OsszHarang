import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osszharang_app/harangozas_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

// Saját fájlok importja
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
    List<AlarmSettings> currentAlarms = Alarm.getAlarms();

    // Ha üres a lista, automatikusan hozzáadjuk a Trianoni harangot
    if (currentAlarms.isEmpty) {
      TrianoniHarangSzerkesztes.trianoniHarangHozzaadasa();
      currentAlarms = Alarm.getAlarms();
    }

    setState(() {
      harangok = currentAlarms;
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

  void _showPermissionSettingsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Beállítások", style: TextStyle(color: Colors.white)),
        content: const Text(
          "A megbízható működéshez ellenőrizze a 'Megjelenítés más alkalmazások felett' engedélyt.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("MÉGSEM", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("BEÁLLÍTÁS", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
      body: Stack(
        children: [
          // HÁTTÉR
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.darken,
              ),
              child: Image.asset('assets/hatter.jpg', fit: BoxFit.cover),
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
                      // Weboldal link (Kicsi, elegáns)
                      InkWell(
                        onTap: _launchUrl,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black38,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.public, color: Colors.orangeAccent, size: 16),
                              SizedBox(width: 8),
                              Text(
                                "osszharang.com",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: _showPermissionSettingsPopup,
                            icon: const Icon(Icons.settings, color: Colors.white70),
                            tooltip: "Engedélyek",
                          ),
                          IconButton(
                            onPressed: navigateToEditPage,
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                            tooltip: "Új harangozás",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // DIZÁJNOS ÓRA KERET (Realtime widget becsomagolva)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // Nagyon halvány háttér
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white10, width: 1), // Vékony keret
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                  ),
                  child: Center(
                    // Itt hívjuk meg a te Realtime widgetedet
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
                      color: Colors.white60,
                    ),
                    label: Text(
                      isDescriptionVisible ? "Leírás elrejtése" : "Miért szól a harang?",
                      style: const TextStyle(color: Colors.white60),
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

  // LISTA NÉZET
  Widget _buildAlarmList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: harangok.length,
      itemBuilder: (context, index) => _buildHarangKartya(harangok[index]),
    );
  }

  // ÜRES ÁLLAPOT (A kért új gombbal)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_outlined, size: 50, color: Colors.white24),
          const SizedBox(height: 20),

          // ÚJ DIZÁJNÚ GOMB
          Container(
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                TrianoniHarangSzerkesztes.trianoniHarangHozzaadasa();
                harangokBetoltese();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000), // Sötétvörös (vér/hazafias)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                side: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              icon: const Icon(Icons.refresh, size: 28),
              label: const Text(
                "Trianoni harang (16:32)\nbekapcsolása",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LEÍRÁS NÉZET
  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.history_edu, color: Colors.orangeAccent, size: 30),
              const SizedBox(height: 15),
              Text(
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
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HARANG KÁRTYA NÉZET
  Widget _buildHarangKartya(AlarmSettings alarm) {
    String time = DateFormat('HH:mm').format(alarm.dateTime);
    String date = DateFormat('EEEE, dd MMM', 'hu_HU').format(alarm.dateTime);

    return Card(
      elevation: 6,
      color: Colors.black45, // Áttetsző sötét
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                      Text(date, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text("EMLÉKHARANGOZÁS", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1)]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/harang.jpg', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          // X TÖRLÉS GOMB
          Positioned(
            right: 5,
            top: 5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await Alarm.stop(alarm.id);
                  harangokBetoltese();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.close, color: Colors.white38, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}