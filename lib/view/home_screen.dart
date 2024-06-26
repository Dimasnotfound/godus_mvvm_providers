import 'package:flutter/material.dart';
import 'package:godus/view/rekap_screen.dart';
import 'package:godus/view/tracking_screen.dart';
import 'package:godus/view/akun_screen.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// import 'package:godus/utils/routes/routes_names.dart';
// import 'package:godus/viewModel/user_view_model.dart';
// import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(initialPage: 1);
  final _controller = NotchBottomBarController(index: 1);
  int maxCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get bottomBarPages => [
        const RekapScreen(),
        const TrackingScreen(),
        const AkunScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    // final preferences = Provider.of<UserViewModel>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(33, 92, 168, 1),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.asset(
                'assets/goatjumping.png',
                width: screenWidth * 0.0485314,
                height: screenHeight * 0.036894,
              ),
            ),
            const Expanded(
              child: Text(
                'GO-DUS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28.0,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          bottomBarPages.length,
          (index) => bottomBarPages[index],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              color: const Color.fromRGBO(33, 92, 168, 1),
              showLabel: false,
              shadowElevation: 5,
              kBottomRadius: 28.0,
              notchColor: const Color.fromRGBO(33, 92, 168, 1),
              removeMargins: false,
              bottomBarWidth: 500,
              showShadow: false,
              durationInMilliSeconds: 300,
              elevation: 1,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.description,
                    color: Colors.white,
                  ),
                  activeItem: Icon(
                    Icons.description,
                    color: Colors.white,
                  ),
                  itemLabel: 'Rekap',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  activeItem: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  itemLabel: 'Tracking',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  activeItem: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  itemLabel: 'Akun',
                ),
              ],
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              kIconSize: 24.0,
            )
          : null,
    );
  }
}


