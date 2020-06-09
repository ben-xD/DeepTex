import 'dart:async';
import 'package:deeptex/providers/strokes_history.dart';
import 'package:deeptex/ui/screens/onboarding/widgets/onboarding.dart';
import 'package:deeptex/ui/screens/start.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> onboardingSeenFuture;

  @override
  void initState() {
    onboardingSeenFuture = isOnboardingSeen();
    super.initState();
  }

  Future<bool> isOnboardingSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove("onboardingSeen"); // For debugging
    bool onboardingSeen = prefs.getBool('onboardingSeen');
    if (onboardingSeen == null) {
      return false;
    }
    return onboardingSeen;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStrokesHistory(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder(
              future: onboardingSeenFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                    backgroundColor: Colors.blue,
                    body: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "DeepTex",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.textMeOne(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width / 10,
                        ),
                      ),
                    ),
                  );
                }
                bool onboardingSeen = snapshot.data;
                if (snapshot.hasError) {
                  onboardingSeen = true;
                }
                if (!onboardingSeen) {
                  return Onboarding();
                }
                return StartScreen();
              })),
    );
  }
}
