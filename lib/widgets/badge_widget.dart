import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String title;
  final bool unlocked;

  const BadgeWidget({Key? key, required this.title, this.unlocked = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked ? Colors.amber.shade200 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: unlocked
            ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(unlocked ? Icons.emoji_events : Icons.lock, color: unlocked ? Colors.orange : Colors.grey.shade600),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
