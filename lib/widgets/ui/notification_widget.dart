import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class NotificationWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const NotificationWidget({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(
            isSmallScreen ? AppDimensions.s : AppDimensions.m,
          ),
          padding: EdgeInsets.all(
            isSmallScreen ? AppDimensions.s : AppDimensions.m,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(
                    width: isSmallScreen ? AppDimensions.xs : AppDimensions.s,
                  ),
                  Expanded(
                    child: Text(
                      widget.message,
                      style:
                          isSmallScreen
                              ? AppTextStyles.bodySmall
                              : AppTextStyles.bodyMedium,
                    ),
                  ),
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSmall,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 2.0 : 4.0),
                      child: Icon(
                        Icons.close,
                        size: isSmallScreen ? 16 : 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
