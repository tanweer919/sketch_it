import 'package:flutter/material.dart';
import 'ChatsTab.dart';
import 'ScoresTab.dart';
class ChatsAndScoresWidget extends StatefulWidget {
  const ChatsAndScoresWidget({ Key key }) : super(key: key);

  @override
  _ChatsAndScoresWidgetState createState() => _ChatsAndScoresWidgetState();
}

class _ChatsAndScoresWidgetState extends State<ChatsAndScoresWidget> with TickerProviderStateMixin {
  TabController _tabController;
  List<Tab> _tabList = [];

  @override
  void initState() {
    //Add all the tabs to the tab list
    _tabList.addAll([
      new Tab(
        text: 'Chats',
      ),
      new Tab(
        text: 'Scoreboard',
      )
    ]);

    //Assign _tabcontroller
    _tabController = new TabController(vsync: this, length: _tabList.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Color(0x44000000), width: 0.7))),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: new TabBar(
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 17,
                ),
                controller: _tabController,
                tabs: _tabList,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [ChatsTab(), ScoresTab()],
              ),
            )
          ],
        ),
      ),
    );
  }
}