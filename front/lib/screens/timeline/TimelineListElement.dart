import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TimelineElement extends StatefulWidget {
  final Function? onProfileClick;
  final String name;
  final String startsAt;
  final String duration;
  final String comment;

  const TimelineElement(
      {super.key,
      required this.onProfileClick,
      required this.name,
      required this.comment,
      required this.startsAt,
      required this.duration});

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
                Text(widget.name),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Row(children: [
            Text(widget.comment),
            const Spacer(),
          ]),
          const SizedBox(height: 4.0),
          Row(children: [
            Text(widget.startsAt),
            const Spacer(),
            Text(widget.duration),
          ]),
        ],
      ),
    );
  }
}
