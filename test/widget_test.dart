// This is a basic Flutter widget test testing the localization system.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_todo_app/generated_files/l10n/app_localizations.dart';
import 'package:islamic_todo_app/core/extensions/localization_extensions.dart';

void main() {
  testWidgets('Localization system works with English', (WidgetTester tester) async {
    // Build a test widget with English locale
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = context.l10n;
            return Scaffold(
              body: Text(l10n.appName),
            );
          },
        ),
      ),
    );

    // Verify English string is displayed
    expect(find.text('Islamic Todo'), findsOneWidget);
  });

  testWidgets('Localization system works with Arabic', (WidgetTester tester) async {
    // Build a test widget with Arabic locale
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = context.l10n;
            return Scaffold(
              body: Text(l10n.appName),
            );
          },
        ),
      ),
    );

    // Verify Arabic string is displayed
    expect(find.text('مهام إسلامية'), findsOneWidget);
  });

  testWidgets('Prayer names are localized correctly', (WidgetTester tester) async {
    // Test English prayer names
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = context.l10n;
            return Scaffold(
              body: Column(
                children: [
                  Text(l10n.fajr),
                  Text(l10n.dhuhr),
                  Text(l10n.asr),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
  });
}
