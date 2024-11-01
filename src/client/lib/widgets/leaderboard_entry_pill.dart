import 'package:flutter/material.dart';

enum Rank { first, second, third, other }

class LeaderboardEntryPill extends StatelessWidget {
  const LeaderboardEntryPill(
      {required this.username,
      // required this.profilePicture,
      required this.score,
      required this.rank})
      : super();

  final String username;

  // final Image profilePicture;
  final int score;
  final Rank rank;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: switch (rank) {
              Rank.first => Color.lerp(
                  Theme.of(context).colorScheme.primary, Colors.black, 0.3),
              Rank.second => Color.lerp(
                  Theme.of(context).colorScheme.primary, Colors.black, 0.2),
              Rank.third => Color.lerp(
                  Theme.of(context).colorScheme.primary, Colors.black, 0.1),
              Rank.other => Theme.of(context).colorScheme.primary,
            },
            borderRadius: BorderRadius.circular(100.0)),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  SizedBox(width: 16),
                  Text(
                    username,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ]),
                Text(
                  "$score",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                )
              ],
            )));
  }
}
