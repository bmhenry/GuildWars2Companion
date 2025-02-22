import 'package:flutter/material.dart';
import 'package:guildwars2_companion/core/widgets/accent.dart';
import 'package:guildwars2_companion/core/widgets/appbar.dart';
import 'package:guildwars2_companion/features/event/widgets/notification_list.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CompanionAccent(
      lightColor: Colors.blue,
      child: Scaffold(
        appBar: CompanionAppBar(
          title: 'Scheduled notifications',
          color: Colors.blue,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                EventNotificationList(),
              ],
            ),
          ),
        )
      ),
    );
  }
}