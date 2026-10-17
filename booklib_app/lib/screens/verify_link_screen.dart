import 'package:flutter/material.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/screens/forgot_password_screen.dart';
import 'package:booklib_app/screens/reset_password_screen.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/password_service.dart';

/// Screen 3: Verify your link screen matching the website's verify-reset-link.tsx page
class VerifyLinkScreen extends StatefulWidget {
  final String? notice;

  const VerifyLinkScreen({super.key, this.notice});

  @override
  State<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends State<VerifyLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();
  final _passwordService = PasswordService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _passwordService.verifyLink(
        _linkController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      final email = result['email'];
      final token = result['token'];

      if (email == null || token == null) {
        setState(() {
          _error = 'Invalid verification response from server.';
        });
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email, token: token),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Could not verify link. Please make sure the full URL is pasted.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 110,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.btnCardBg,
                  border: Border.all(color: AppTheme.btnCardBorder),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [AppTheme.shadowSm],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AppTheme.btnCardText,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.btnCardText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 34,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: const [AppTheme.authCardShadow],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Terracotta Book Icon Badge
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.kicker,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [AppTheme.primaryGlow],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // BookLib Brand Name
                      const Text(
                        'BookLib',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontSerif,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Heading
                      const Text(
                        'Verify your link',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontSerif,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.btnCardText,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      const Text(
                        'Paste the password reset link you received by email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Notice banner (if navigated from forgot password)
                      if (widget.notice != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeGreenBg,
                            border: Border.all(color: const Color(0xFFC6DEC5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.notice!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.badgeGreenText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      // Multiline text field: Link from your email
                      const Text(
                        'Link from your email',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _linkController,
                        keyboardType: TextInputType.url,
                        autofocus: true,
                        minLines: 3,
                        maxLines: 5,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste the full link here',
                          hintStyle: const TextStyle(
                            color: AppTheme.inputPlaceholder,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppTheme.inputBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppTheme.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Paste the link from your email';
                          }
                          final uri = Uri.tryParse(text);
                          if (uri == null ||
                              (!text.startsWith('http://') &&
                                  !text.startsWith('https://'))) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),

                      // Error message
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEB),
                            border: Border.all(color: const Color(0xFFF8CFCB)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⚠  ', style: TextStyle(fontSize: 13)),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFB9382E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Primary button: Verify
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [AppTheme.primaryGlow],
                        ),
                        child: FilledButton(
                          onPressed: _loading ? null : _verify,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Did not get an email? Request a new link
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Did not get an email? ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Request a new link',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.kicker,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Or return to log in
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Or return to ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: const Text(
                              'log in',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.kicker,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
