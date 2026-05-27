import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AvailabilityCard extends StatelessWidget {
  final HomePageController controller;

  const AvailabilityCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<int>>(
      key: ValueKey(controller.locationIDSelected),
      future: controller.getMachineCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 112,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final counts = snapshot.data ?? [0, 0, 0, 0];
        final totalWashers = counts[0];
        final idleWashers = counts[1];
        final totalDryers = counts[2];
        final idleDryers = counts[3];

        return Card(
          elevation: 5,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          color: colorScheme.cardPrimary,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(9, 9, 9, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        color: colorScheme.primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Availability',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _MachineAvailabilityStat(
                        label: 'washers',
                        available: idleWashers,
                        total: totalWashers,
                        accentColor: colorScheme.primary,
                        icon: Icons.local_laundry_service_outlined,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _MachineAvailabilityStat(
                        label: 'dryers',
                        available: idleDryers,
                        total: totalDryers,
                        accentColor: colorScheme.secondary,
                        icon: Icons.local_laundry_service_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MachineAvailabilityStat extends StatelessWidget {
  final String label;
  final int available;
  final int total;
  final Color accentColor;
  final IconData icon;

  const _MachineAvailabilityStat({
    required this.label,
    required this.available,
    required this.total,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total <= 0 ? 0.0 : (available / total).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 136;
        final compact = constraints.maxWidth < 150;
        final ringSize = tight ? 58.0 : (compact ? 63.0 : 70.0);
        final countSize = tight ? 26.0 : (compact ? 29.0 : 32.0);
        final iconSize = tight ? 23.0 : (compact ? 25.0 : 27.0);
        final labelSize = tight ? 11.5 : (compact ? 12.5 : 13.0);

        return Semantics(
          label: '$available of $total $label ready',
          child: Container(
            constraints: const BoxConstraints(minHeight: 80),
            padding: EdgeInsets.symmetric(
              horizontal: tight ? 5 : (compact ? 6 : 8),
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: ringSize,
                  child: _AvailabilityRing(
                    progress: progress,
                    accentColor: accentColor,
                    icon: icon,
                    iconSize: iconSize,
                    strokeWidth: tight ? 6.5 : 7.5,
                  ),
                ),
                SizedBox(width: tight ? 7 : (compact ? 8 : 9)),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$available',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: countSize,
                            fontWeight: FontWeight.w700,
                            height: 0.95,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$label\navailable',
                          softWrap: false,
                          style: TextStyle(
                            color: colorScheme.fontInverted,
                            fontSize: labelSize,
                            fontWeight: FontWeight.w400,
                            height: 1.08,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvailabilityRing extends StatelessWidget {
  final double progress;
  final Color accentColor;
  final IconData icon;
  final double iconSize;
  final double strokeWidth;

  const _AvailabilityRing({
    required this.progress,
    required this.accentColor,
    required this.icon,
    required this.iconSize,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = Colors.grey.withValues(alpha: 0.18);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: trackColor, width: strokeWidth),
            ),
          ),
        ),
        if (progress > 0)
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              color: accentColor,
            ),
          ),
        Icon(icon, color: accentColor, size: iconSize),
      ],
    );
  }
}
