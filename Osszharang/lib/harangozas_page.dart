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
          // 1. HÁTTÉRKÉP (Ugyanaz, mint a többi oldalon, vagy a harangborito)
          Positioned.fill(
            child: Image.asset(
              'assets/harangborito.jpg', // Itt megtartottam a specifikus képet
              fit: BoxFit.cover,
            ),
          ),

          // 2. HOMÁLYOSÍTÁS ÉS SZÍN FÓLIA (Téma szerint)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: AppTheme.backgroundOverlay.withOpacity(0.5), // Zöldes réteg
              ),
            ),
          ),

          // 3. TARTALOM
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // CÍM
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    widget.alarmSettings.notificationTitle ?? "Emlékharangozás",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),

                // ANIMÁCIÓ (Izzó piros körben)
                SwingAnimation(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: AppTheme.glowingRedDecoration(), // A téma izzó effektje!
                    child: Center(
                      child: Text(
                        "🔔",
                        style: TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),

                // LEÁLLÍTÁS GOMB
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.accentRed.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2
                          )
                        ]
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showExitConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed, // Sötétvörös
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "HARANGOZÁS LEÁLLÍTÁSA",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  // Megerősítő párbeszédpanel (Témázva)
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Üveghatású dialógus
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: AppTheme.backgroundBase.withOpacity(0.9), // Sötétzöld háttér
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppTheme.accentRed, width: 1), // Piros keret
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
                onPressed: () => Navigator.pop(context), // Mégsem
                child: const Text("MÉGSEM", style: TextStyle(color: AppTheme.textTertiary)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Leállítás és kilépés
                  Alarm.stop(widget.alarmSettings.id).then((_) => Navigator.pop(context)); // Bezár dialog
                  Navigator.pop(context); // Bezár oldal
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

// Az animáció változatlan maradt, csak a hívása változott fent
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