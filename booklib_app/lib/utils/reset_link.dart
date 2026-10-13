// Pulls the token (and email) out of the reset link from the email
class ResetLink {
  final String token;
  final String? email;

  const ResetLink({required this.token, this.email});

  // Accepts the full link, or just the token
  // Link example: http://site.com/reset-password/TOKEN?email=user%40example.com
  static ResetLink parse(String input) {
    final text = input.trim();
    final uri = Uri.tryParse(text);

    if (uri != null && uri.hasScheme) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        return ResetLink(
          token: segments.last,
          email: uri.queryParameters['email'],
        );
      }
    }

    // Not a link: treat the whole text as the token
    return ResetLink(token: text);
  }
}