import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const HomePage(),
    const CalendarTasks(),
    const SignInPage(),
    const ChatPage(),
    // const NewTaskScreen(),
    // const CompleteTaskScreen(),
    // const CancelledTaskScreen(),
    // const ProgressTaskScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          selectedItemColor: Colors.green,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            selectedIndex = index;
            if (mounted) {
              setState(() {});
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.shekelSign), label: "Inbox"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.checkToSlot), label: "Tasks"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.circleXmark), label: "Cancelled"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.barsProgress), label: "Chatbox"),
          ]),
    );
  }
}
