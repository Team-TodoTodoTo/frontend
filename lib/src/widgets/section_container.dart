import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final String? title;
  final String? date;
  final List<Widget> children;

  const SectionContainer({
    super.key,
    this.title,
    this.date,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          if (date != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                date!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
