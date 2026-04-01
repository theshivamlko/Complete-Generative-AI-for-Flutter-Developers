import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/anime_filter_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MakeMeAnimeApp());
}

class MakeMeAnimeApp extends StatelessWidget {
  const MakeMeAnimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make Me Anime',
      theme: AppTheme.darkTheme,
      home: const AnimeFilterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
