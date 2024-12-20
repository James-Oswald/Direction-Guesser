import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

enum Rank { first, second, third, other }

final NumberFormat formatter = NumberFormat.decimalPatternDigits(
  locale: 'en_us',
  decimalDigits: 0,
);

class LeaderboardEntryPill extends StatelessWidget {
  const LeaderboardEntryPill(
      {required this.username,
      required this.score,
      required this.rank,
      required this.deg_off})
      : super();

  final String username;
  final int score;
  final Rank rank;
  final String deg_off;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Shimmer.fromColors(
          baseColor: switch (rank) {
            Rank.first => Color(0xFFC49812),
            Rank.second => Color(0xFF757677),
            Rank.third => Color(0xFF80683D),
            Rank.other => Theme.of(context).colorScheme.primary,
          },
          highlightColor: switch (rank) {
            Rank.first => Color(0xFFE8D38B),
            Rank.second => Color(0xFFA6A6A6),
            Rank.third => Color(0xFF988468),
            Rank.other => Theme.of(context).colorScheme.primary
          },
          child: Container(
              decoration: BoxDecoration(
                  color: switch (rank) {
                    Rank.first => Color(0xFFC49812),
                    Rank.second => Color(0xFF757677),
                    Rank.third => Color(0xFF80683D),
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
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            //TODO: change text color based on rank
                            child: Text(username[0].toUpperCase(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary))),
                        SizedBox(width: 16),
                        Text(
                          username,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ]),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            formatter.format(score),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ))
                    ],
                  )))),
      Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100.0)),
          child: Padding(
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        // TODO: change text color based on rank
                        child: Text(username[0].toUpperCase(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary))),
                    SizedBox(width: 16),
                    Text(
                      username,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ]),
                  Column(children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          formatter.format(score),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary),
                        )),
                    Text(
                      deg_off+" off" ?? "XX.XX° off",
                      style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ])
                ],
              )))
    ]);
  }
}
