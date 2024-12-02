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
                  // TODO: this should all be queried from the backend
                  children: const [
                    LeaderboardEntryPill(
                        profilePicture: NetworkImage(
                            "https://cdn.discordapp.com/avatars/218424322560229376/58a40f5e74e76937ffc92d9c36717227.webp?size=128"),
                        username: "ishtyaq",
                        score: 90208,
                        rank: Rank.first),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(
                        profilePicture: NetworkImage(
                            "https://cdn.discordapp.com/avatars/200476693691891712/0c8670c60270820ce1ed7756ddbf46c7.webp?size=128"),
                        username: "link_",
                        score: 89962,
                        rank: Rank.second),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(
                        profilePicture: NetworkImage(
                            "https://cdn.discordapp.com/avatars/351160618625007617/615e31688ed3c111e24027e41bc8dae1.webp?size=128"),
                        username: "shariemakesart",
                        score: 67863,
                        rank: Rank.third),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(
                        profilePicture: NetworkImage(
                            "https://cdn.discordapp.com/avatars/915982311135248406/1e910bdeb207a71edf4068885dfb8780.webp?size=128"),
                        username: "vomit_chan",
                        score: 14137,
                        rank: Rank.other),
                    SizedBox(height: 16),
                    LeaderboardEntryPill(
                        profilePicture: NetworkImage(
                            "https://cdn.discordapp.com/avatars/274354935036903424/14d6f3b6346da46b18ca5b0b1c46141c.webp?size=128"),
                        username: "ReturnToLean4",
                        score: 2753,
                        rank: Rank.other)
                  ],
                ))));
  }
}
