import 'package:flutter/material.dart';

class PharmacyCard extends StatelessWidget {
  final String name;
  final String distance;
  final double rating;
  final VoidCallback onTap;
  final Color? brandColor;
  final String? logoInitial;

  const PharmacyCard({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.onTap,
    this.brandColor,
    this.logoInitial,
  });

  @override
  Widget build(BuildContext context) {
    final color = brandColor ?? const Color(0xFF0796DE);
    final initial = logoInitial ?? name[0].toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand colour banner with logo initial
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circle
                  Positioned(
                    top: -16,
                    right: -16,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Distance
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Color(0xFF0796DE)),
                        const SizedBox(width: 2),
                        Text(distance,
                            style: const TextStyle(
                              color: Color(0xFF919191),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            )),
                      ]),
                      // Rating
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFFB800)),
                        const SizedBox(width: 2),
                        Text(rating.toString(),
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            )),
                      ]),
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
