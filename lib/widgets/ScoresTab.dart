import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Providers/RoomProvider.dart';
class ScoresTab extends StatelessWidget {
  const ScoresTab({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, model, child) => ListView.builder(
      shrinkWrap: true,
      itemCount: model.players.length,
      itemBuilder: (BuildContext context, int index) {
        Player player = model.players[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
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
                          '${index + 1}.',
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                          player.user.username,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${player.score}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
    );
  }
}