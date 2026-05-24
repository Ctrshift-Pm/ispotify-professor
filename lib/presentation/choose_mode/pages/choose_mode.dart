import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_with_flutter/common/widgets/button/basic_app_button.dart';
import 'package:spotify_with_flutter/core/configs/assets/app_images.dart';
import 'package:spotify_with_flutter/core/configs/assets/app_vectors.dart';
import 'package:spotify_with_flutter/core/configs/theme/app_color.dart';
import 'package:spotify_with_flutter/core/routes/app_routes.dart';
import 'package:spotify_with_flutter/core/services/theme_controller.dart';

class ChooseModePage extends StatefulWidget {
  const ChooseModePage({super.key});

  @override
  State<ChooseModePage> createState() => _ChooseModePageState();
}

class _ChooseModePageState extends State<ChooseModePage> {
  @override
  Widget build(BuildContext context) {
    final selectedMode = themeController.themeMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 50,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(AppImages.chooseModeBackground),
              ),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 40.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(AppVectors.logo),
                ),
                const Spacer(),
                const Text(
                  'Escolha o tema',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await themeController.updateTheme(ThemeMode.dark);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: _modeOption(
                            icon: AppVectors.moon,
                            isSelected: selectedMode == ThemeMode.dark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Modo escuro",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await themeController.updateTheme(ThemeMode.light);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: _modeOption(
                            icon: AppVectors.sun,
                            isSelected: selectedMode == ThemeMode.light,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Modo claro",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColors.grey,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 50),
                BasicAppButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signupOrSignin);
                  },
                  title: "Continuar",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOption({
    required String icon,
    required bool isSelected,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 87, sigmaY: 87),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.white.withValues(alpha: 0),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.white.withValues(alpha: 0.18),
              width: 2,
            ),
          ),
          height: 73,
          width: 73,
          child: SvgPicture.asset(
            icon,
            fit: BoxFit.none,
            colorFilter: isSelected
                ? const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)
                : null,
          ),
        ),
      ),
    );
  }
}
