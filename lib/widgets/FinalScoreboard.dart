import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Player.dart';
import '../commons/LargeYellowButton.dart';
import '../Providers/AppProvider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FinalScoreboard extends StatelessWidget {
  final List<Player> players;
  FinalScoreboard({@required this.players});
  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Scoreboard',
              style: TextStyle(fontSize: 40, fontFamily: 'CaveatBrush'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (BuildContext context, int index) {
                  Player player = players[index];
                  if (players.length > 3) {
                    if (index < 3) {
                      if (index == 1 || index == 2) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 65,
                                    width: 50,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          child: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            child: players[1].user.profilePicUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        players[1].user.profilePicUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        Image.asset(
                                                      'assets/images/user_placeholder.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/user_placeholder.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            child: Image.asset(
                                              'assets/images/silver_medal.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${players[1].user.username}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '(${players[1].score})',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 65,
                                    width: 50,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          child: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            child: players[0].user.profilePicUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        players[0].user.profilePicUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        Image.asset(
                                                      'assets/images/user_placeholder.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/user_placeholder.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            child: Image.asset(
                                              'assets/images/gold_medal.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${players[0].user.username}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '(${players[0].score})',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 65,
                                    width: 50,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          child: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            child: players[2].user.profilePicUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        players[2].user.profilePicUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        Image.asset(
                                                      'assets/images/user_placeholder.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/user_placeholder.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            child: Image.asset(
                                              'assets/images/bronze_medal.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${players[2].user.username}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '(${players[2].score})',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${index < 9 ? '0' : ''}${index + 1}.',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 2.0, right: 4.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(30),),
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            child: player.user.profilePicUrl != null
                                                ? CachedNetworkImage(
                                              imageUrl: player.user.profilePicUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Image.asset(
                                                'assets/images/user_placeholder.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                                : Image.asset(
                                              'assets/images/user_placeholder.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${player.user.username}${appProvider.currentUser.username == player.user.username ? '(You)' : ''}',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      '${player.score}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${index < 9 ? '0' : ''}${index + 1}.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2.0, right: 4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(30),),
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          child: player.user.profilePicUrl != null
                                              ? CachedNetworkImage(
                                            imageUrl: player.user.profilePicUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/user_placeholder.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              : Image.asset(
                                            'assets/images/user_placeholder.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${player.user.username}${appProvider.currentUser.username == player.user.username ? '(You)' : ''}',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        child: Image.asset(
                                          index == 0
                                              ? 'assets/images/gold_medal.png'
                                              : index == 1
                                                  ? 'assets/images/silver_medal.png'
                                                  : 'assets/images/bronze_medal.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    '${player.score}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          LargeButton(
            child: Text(
              'Exit Game',
              style: TextStyle(
                  fontSize: 30, color: Colors.white, fontFamily: 'CaveatBrush'),
            ),
            buttonPressed: false,
            width: MediaQuery.of(context).size.width * 0.6,
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            isPrimaryColor: false,
          )
        ],
      ),
    );
  }
}
