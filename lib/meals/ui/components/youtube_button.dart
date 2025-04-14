import 'package:cookbook/meals/ui/components/labeled_widget.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeButton extends StatelessWidget {
  const YoutubeButton({super.key, required this.url, this.label});

  final String? label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            color: Color(0xFFFF0831),
          ),
          child: LabeledWidget(
            icon: Icon(LucideIcons.youtube, size: 16),
            text: label ?? "Watch on Youtube",
          ),
        ),
      ),
    );
  }
}
