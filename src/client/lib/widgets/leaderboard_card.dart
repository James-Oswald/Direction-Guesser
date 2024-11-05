import 'package:direction_guesser/widgets/leaderboard_entry_pill.dart';
import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard() : super();

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 6,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    LeaderboardEntryPill(username: "username", score: 69420, rank: Rank.first),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(username: "username", score: 69420, rank: Rank.second),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(username: "username", score: 69420, rank: Rank.third),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(username: "username", score: 69420, rank: Rank.other),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(username: "username", score: 69420, rank: Rank.other)
                  ],
                ))));
  }
}
