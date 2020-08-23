import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator/extra/my_calculator.dart';

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool isDarkTheme = false;
  var prefs;
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _initiateTheme();
  }

  void _initiateTheme() async {
    prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    history = prefs.getStringList('history');
  }

  void _changeTheme() async {
    isDarkTheme = !isDarkTheme;

    await prefs.setBool('isDarkTheme', isDarkTheme);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkTheme ? Color(0xff212121) : Color(0xffededed),
      body: MyCalculator(
        isDarkTheme: isDarkTheme,
        onThemeClicked: () {
          _changeTheme();
        },
      ),
    );
  }
}
