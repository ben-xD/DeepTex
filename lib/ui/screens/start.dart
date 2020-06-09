import 'package:deeptex/ui/screens/draw/draw.dart';
import 'package:deeptex/ui/screens/more/more.dart';
import 'package:deeptex/ui/screens/train/train.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedTabIndex = 1;

  List<Widget> _screenOptions = [TrainScreen(), DrawScreen(), MoreScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Hello"),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedTabIndex = value;
          });
        },
        currentIndex: _selectedTabIndex,
        items: const [
          BottomNavigationBarItem(
              title: const Text("Train"), icon: Icon(Icons.train)),
          BottomNavigationBarItem(
              title: const Text("Draw"), icon: Icon(Icons.border_color)),
          BottomNavigationBarItem(
              title: const Text("More"), icon: Icon(Icons.more_horiz))
        ],
      ),
      body: _screenOptions.elementAt(_selectedTabIndex),
    );
  }
}
