import 'package:buz_tracker/UI/Home/Components/DailyView.dart';
import 'package:buz_tracker/UI/Home/Components/MonthlyView.dart';
import 'package:buz_tracker/UI/Home/Components/YearlyView.dart';
import 'package:buz_tracker/provider/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _controller;

  PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: "Daily"),
            Tab(text: "Monthly"),
            Tab(text: "Yearly"),
          ],
        ),
        Expanded(
          child: ChangeNotifierProvider<HomeProvider>(
            create: (context) => HomeProvider(),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: const [
                DailyView(),
                MonthlyView(),
                YearlyView(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
