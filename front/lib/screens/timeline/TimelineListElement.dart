import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TimelineElement extends StatefulWidget {
  final Function? onProfileClick;
  final String name;
  final String startsAt;
  final String duration;
  final String comment;
  final String imageUrl;

  const TimelineElement(
      {super.key,
      required this.onProfileClick,
      required this.name,
      required this.comment,
      required this.startsAt,
      required this.imageUrl,
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
                  imageUrl: widget.imageUrl.isNotEmpty
                      ? widget.imageUrl
                      : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fclipground.com%2Fimages%2Fdefault-image-icon-png-4.png&f=1&nofb=1&ipt=6c40744f021c9dcc880eb432f338d9fff778d199dc615dacd3de4ab1ae19f345&ipo=images",
                  errorWidget: (context, string, error) =>
                      const Icon(Icons.error),
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
