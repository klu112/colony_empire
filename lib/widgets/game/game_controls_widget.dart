import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ServicesProvider>(
      builder: (context, gameProvider, servicesProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.s),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpeedButton(
                context: context,
                speed: 0,
                currentSpeed: gameProvider.speed,
                icon: Icons.pause,
                servicesProvider: servicesProvider,
              ),
              const SizedBox(width: AppDimensions.xs),
              _buildSpeedButton(
                context: context,
                speed: 1,
                currentSpeed: gameProvider.speed,
                icon: Icons.play_arrow,
                servicesProvider: servicesProvider,
              ),
              const SizedBox(width: AppDimensions.xs),
              _buildSpeedButton(
                context: context,
                speed: 2,
                currentSpeed: gameProvider.speed,
                icon: Icons.fast_forward,
                servicesProvider: servicesProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeedButton({
    required BuildContext context,
    required int speed,
    required int currentSpeed,
    required IconData icon,
    required ServicesProvider servicesProvider,
  }) {
    final bool isActive = speed == currentSpeed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Speed button tapped: $speed');
          servicesProvider.setGameSpeed(speed);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }
}
