import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'settings.dart';
import 'ui/home_page.dart';
import 'ui/theme.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Settings.load();
  runApp(NetMaskApp(settings: settings));
}

class NetMaskApp extends StatelessWidget {
  const NetMaskApp({super.key, required this.settings});
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final dark = settings.dark;
          SystemChrome.setSystemUIOverlayStyle(
              dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
          return MaterialApp(
            title: 'NetMask',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(dark),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
