import 'package:direction_guesser/widgets/leaderboard_entry_pill.dart';
import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final List<MapEntry<String, List<dynamic>>> scores;
  const LeaderboardCard(this.scores) : super();
  @override
  Widget build(BuildContext context) {
    const double interiorPadding = 24;
    return Card(
        elevation: 6,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
                padding: EdgeInsets.all(interiorPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // TODO: this should all be queried from the backend
                  children: [
                    LeaderboardEntryPill(
                        username: scores[0].key ?? "---",
                        score: scores[0].value[0] ?? "---",
                        rank: Rank.first,
                        deg_off: scores[0].value[1].toStringAsFixed(2) ?? "---" + "° off",),
                        
                    const SizedBox(height: interiorPadding),
                    if(scores.length > 1)
                      LeaderboardEntryPill(
                          username: scores[1].key ?? "---",
                          score: scores[1].value[0] ?? "---",
                          rank: Rank.second,
                          deg_off: scores[1].value[1].toStringAsFixed(2) ?? "---" + "° off",),
                    const SizedBox(height: interiorPadding),
                    if (scores.length > 2)
                      LeaderboardEntryPill(
                          username: scores[2].key ?? "---",
                          score: scores[2].value[0] ?? "---",
                          rank: Rank.third,
                          deg_off: scores[2].value[1].toStringAsFixed(2) ?? "---" + "° off",),
                    const SizedBox(height: interiorPadding),
                    if (scores.length > 3)
                      for (int i = 3; i < scores.length; i++)
                        LeaderboardEntryPill(
                            username: scores[i].key ?? "---",
                            score: scores[i].value[0] ?? "---",
                            rank: Rank.other,
                            deg_off: scores[i].value[1].toStringAsFixed(2) ?? "---" + "° off",)
                  ],
                ))));
  }
}
