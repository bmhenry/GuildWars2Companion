import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/core/widgets/info_card.dart';
import 'package:guildwars2_companion/features/pvp/models/season.dart';
import 'package:guildwars2_companion/features/pvp/models/standing.dart';
import 'package:guildwars2_companion/core/widgets/accent.dart';
import 'package:guildwars2_companion/core/widgets/cached_image.dart';
import 'package:guildwars2_companion/core/widgets/header.dart';
import 'package:guildwars2_companion/core/widgets/list_view.dart';
import 'package:guildwars2_companion/features/pvp/widgets/pvp_season_rank.dart';
import 'package:intl/intl.dart';

class SeasonPage extends StatelessWidget {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final PvpSeasonRank rank;
  final PvpStanding standing;

  SeasonPage({
    @required this.rank,
    @required this.standing
  });

  @override
  Widget build(BuildContext context) {
    return CompanionAccent(
      lightColor: Colors.blueGrey,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            CompanionHeader(
              color: Colors.blueGrey,
              includeBack: true,
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: standing.seasonId,
                    child: PvpSeasonRankBadge(
                      rank: rank,
                      standing: standing,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      standing.season.name,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Text(
                    _dateFormat.format(DateTime.parse(standing.season.start)) +
                          (standing.season.end != null ? ' - ' + _dateFormat.format(DateTime.parse(standing.season.end)) : ''),
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Colors.white
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: CompanionListView(
                children: <Widget>[
                  CompanionInfoCard(
                    title: 'Rewards',
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        runSpacing: 16.0,
                        children: standing.season.divisions
                          .map((d) => Container(
                            width: 110,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    d.name,
                                    style: Theme.of(context).textTheme.bodyText1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight: 38.0,
                                    maxWidth: 80.0,
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    runSpacing: 2.0,
                                    children: d.tiers
                                      .map((t) => Container(
                                        height: 18.0,
                                        width: 18.0,
                                        margin: EdgeInsets.symmetric(horizontal: 2.0),
                                        child: 
                                          standing.current.division > standing.season.divisions.indexOf(d) ||
                                          (standing.current.division == standing.season.divisions.indexOf(d) &&
                                          standing.current.tier >= d.tiers.indexOf(t))
                                          ? Icon(
                                          FontAwesomeIcons.check,
                                          size: 10,
                                          color: Colors.white,
                                        ) : null,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(9.0),
                                          color: Colors.black,
                                        ),
                                      ))
                                      .toList(),
                                  ),
                                ),
                                CompanionCachedImage(
                                  height: 72.0,
                                  imageUrl: d.smallIcon,
                                  color: Colors.black,
                                  iconSize: 28,
                                  fit: null,
                                ),
                              ],
                            ),
                          ))
                          .toList()
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}