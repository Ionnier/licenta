import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TimelineElement extends StatefulWidget {
  final Function? onProfileClick;

  const TimelineElement({super.key, required this.onProfileClick});

  @override
  State<TimelineElement> createState() => _TimelineElementState();
}

class _TimelineElementState extends State<TimelineElement> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          InkWell(
            enableFeedback: widget.onProfileClick != null,
            onTap: () {
              if (widget.onProfileClick != null) {
                widget.onProfileClick!();
              }
            },
            child: Row(
              children: [
                CachedNetworkImage(
                  width: 32,
                  height: 32,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: 'https://picsum.photos/250?image=9',
                ),
                const SizedBox(
                  width: 8.0,
                ),
                const Text("Name"),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Row(children: const [
            Text("Activity"),
            Spacer(),
          ]),
          const SizedBox(height: 4.0),
          Row(children: const [
            Text("Duration"),
            Spacer(),
          ]),
        ],
      ),
    );
  }
}
