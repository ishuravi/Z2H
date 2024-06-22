import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zero2hero/screens/Friends.dart';
import 'DrawerPage.dart';
import 'first.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final PersistentTabController _controller =
  PersistentTabController(initialIndex: 0);
  final GlobalKey<NavigatorState> _FirstPageKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _FriendsKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _DrawerPageKey = GlobalKey<NavigatorState>();
  int _currentIndex = 0;

  List<Widget> _navScreens() {
    return [
      Navigator(
        key: _FirstPageKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => FirstPage(onTabChanged: _handleTabChanged),
          );
        },
      ),
      Navigator(
        key: _FriendsKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => Friends(onTabChanged: _handleTabChanged),
          );
        },
      ),
      Navigator(
        key: _DrawerPageKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => DrawerPage(onTabChanged: _handleTabChanged),
          );
        },
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary:Color(0xFF007dfe),
        inactiveColorPrimary: Color(0xFF007dfe),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.group_add),
        title: ("Friends"),
        activeColorPrimary: Color(0xFF007dfe),
        inactiveColorPrimary:Color(0xFF007dfe),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.menu_outlined),
        title: ("Menu"),
        activeColorPrimary: Color(0xFF007dfe),
        inactiveColorPrimary: Color(0xFF007dfe),
      ),
    ];
  }

  void _handleTabChanged(int index) {
    setState(() {
      _controller.index = index;
      _currentIndex = index;
    });
  }
  void _resetNavigationStack(int index) {
    switch (index) {
      case 0:
        _FirstPageKey.currentState?.popUntil((route) => route.isFirst);
        break;
      case 1:
        _FriendsKey.currentState?.popUntil((route) => route.isFirst);
        break;
      case 2:
        _DrawerPageKey.currentState?.popUntil((route) => route.isFirst);
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _navScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Color(0xFFDCFFFF),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          hideNavigationBarWhenKeyboardShows: true,
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          popAllScreensOnTapOfSelectedTab: true,
          navBarStyle: NavBarStyle.style1,
          onItemSelected: (index) {
            _resetNavigationStack(index);
            _controller.jumpToTab(index);
            setState(() {
              _currentIndex = index;
            });
          },

        ),
      ),
    );
  }
}
