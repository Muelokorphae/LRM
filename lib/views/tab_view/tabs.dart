import 'package:flutter/material.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/shop/shop_view.dart';
import 'package:lrm_app/views/tab_view/Search/search_view.dart';
import 'package:lrm_app/views/tab_view/home/home_view.dart';
import 'package:lrm_app/views/tab_view/profile/profile_view.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeView(),
          ShopView(),
          SearchView(),
          ProfileView(),
       
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
        selectedItemColor: AppColors.tabsColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}







