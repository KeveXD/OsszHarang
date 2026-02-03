import 'package:flutter/material.dart';

class AppTheme {
  // --- SZÍNEK (Visszafogott / Subtle Green Edition) ---

  // 1. Háttér Alap (Majdnem fekete, egy nagyon pici sötétzöld tónussal)
  static const Color backgroundBase = Color(0xFF101A16);

  // 2. Fólia (Tompa Zsálya / Szürkés-zöld)
  static const Color backgroundOverlay = Color(0xFF4A635D);

  // 3. Kiemelő Szín (Pasztell Korall)
  static const Color accentRed = Color(0xBFFA0707);

  // 4. Segédszín (Törtfehér)
  static const Color textCream = Color(0xFFF2F5F4);

  // 5. ÚJ: Sötétzöld Keret Szín (Elegáns fenyőzöld)
  static const Color borderDarkGreen = Color(0xFF1E3128);

  // --- ÜVEG ALAPOK ---

  static const Color glassBackground = Color(0xFF002012);

  // Szöveg színek
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFCFD8DC);
  static const Color textTertiary = Colors.white54;

  // --- STÍLUSOK (DEKORÁCIÓK) ---

  // Általános üveg doboz (Fehér/Áttetsző kerettel - ez a régi)
  // Általános üveg doboz
  static BoxDecoration glassDecoration({
    Color borderColor = Colors.white10,
    double opacity = 0.5,
    double borderWidth = 5.0, // <--- ITT: Ez az alapértelmezett vastagság (pl. 2.0)
  }) {
    return BoxDecoration(
      color: glassBackground.withOpacity(opacity),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
          color: borderColor,
          width: borderWidth // <--- Itt használjuk fel a fenti értéket
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // ÚJ: Zöld Keretes Üveg Doboz (Ha ezt a keretszínt akarod használni a kártyákon)
  static BoxDecoration greenGlassDecoration({
    double opacity = 0.5,
  }) {
    return BoxDecoration(
      color: glassBackground.withOpacity(opacity),
      borderRadius: BorderRadius.circular(25),
      // Itt használjuk az új sötétzöld keretet
      border: Border.all(color: borderDarkGreen, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // Az "Extrás" Óra stílusa (Pasztell piros keret + Ragyogás)
  static BoxDecoration glowingRedDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.6),

      borderRadius: BorderRadius.circular(35),

      border: Border.all(
        color: Colors.white.withOpacity(0.7),
        width: 1.5,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.15),
          blurRadius: 30,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: glassBackground.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}