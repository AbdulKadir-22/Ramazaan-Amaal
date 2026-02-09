import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The Logo Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildLogoPlaceholder(),
                ),
              ),
              
              const SizedBox(height: 40),

              // 2. The Main Title
              const Text(
                "Ramazan Amaal\nTracker",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark, // Using AppColors
                  letterSpacing: 0.5,
                  height: 1.2, 
                ),
              ),

              const SizedBox(height: 16),

              // 3. The Subtitle
              const Text(
                "A calm companion for your Ramazan amaal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey, // Using AppColors
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          // The Crescent Moon
          const Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.nightlight_round, 
              size: 45, 
              color: AppColors.primary, // Using AppColors
            ),
          ),
          // The Checkmark
          Positioned(
            right: 8,
            top: 10,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, 
              ),
              child: const Icon(
                Icons.check, 
                size: 20, 
                color: AppColors.primary, // Using AppColors
              ),
            ),
          ),
        ],
      ),
    );
  }
}