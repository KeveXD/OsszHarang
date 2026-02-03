import 'dart:ui'; // Kell a Blur effekthez
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:alarm/model/alarm_settings.dart';

// Saját téma importálása
import 'theme.dart';

class HarangozasPage extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const HarangozasPage({Key? key, required this.alarmSettings}) : super(key: key);

  @override
  _HarangozasPageState createState() => _HarangozasPageState();
}

class _HarangozasPageState extends State<HarangozasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase, // Sötétzöld alap
      body: Stack(
        children: [
          // 1. HÁTTÉRKÉP
          Positioned.fill(
            child: Image.asset(
              'assets/harangozas.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. HOMÁLYOSÍTÁS ÉS SZÍN FÓLIA
          Positioned.fill(
            child: BackdropFilter(
              // Egy pici homályosítást (3.0) visszatettem, hogy az elegáns vékony betűk olvashatóak legyenek
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: AppTheme.backgroundOverlay.withOpacity(0.5), // Zöldes réteg
              ),
            ),
          ),

          // 3. TARTALOM
          SafeArea(
            child: Column(
              children: [
                // FELSŐ CÍM - Feljebb hozva
                const SizedBox(height: 40), // Távolság a tetejétől
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Text(
                        (widget.alarmSettings.notificationTitle ?? "EMLÉKHARANGOZÁS").toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22, // Kicsit kisebb, de...
                          fontWeight: FontWeight.w300, // ...vékonyabb és...
                          letterSpacing: 4.0, // ...ritkítottabb (elegánsabb)
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Díszítő vonal a cím alatt
                      Container(
                        width: 60,
                        height: 1,
                        color: AppTheme.accentRed.withOpacity(0.8),
                      )
                    ],
                  ),
                ),

                const Spacer(), // Ez tolja középre a harangot

                // ANIMÁCIÓ (Középen)
                SwingAnimation(
                  child: Center(
                    child: Text(
                      "🔔",
                      style: TextStyle(
                          fontSize: 100,
                          shadows: [
                            Shadow(
                                blurRadius: 40,
                                color: AppTheme.accentRed.withOpacity(0.5),
                                offset: const Offset(0, 0)
                            )
                          ]
                      ),
                    ),
                  ),
                ),

                const Spacer(), // Ez tolja le a gombot

                // LEÁLLÍTÁS GOMB - Szerényebb, keretes (Outlined) stílus
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0, left: 40, right: 40),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showExitConfirmationDialog(context);
                    },
                    icon: const Icon(Icons.stop_circle_outlined, color: AppTheme.textPrimary),
                    label: const Text(
                      "HARANGOZÁS LEÁLLÍTÁSA",
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      // Átlátszó háttér, vékony piros keret
                      side: const BorderSide(color: AppTheme.accentRed, width: 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.black.withOpacity(0.2), // Nagyon halvány sötét háttér a gombnak
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

  // Megerősítő párbeszédpanel (Témázva)
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: AppTheme.backgroundBase.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppTheme.accentRed, width: 1),
            ),
            title: const Text(
                "Leállítás",
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)
            ),
            content: const Text(
              "Biztosan meg szeretnéd szakítani a harangozást?",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("MÉGSEM", style: TextStyle(color: AppTheme.textTertiary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Alarm.stop(widget.alarmSettings.id).then((_) => Navigator.pop(context));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
                child: const Text("IGEN, LEÁLLÍTÁS", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Animáció (változatlan)
class SwingAnimation extends StatefulWidget {
  final Widget child;
  const SwingAnimation({Key? key, required this.child}) : super(key: key);
  @override
  _SwingAnimationState createState() => _SwingAnimationState();
}

class _SwingAnimationState extends State<SwingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: Tween<double>(begin: -0.05, end: 0.05).animate(_controller), child: widget.child);
  }
}