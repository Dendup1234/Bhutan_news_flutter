import 'package:flutter/material.dart';
import 'package:bhutan_news_app_flutter/features_tab.dart';
import 'package:bhutan_news_app_flutter/life_style_tab.dart';
import 'package:bhutan_news_app_flutter/opinion_tab.dart';
import 'package:bhutan_news_app_flutter/sport.dart';
import 'package:bhutan_news_app_flutter/home_tab.dart';
import 'package:bhutan_news_app_flutter/nation_tab.dart';
import 'package:bhutan_news_app_flutter/news_tab.dart';
import 'package:bhutan_news_app_flutter/editorial_tab.dart';
import 'package:bhutan_news_app_flutter/business_tab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Center(
            child: Image.asset(
              'assets/bhutan_news_logo.png', // Add your logo path here
              height: 40.0,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              alignment: Alignment.centerLeft, // Aligns TabBar to the extreme left
              child: const TabBar(
                isScrollable: true,
                indicatorColor: Colors.yellow,
                labelColor: Colors.yellow,
                unselectedLabelColor: Colors.grey,
                tabs:  [
                  Tab(text: 'Home'),
                  Tab(text: 'News'),
                  Tab(text: 'Business'),
                  Tab(text: 'Editorial'),
                  Tab(text: 'Nation'),
                  Tab(text: 'Feature'),
                  Tab(text: 'Life Style'),
                  Tab(text: 'Opinion'),
                  Tab(text: 'Sport'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            HomeTab(),
            NewsTab(),
            BusinessTab(),
            EditorialTab(),
            NationTab(),
            FeaturesTab(),
            LifeStyleTab(),
            OpinionTab(),
            SportTab(),
          ],
        ),

      ),
    );
  }
}
