import 'package:flutter/material.dart';

class AppTheme {
  // --- SZÍNPALETTA (Zöld árnyalatok + Egy Piros) ---

  // 1. Alap Háttér (A legsötétebb méregzöld - fekete helyett)
  static const Color backgroundBase = Color(0xFF02231C);

  // 2. Fólia (Zsálya zöld - ez világosít a háttérképen)
  static const Color backgroundOverlay = Color(0xFF388E3C);

  // 3. Üveg "Sötétség" (Sötét fenyőzöld - a dobozok háttere fekete helyett)
  static const Color glassBackground = Color(0xFF001510);

  // 4. Kiemelő Piros (Telített, nemzeti piros)
  static const Color accentRed = Color(0xFFD32F2F);

  // --- SZÖVEG SZÍNEK ---
  static const Color textPrimary = Colors.white;       // Hófehér
  static const Color textSecondary = Color(0xFFA5D6A7); // Halványzöld (fehér helyett, ahol kevésbé fontos)
  static const Color textTertiary = Color(0xFF66BB6A);  // Középzöld

  // --- STÍLUSOK ---

  // Általános üveg doboz (Lista elemek, gombok háttere)
  static BoxDecoration glassDecoration({
    Color borderColor = Colors.white12, // Nagyon halvány keret
    double opacity = 0.6, // Kicsit erősebb fedés, hogy a zöld látszódjon
  }) {
    return BoxDecoration(
      // Fekete helyett a sötét fenyőzöldet használjuk
      color: glassBackground.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),

      border: Border.all(
          color: borderColor,
          width: 1
      ),

      boxShadow: [
        BoxShadow(
          // Fekete árnyék helyett mélyzöld árnyék!
          color: const Color(0xFF000F05).withOpacity(0.5),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // Az Óra "Extrás" doboza
  static BoxDecoration glowingRedDecoration() {
    return BoxDecoration(
      // A belseje sötét fenyőzöld (nem fekete)
      color: glassBackground.withOpacity(0.7),

      borderRadius: BorderRadius.circular(35),

      // Piros keret
      border: Border.all(
        color: accentRed.withOpacity(0.8),
        width: 2.0,
      ),

      // Piros + Mélyzöld ragyogás
      boxShadow: [
        // Külső piros fény
        BoxShadow(
          color: accentRed.withOpacity(0.2),
          blurRadius: 30,
          spreadRadius: 2,
        ),
        // Belső mélység (sötétzöld árnyék)
        BoxShadow(
          color: const Color(0xFF000F05).withOpacity(0.6),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}