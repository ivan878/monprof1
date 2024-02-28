import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PieceJointe extends StatefulWidget {
  final String imagepj;
  const PieceJointe({
    Key? key,
    required this.imagepj,
  }) : super(key: key);

  @override
  State<PieceJointe> createState() => _PieceJointeState();
}

class _PieceJointeState extends State<PieceJointe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        elevation: 0,
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(widget.imagepj),
          )),
    );
  }
}
