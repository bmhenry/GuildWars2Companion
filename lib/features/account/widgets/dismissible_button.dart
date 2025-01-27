import 'package:flutter/material.dart';
import 'package:guildwars2_companion/core/widgets/button.dart';

class DismissibleButton extends StatelessWidget {
  final Key key;
  final Widget leading;
  final Widget trailing;
  final String title;
  final List<String> subtitles;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final Color color;

  DismissibleButton({
    @required this.key,
    @required this.title,
    @required this.color,
    @required this.onDismissed,
    this.onTap,
    this.subtitles,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CompanionButton(
      leading: leading,
      trailing: trailing,
      title: title,
      subtitles: subtitles,
      onTap: onTap,
      color: color,
      wrapper: (context, child) {
        return Dismissible(
          child: child,
          key: key,
          onDismissed: (_) => onDismissed(),
          background: _Background(),
          secondaryBackground: _Background(rtl: true),
        );
      },
    );
  }
}

class _Background extends StatelessWidget {
  final bool rtl;

  _Background({
    this.rtl = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Row(
        mainAxisAlignment: rtl
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
        children: <Widget>[
          if (!rtl)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          Text(
            'Delete Api Key',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0
            ),
          ),
          if (rtl)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}