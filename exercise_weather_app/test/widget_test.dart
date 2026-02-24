import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exercise_weather_app/main.dart';

void main() {
  testWidgets('Weather App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherChatApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
