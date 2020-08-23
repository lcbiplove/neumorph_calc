import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class GridButton extends StatefulWidget {
  final List<List<GridButtonItem>> items;

  final ValueChanged<dynamic> onPressed;

  final bool hideSurroundingBorder;

  final bool enabled;
  final bool isDarkTheme;

  GridButton({
    Key key,
    @required this.items,
    @required this.onPressed,
    this.hideSurroundingBorder = true,
    this.enabled = true,
    this.isDarkTheme,
  });

  @override
  _GridButtonState createState() => _GridButtonState();
}

class _GridButtonState extends State<GridButton> {
  Widget _getIconOrText(GridButtonItem item) {
    if (item.title == 'B') {
      return Icon(
        Icons.backspace,
        color: widget.isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
      );
    } else if (item.title == 'D') {
      return Icon(
        Icons.brightness_2,
        color: widget.isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
      );
    } else if (item.title == 'H') {
      return Icon(
        Icons.history,
        color: widget.isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
      );
    } else if (item.title == 'CH') {
      return Icon(
        Icons.keyboard,
        color: widget.isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
      );
    }

    return AutoSizeText(
      item.title,
      style: item.textStyle,
    );
  }

  Widget _getButton(int row, int col) {
    GridButtonItem item = widget.items[col][row];
    return Expanded(
      flex: item.flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: item.title == ''
            ? Container()
            : NeumorphicContainer(
                isDarkTheme: widget.isDarkTheme,
                key: item.key,
                color: item.color,
                onPressed: (widget.enabled == true)
                    ? () {
                        widget.onPressed(
                            item.value != null ? item.value : item.title);
                      }
                    : null,
                child: Center(
                  child: _getIconOrText(item),
                ),
              ),
      ),
    );
  }

  List<Widget> _getRows(int col) {
    List<Widget> list = List(widget.items[col].length);
    for (int i = 0; i < list.length; i++) {
      list[i] = _getButton(i, col);
    }
    return list;
  }

  List<Widget> _getCols() {
    List<Widget> list = List(widget.items.length);
    for (int i = 0; i < list.length; i++) {
      list[i] = Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _getRows(i),
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: _getCols(),
      ),
    );
  }
}

class GridButtonItem {
  final Key key;

  final Color color;

  final String title;

  final TextStyle textStyle;

  final int flex;

  final dynamic value;

  const GridButtonItem({
    this.key,
    this.title,
    this.color,
    this.textStyle,
    this.value,
    this.flex = 1,
  });
}

class NeumorphicContainer extends StatefulWidget {
  final Widget child;
  final double bevel;
  final Offset blurOffset;
  final Color color;
  final Function onPressed;
  final bool isDarkTheme;

  NeumorphicContainer({
    Key key,
    this.child,
    this.bevel = 4.0,
    this.color,
    this.onPressed,
    this.isDarkTheme = true,
  })  : this.blurOffset = Offset(bevel / 2, bevel / 2),
        super(key: key);

  @override
  _NeumorphicContainerState createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
    widget.onPressed();
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: Neumorphic(
        style: NeumorphicStyle(
          color: widget.color,
          depth: _isPressed
              ? (widget.isDarkTheme ? -2 : -4)
              : (widget.isDarkTheme ? 2 : 4),
          shadowLightColor:
              widget.isDarkTheme ? Colors.grey.shade600 : Colors.white,
          shadowDarkColor:
              widget.isDarkTheme ? Colors.black : Colors.grey.shade400,
          shadowLightColorEmboss:
              widget.isDarkTheme ? Colors.grey.shade600 : Colors.white,
          shadowDarkColorEmboss:
              widget.isDarkTheme ? Colors.black : Colors.grey.shade400,
        ),
        child: widget.child,
      ),
    );
  }
}
