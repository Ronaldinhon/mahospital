import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:quiver/iterables.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class ImagingTab extends StatefulWidget {
  @override
  _ImagingTabState createState() => _ImagingTabState();
}

class _ImagingTabState extends State<ImagingTab> {
  List<String> lll = [
    'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
    'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
    'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
  ];
  int activeIndex = 0;

  Card createImageList(int i, String link) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        child: Container(
            //     // height: 300,
            // width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                      height: 250,
                      // viewportFraction: 1.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (index, reason) {
                        setState(() => activeIndex = index);
                      }),
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    return Container(
                        child: Image.network(lll[0], fit: BoxFit.cover));
                  },
                  itemCount: 3,
                ),
                SizedBox(height: 13),
                buildIndicator(),
              ],
            )
            // Image.network(
            //   link,
            // ),
            ),
        onTap: () async {
          await showGeneralDialog(
              context: context,
              pageBuilder: (_, __, ___) => ImageDialog(i, link, lll));
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Rara Ra-a-aa Roma Romama Gaga ulala I want your romance'),
      )
    ]));
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        count: 3,
        activeIndex: activeIndex,
      );

  @override
  Widget build(BuildContext context) {
    return
        // SingleChildScrollView(
        //   child:
        ListView(
            padding: EdgeInsets.only(left: 8, right: 8),
            shrinkWrap: true,
            // animationDuration: const Duration(seconds: 1),
            children: enumerate(lll)
                .map<Card>((indexedValue) =>
                    createImageList(indexedValue.index, indexedValue.value))
                .toList())
        // )
        ;
  }
}

class ImageDialog extends StatelessWidget {
  final int page;
  final String link;
  final List<String> lll;

  final CarouselController _controller = CarouselController();
  ImageDialog(this.page, this.link, this.lll);
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 400),
        () => _controller.animateToPage(page));
    final double height = MediaQuery.of(context).size.height;
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
          height: height,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: false),
      items: lll
          .map((item) => SizedBox.expand(
                    child: InteractiveViewer(
                      constrained: true,
                      maxScale: 5.0,
                      minScale: 0.5,
                      // boundaryMargin: EdgeInsets.all(5.0),
                      child: Image.network(
                        item,
                      ),
                    ),
                  )
              // Container(
              //       child: Center(
              //           child: Image.network(
              //         item,
              //         fit: BoxFit.cover,
              //         height: height,
              //       )),
              //     )
              )
          .toList(),
    );
  }
}
