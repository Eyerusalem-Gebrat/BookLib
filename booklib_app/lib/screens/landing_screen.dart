import 'package:flutter/material.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/screens/login_screen.dart';

/// The mobile landing screen mirroring the BookLib web landing page:
/// Editorial aesthetic, warm canvas, top navigation header with Log in button,
/// hero section with editorial typography, elevated feature cards, salon banner, and footer.
class LandingScreen extends StatelessWidget {
  /// An optional message, e.g. "Your session has expired."
  final String? notice;

  const LandingScreen({super.key, this.notice});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar (matches web app header exactly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.headerBg,
                border: Border(
                  bottom: BorderSide(color: AppTheme.headerBorder, width: 1),
                ),
                boxShadow: [AppTheme.shadowSm],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BookLib',
                    style: TextStyle(
                      fontFamily: AppTheme.fontSerif,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppTheme.headerLogo,
                    ),
                  ),
                  // Mobile only has "Log in" button
                  InkWell(
                    onTap: () => _navigateToLogin(context),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.btnCardBg,
                        border: Border.all(color: AppTheme.btnCardBorder),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.btnCardText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Optional Notice Banner
                    if (notice != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEB),
                          border: Border.all(color: const Color(0xFFF8CFCB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notice!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB9382E),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],

                    // Kicker Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        border: Border.all(color: AppTheme.statusWantBorder),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📖  ', style: TextStyle(fontSize: 13)),
                          Text(
                            'Your Personal Reading Sanctuary',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.kicker,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Headline
                    const Text(
                      'Track every book you read',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontSerif,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: AppTheme.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'Add the books you want to read, upload their posters, and watch your reading progress grow, page by page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Hero CTA Button (Acts as Login on Mobile)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [AppTheme.primaryGlow],
                      ),
                      child: FilledButton(
                        onPressed: () => _navigateToLogin(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Get started',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Open Book Divider
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Divider(color: AppTheme.inputBorder),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '📖',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Divider(color: AppTheme.inputBorder),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Feature Card 1: Organize
                    _buildFeatureCard(
                      iconWidget: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppTheme.badgeIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_outline_rounded,
                          color: AppTheme.kicker,
                          size: 18,
                        ),
                      ),
                      numberTag: '01',
                      title: 'Organize',
                      description:
                          'Mark books as Want to Read, Reading, or Finished.',
                      bottomWidget: Row(
                        children: [
                          _buildStatusPill('Want to Read'),
                          const SizedBox(width: 6),
                          _buildStatusPill('Reading'),
                          const SizedBox(width: 6),
                          _buildStatusPill('Finished'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Feature Card 2: Track progress
                    _buildFeatureCard(
                      iconWidget: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppTheme.badgeIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: AppTheme.kicker,
                          size: 18,
                        ),
                      ),
                      numberTag: '02',
                      title: 'Track progress',
                      description:
                          'Enter the pages you have read and see your percentage.',
                      bottomWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Page 184 of 268',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                '68%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.kicker,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: const LinearProgressIndicator(
                              value: 0.68,
                              backgroundColor: AppTheme.progressTrack,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Feature Card 3: Keep it private
                    _buildFeatureCard(
                      iconWidget: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppTheme.badgeGreenBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppTheme.badgeGreenText,
                          size: 18,
                        ),
                      ),
                      numberTag: '03',
                      title: 'Keep it private',
                      description: 'Your books are visible only to you.',
                      bottomWidget: const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Private archive • Encrypted collection',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reading Salon Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.salonBannerBg,
                        border: Border.all(color: AppTheme.salonBannerBorder),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBECE2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('📖', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Afternoon in the reading salon',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontSerif,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Warm light, mahogany bookshelves, and endless worlds to discover.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 14, color: AppTheme.kicker),
                              Icon(Icons.star_rounded,
                                  size: 14, color: AppTheme.kicker),
                              Icon(Icons.star_rounded,
                                  size: 14, color: AppTheme.kicker),
                              Icon(Icons.star_rounded,
                                  size: 14, color: AppTheme.kicker),
                              Icon(Icons.star_outline_rounded,
                                  size: 14, color: AppTheme.kicker),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Curated Footer Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.footerBg,
                        border: Border.all(color: AppTheme.footerBorder),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'BookLib — Curated library companion for reflective readers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'New here? Create your account on the BookLib website.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.kicker,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required Widget iconWidget,
    required String numberTag,
    required String title,
    required String description,
    required Widget bottomWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconWidget,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  numberTag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kicker,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontSerif,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}