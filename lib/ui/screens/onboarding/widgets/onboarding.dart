import 'package:deeptex/ui/screens/start.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentPage = 0;
  final int numPages = 3;
  final PageController controller = PageController(initialPage: 0);

  void setCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void finishOnboarding() async {
    // TODO save finished
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboardingSeen', true);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => StartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3F85E2), Color(0xFF52929F)]),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkipHeader(
                finishOnboarding: finishOnboarding,
              ),
              Body(
                currentPage: currentPage,
                setCurrentPage: setCurrentPage,
                controller: controller,
              ),
              SizedBox(),
              Column(
                children: [
                  AnimatedCrossFade(
                    crossFadeState: (currentPage != numPages - 1)
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: FlatButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      color: Color(0x22FFFFFF),
                      onPressed: () {
                        setState(() {
                          currentPage += 1;
                          print(currentPage);
                          controller.animateToPage(currentPage,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.ease);
                        });
                      },
                      child: Text("Continue",
                          style: TextStyle(
                              fontSize: 18, color: Color(0xAAFFFFFF))),
                    ),
                    secondChild: FlatButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        color: Color(0x22FFFFFF),
                        onPressed: finishOnboarding,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text("Finish",
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xAAFFFFFF))),
                        )),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < numPages; i++)
                        AnimatedContainer(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          duration: Duration(milliseconds: 150),
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          width: currentPage == i ? 36.0 : 12.0,
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class SkipHeader extends StatelessWidget {
  final void Function() finishOnboarding;

  const SkipHeader({Key key, this.finishOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(8),
      child: ButtonTheme(
        minWidth: 0,
        child: FlatButton(
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: finishOnboarding,
          child: Text(
            "Skip",
            style: TextStyle(
              color: Color(0xAAFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final void Function(int page) setCurrentPage;

  Body({Key key, this.currentPage, this.setCurrentPage, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      // color: Colors.black, # for debugging
      height: MediaQuery.of(context).size.height * 0.6,
      child: PageView(
        controller: controller,
        onPageChanged: setCurrentPage,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.border_color,
                  size: 128,
                  color: Colors.white,
                ),
                SizedBox(height: 30.0),
                Text(
                  "Draw a character",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.textMeOne(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 10,
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "To find its name, code and LaTex package",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width / 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.train,
                  size: 128,
                  color: Colors.white,
                ),
                SizedBox(height: 30.0),
                Text(
                  "or train the detector...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.textMeOne(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 10,
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "to contribute to the\nopen source dataset",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width / 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_money,
                  size: 128,
                  color: Colors.white,
                ),
                SizedBox(height: 30.0),
                Text(
                  "Free forever...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.textMeOne(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 10,
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "because the code and dataset is available for free online.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width / 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
