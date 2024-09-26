import 'package:buz_tracker/UI/Expense/ExpenseScreen.dart';
import 'package:buz_tracker/UI/Home/HomeScreen.dart';
import 'package:buz_tracker/UI/Project/ProjectScreen.dart';
import 'package:buz_tracker/UI/Settings/SettingScreen.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:flutter_svg/svg.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomeScreen(),
    ExpenseListScreen(),
    ProjectListScreen(),
    SettingScreen()
  ];

  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
          text: "BuzTracker",
          size: 18,
          wt: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/svgs/home.svg",
              color: Colors.black,
              height: 24,
              width: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/svgs/expense.svg",
              color: Colors.black,
              height: 24,
              width: 24,
            ),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/svgs/project.svg",
              color: Colors.black,
              height: 24,
              width: 24,
            ),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/svgs/settings.svg",
              color: Colors.black,
              height: 24,
              width: 24,
            ),
            label: 'Settings',
          ),
        ],
        selectedItemColor: primaryDarkColor,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
