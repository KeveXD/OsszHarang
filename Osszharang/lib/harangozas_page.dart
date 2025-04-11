import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:alarm/model/alarm_settings.dart';

class HarangozasPage extends StatefulWidget {
  final AlarmSettings alarmSettings;

  HarangozasPage({Key? key, required this.alarmSettings}) : super(key: key);

  @override
  _HarangozasPageState createState() => _HarangozasPageState();
}

class _HarangozasPageState extends State<HarangozasPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white54.withOpacity(0.3), BlendMode.modulate),
              child: Image.asset('assets/harangborito.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Container(color: Colors.black.withOpacity(0.2)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Trianoni évforduló", style: Theme.of(context).textTheme.titleLarge),
                SwingAnimation(child: Text("🔔", style: TextStyle(fontSize: 70))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        _showExitConfirmationDialog(context);
                      },
                      child: Text("Vége", style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Megerősítő párbeszédpanel, ha a felhasználó a "Vége" gombra kattint
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Biztosan ki szeretne lépni a harangozásból?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Ha a felhasználó "Igen"-t választ, állítsuk le a harangozást és zárjuk be a képernyőt
                Alarm.stop(widget.alarmSettings.id).then((_) => Navigator.pop(context));
                Navigator.pop(context); // Popup window bezárása
              },
              child: Text("Igen"),
            ),
            TextButton(
              onPressed: () {
                // Ha a felhasználó "Nem"-et választ, zárja be a párbeszédpanelt
                Navigator.pop(context);
              },
              child: Text("Nem"),
            ),
          ],
        );
      },
    );
  }
}

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
    return RotationTransition(turns: Tween<double>(begin: -0.08, end: 0.08).animate(_controller), child: widget.child);
  }
}
