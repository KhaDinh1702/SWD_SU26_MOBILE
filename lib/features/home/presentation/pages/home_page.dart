import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/features/home/presentation/widgets/feature_item.dart';
import 'package:flutter_app/features/home/presentation/widgets/gradient_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient toàn màn hình
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.primaryGradient,
              ),
            ),
          ),

          // Vòng tròn trang trí
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Phần thương hiệu
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.local_car_wash,
                            size: 52,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'AutoWash Pro',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hệ thống rửa xe thông minh & hiện đại',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Tính năng nổi bật
                        FeatureItem(
                          icon: Icons.calendar_today_rounded,
                          text: 'Đặt lịch thông minh với hàng đợi ưu tiên',
                        ),
                        const SizedBox(height: 16),
                        FeatureItem(
                          icon: Icons.star_rounded,
                          text: 'Tích điểm & nâng hạng thành viên tự động',
                        ),
                        const SizedBox(height: 16),
                        FeatureItem(
                          icon: Icons.local_offer_rounded,
                          text: 'Ưu đãi độc quyền cho hạng Gold & Platinum',
                        ),
                      ],
                    ),
                  ),
                ),

                // Card dưới cùng với nút hành động
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                  child: Column(
                    children: [
                      // Thanh kéo
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 28),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Bắt Đầu Ngay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Đăng nhập hoặc tạo tài khoản miễn phí',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 28),
                      GradientButton(
                        label: 'Đăng Nhập',
                        onTap: () => context.pushNamed('login'),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => context.pushNamed('register'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Tạo Tài Khoản',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
