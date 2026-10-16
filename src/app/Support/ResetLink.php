<?php

namespace App\Support;

use Illuminate\Support\Facades\Password;

// Reads and checks the password reset link from the email
class ResetLink
{
    // Accepts:  http://site/reset-password/TOKEN?email=user%40example.com
    // Returns ['token' => ..., 'email' => ...], or null when the text is not a reset link
    public static function parse(string $input): ?array
    {
        $input = trim($input);

        $path = parse_url($input, PHP_URL_PATH);
        $query = parse_url($input, PHP_URL_QUERY);

        if (! is_string($path) || ! is_string($query)) {
            return null;
        }

        parse_str($query, $params);
        $email = $params['email'] ?? null;

        // The path must end with /reset-password/{token}
        $segments = array_values(array_filter(
            explode('/', $path),
            fn ($segment) => $segment !== ''
        ));
        $count = count($segments);

        if (
            $count < 2 ||
            $segments[$count - 2] !== 'reset-password' ||
            ! is_string($email) ||
            $email === ''
        ) {
            return null;
        }

        return ['token' => $segments[$count - 1], 'email' => $email];
    }

    // Parses the link AND asks Laravel whether the token is still valid.
    // It does not use the token up: only the final password change does.
    public static function verify(string $input): ?array
    {
        $parsed = self::parse($input);

        if ($parsed === null) {
            return null;
        }

        $broker = Password::broker();
        $user = $broker->getUser(['email' => $parsed['email']]);

        if ($user === null || ! $broker->tokenExists($user, $parsed['token'])) {
            return null;
        }

        return $parsed;
    }
}