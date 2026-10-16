<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password as PasswordRule;
use App\Support\ResetLink;
use Illuminate\Validation\ValidationException;

class PasswordResetApiController extends Controller
{
    // Send a password reset link to the user's email
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
        ]);

        Password::sendResetLink(
            $request->only('email')
        );

        // Use a generic response to avoid revealing whether
        // an email address has a registered account.
        return response()->json([
            'message' =>
                'If an account exists for this email, a password reset link will be sent.',
        ]);
    }

        // Check a pasted reset link WITHOUT using it up
    public function verifyLink(Request $request): JsonResponse
    {
        $data = $request->validate([
            'link' => ['required', 'string', 'max:2000'],
        ]);

        $result = ResetLink::verify($data['link']);

        if ($result === null) {
            throw ValidationException::withMessages([
                'link' => ['This link is not valid or has expired. Please request a new one.'],
            ]);
        }

        return response()->json([
            'message' => 'Link verified.',
            'email' => $result['email'],
            'token' => $result['token'],
        ]);
    }

    // Reset the password using the emailed token
    public function resetPassword(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'token' => ['required', 'string'],
            'password' => [
                'required',
                'confirmed',
                PasswordRule::defaults(),
            ],
        ]);

        // reset checks the token and email, and if valid, calls the closure to update the password
        $status = Password::reset(
            $credentials,
            function (User $user, string $password) {
                // The User model's hashed cast hashes the password
                $user->password = $password;
                $user->setRememberToken(Str::random(60));
                $user->save();
                $user->tokens()->update(['revoked' => true]);

                event(new PasswordReset($user)); // so other parts can listen the event
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return response()->json([
                'message' => __($status),
            ], 422);
        }

        return response()->json([
            'message' => 'Password reset successfully. You can now log in.',
        ]);
    }
}

