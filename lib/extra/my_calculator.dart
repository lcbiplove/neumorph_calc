import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:calculator/extra/calculator_grid_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart' as intl;
import 'package:calculator/extra/calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signature for callbacks that report that the [MyCalculator] value has changed.
typedef CalcChanged = void Function(
    String key, double value, String expression);

class MyCalculator extends StatefulWidget {
  /// Whether to show surrounding borders.
  final bool hideSurroundingBorder;

  /// Whether to show expression area.
  final bool hideExpression;

  /// The value currently displayed on this calculator.
  final double value;

  /// Called when the button is tapped or the value is changed.
  final CalcChanged onChanged;

  /// The [NumberFormat] used for display
  final intl.NumberFormat numberFormat;

  /// Maximum number of digits on display.
  final int maximumDigits;
  final bool isDarkTheme;

  final Function onThemeClicked;

  MyCalculator({
    Key key,
    this.hideExpression = false,
    this.value = 0,
    this.onChanged,
    this.numberFormat,
    this.maximumDigits = 10,
    this.hideSurroundingBorder = false,
    this.isDarkTheme = true,
    this.onThemeClicked,
  }) : super(key: key);

  @override
  _MyCalculatorState createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator>
    with SingleTickerProviderStateMixin {
  String _displayValue;
  String _expression = "";
  String _acLabel = "AC";
  Calculator _calc;
  bool isHistoryHidden = true;
  var prefs;
  List<String> history = [];
  final List<String> _nums = new List(10);

  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initiatePrefs();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: Offset(-1.5, 0.0),
    ).animate(_controller);
  }

  void _initiatePrefs() async {
    prefs = await SharedPreferences.getInstance();
    history = prefs.getStringList('history') ?? history;
  }

  _historyClicked() {
    isHistoryHidden = !isHistoryHidden;
    if (isHistoryHidden) {
      _controller.reverse();
    } else {
      _controller.forward();
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
    setState(() {});
  }

  void _changeHistory(expressionValue, displayValue) {
    if (expressionValue.toString().indexOf('?') == -1 &&
        expressionValue != displayValue) {
      if (history == null) {
        history = ['$expressionValue = $displayValue'];
        prefs.setStringList('history', history);
      } else {
        if (history.length == 25) {
          history.removeAt(0);
        }
        history.add('$expressionValue = $displayValue');
        prefs.setStringList('history', history);
      }
      setState(() {});
    }
  }

  void _clearHistory() {
    prefs.setStringList('history', null);
    history = [];
    setState(() {});
  }

  void _historyContentClicked(history) {
    String val = (history.split('=')[1]).trim();
    if (val.indexOf('-') != -1) {
      _calc.setOperator('-');
      val = val.substring(1);
      if (val.indexOf('.') != -1) {
        _calc.addDigit(int.parse(val.split('.')[0].trim()));
        _calc.addPoint();
        _calc.addDigit(int.parse(val.split('.')[1].trim()));
      } else {
        _calc.addDigit(int.parse(val));
      }
    } else if (val.indexOf('.') != -1) {
      _calc.addDigit(int.parse(val.split('.')[0].trim()));
      _calc.addPoint();
      List digAfterPoint = (val.split('.')[1]).split('');
      for (String digit in digAfterPoint) {
        _calc.addDigit(int.parse(digit.trim()));
      }
    } else {
      _calc.addDigit(int.parse(val));
    }

    setState(() {
      _displayValue = _calc.displayString;
      _expression = _calc.expression;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(children: <Widget>[
          Expanded(
            child: _getDisplay(),
            flex: 2,
          ),
          Expanded(
            child: _getButtons(),
            flex: 5,
          ),
        ]),
        Column(
          children: <Widget>[
            Expanded(
              child: Container(),
              flex: 2,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 0,
                          color: widget.isDarkTheme
                              ? Color(0xff212121)
                              : Color(0xffededed),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: ScrollConfiguration(
                                behavior: ScrollBehavior(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: _scrollController,
                                  itemCount: history.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: FlatButton(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 30, horizontal: 15),
                                        onPressed: () {
                                          _historyContentClicked(
                                              history[index]);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                history[index].split('=')[0],
                                                style: TextStyle(
                                                  color: widget.isDarkTheme
                                                      ? Colors.white70
                                                      : Colors.black87,
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '= ${history[index].split('=')[1]}',
                                              style: TextStyle(
                                                color: widget.isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 22,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey,
                            ),
                            FlatButton(
                              padding: EdgeInsets.all(14),
                              onPressed: () {
                                _clearHistory();
                              },
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: widget.isDarkTheme
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              flex: 3,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_calc != null) return;
    if (widget.numberFormat == null) {
      var myLocale = Localizations.localeOf(context);
      var nf = intl.NumberFormat.decimalPattern(myLocale.toLanguageTag())
        ..maximumFractionDigits = 6;
      _calc = Calculator.numberFormat(nf, widget.maximumDigits);
    } else {
      _calc =
          Calculator.numberFormat(widget.numberFormat, widget.maximumDigits);
    }
    for (var i = 0; i < 10; i++) {
      _nums[i] = _calc.numberFormat.format(i);
    }
    _calc.setValue(widget.value);
    _displayValue = _calc.displayString;
  }

  Widget _getButtons() {
    return GridButton(
      isDarkTheme: widget.isDarkTheme,
      onPressed: (dynamic val) {
        var acLabel;
        switch (val) {
          case "D":
            widget.onThemeClicked();
            break;
          case "CH":
          case "H":
            _historyClicked();
            break;
          case "B":
            _calc.removeDigit();
            break;
          case "±":
            _calc.toggleSign();
            break;
          case "+":
          case "-":
          case "×":
          case "÷":
            _calc.setOperator(val);
            break;
          case "=":
            _calc.operate();
            _changeHistory(_calc.expression, _calc.displayString);
            acLabel = "AC";
            break;
          case "AC":
            _calc.allClear();
            break;
          case "C":
            _calc.clear();
            acLabel = "AC";
            break;
          default:
            if (val == _calc.numberFormat.symbols.DECIMAL_SEP) {
              _calc.addPoint();
              acLabel = "C";
            }
            if (val == _calc.numberFormat.symbols.PERCENT) {
              _calc.setPercent();
            }
            if (_nums.contains(val)) {
              _calc.addDigit(_nums.indexOf(val));
            }
            acLabel = "C";
        }
        if (widget.onChanged != null) {
          widget.onChanged(val, _calc.displayValue, _calc.expression);
        }
        setState(() {
          _displayValue = _calc.displayString;
          _expression = _calc.expression;
          _acLabel = acLabel ?? _acLabel;
        });
      },
      items: _getItems(),
    );
  }

  Widget _getDisplay() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(left: 18, right: 18),
                  child: AutoSizeText(
                    _displayValue,
                    style: TextStyle(
                      fontSize: 40,
                      color: widget.isDarkTheme
                          ? Color(0xffeeeeee)
                          : Colors.black87,
                    ),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: !widget.hideExpression,
            child: Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression,
                      style: TextStyle(
                          color: widget.isDarkTheme
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 18),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<List<GridButtonItem>> _getItems() {
    return [
      [isHistoryHidden ? "H" : "CH", "", "", "B"],
      ["D", _acLabel, _calc.numberFormat.symbols.PERCENT, "÷"],
      [_nums[7], _nums[8], _nums[9], "×"],
      [_nums[4], _nums[5], _nums[6], "-"],
      [_nums[1], _nums[2], _nums[3], "+"],
      [_calc.numberFormat.symbols.DECIMAL_SEP, _nums[0], "±", "="],
    ].map((items) {
      return items.map((title) {
        Color color =
            widget.isDarkTheme ? Color(0xff212121) : Color(0xffededed);
        TextStyle style = TextStyle(
            fontSize: 27,
            color: widget.isDarkTheme ? Color(0xffeeeeee) : Colors.black87);
        int flex = 1;
        if (title == 'H' || title == 'CH' || title == 'B') {}

        return GridButtonItem(
          title: title,
          flex: flex,
          color: color,
          textStyle: style,
        );
      }).toList();
    }).toList();
  }
}
