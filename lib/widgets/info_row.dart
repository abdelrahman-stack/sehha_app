
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
