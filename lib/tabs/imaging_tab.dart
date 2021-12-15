import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class ImagingTab extends StatefulWidget {
  @override
  _ImagingTabState createState() => _ImagingTabState();
}

class _ImagingTabState extends State<ImagingTab> {
  ExpansionPanel createImageList() {
    // drugs.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    // drug.where((d) => d['active']).forEach((d) {
    return ExpansionPanel(
        isExpanded: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
              ),
            ),
            onTap: () async {
              await showGeneralDialog(
                  context: context, pageBuilder: (_, __, ___) => ImageDialog());
            },
          );
        },
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text('Rara Ra-a-aa Roma Romama Gaga ulala I want your romance'),
        ));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        animationDuration: const Duration(seconds: 1),
        children: [
          createImageList(),
          createImageList(),
          createImageList(),
        ],
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: InteractiveViewer(
        constrained: true,
        maxScale: 5.0,
        minScale: 0.5,
        // boundaryMargin: EdgeInsets.all(5.0),
        child: Image.network(
          'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
        ),
      ),
    );
    
  }
}