import 'package:cookbook/meals/model/meal.dart';
import 'package:cookbook/meals/ui/components/labeled_widget.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MealListItem extends StatelessWidget {
  const MealListItem({super.key, required this.meal, this.onTap});

  final Meal meal;

  final ValueChanged<Meal>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(meal),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 20, 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 130,
                child: Image.network(meal.thumbnail, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontFamily: "Tinos",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      LabeledWidget(
                        icon: Icon(
                          LucideIcons.earth,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        text: meal.area,
                      ),
                      LabeledWidget(
                        icon: Icon(LucideIcons.tags, size: 14),
                        text: meal.tags.join(", "),
                      ),
                      if (meal.youtubeUrl != null)
                        LabeledWidget(
                          icon: Icon(
                            LucideIcons.youtube,
                            size: 14,
                            color: Color(0xFFFF0831),
                          ),
                          text: "Video available",
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
