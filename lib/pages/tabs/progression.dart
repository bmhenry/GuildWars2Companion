import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guildwars2_companion/blocs/achievement/bloc.dart';
import 'package:guildwars2_companion/pages/progression/achievement_categories.dart';
import 'package:guildwars2_companion/pages/progression/daily_categories.dart';
import 'package:guildwars2_companion/pages/progression/masteries.dart';
import 'package:guildwars2_companion/utils/guild_wars_icons.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/error.dart';
import 'package:guildwars2_companion/widgets/full_button.dart';

class ProgressionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.orange),
      child: Scaffold(
        appBar: CompanionAppBar(
          title: 'Progression',
          color: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is ErrorAchievementsState) {
              return Center(
                child: CompanionError(
                  title: 'the progression',
                  onTryAgain: () =>
                    BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                      includeProgress: state.includesProgress
                    )),
                ),
              );
            }

            if (state is LoadedAchievementsState) {
              return RefreshIndicator(
                backgroundColor: Theme.of(context).accentColor,
                color: Colors.white,
                onRefresh: () async {
                  BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                    includeProgress: state.includesProgress
                  ));
                  await Future.delayed(Duration(milliseconds: 200), () {});
                },
                child: _buildButtonList(context),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonList(BuildContext context) {
    return ListView(
      children: <Widget>[
        CompanionFullButton(
          color: Colors.orange,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AchievementCategoriesPage()
          )),
          title: 'Achievements',
          leading: Icon(
            GuildWarsIcons.achievement,
            size: 42.0,
            color: Colors.white,
          ),
        ),
        CompanionFullButton(
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DailyCategoriesPage()
          )),
          title: 'Dailies',
          leading: Icon(
            GuildWarsIcons.daily,
            size: 42.0,
            color: Colors.white,
          ),
        ),
        CompanionFullButton(
          color: Colors.red,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MasteriesPage()
          )),
          title: 'Masteries',
          leading: Icon(
            GuildWarsIcons.mastery,
            size: 42.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
