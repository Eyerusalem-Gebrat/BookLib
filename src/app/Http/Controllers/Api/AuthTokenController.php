<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthTokenController extends Controller
{
    // Log in an existing website user and return a Passport token
    public function store(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = \App\Models\User::where(
            'email',
            $credentials['email']
        )->first();

        // Reject nonexistent users and incorrect passwords
        if (
            ! $user ||
            ! Hash::check($credentials['password'], $user->password)
        ) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Tell the request logger who is logging in (this request had no token yet)
        $request->attributes->set('log_user_id', $user->id);

        // Only verified accounts may use the app
        if (! $user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Please verify your email address first, then log in again.',
            ], 403);
        }

        // Create a Passport access token
        $token = $user->createToken('mobile')->accessToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ]);
    }

    // Revoke the Passport token used for this request
    public function destroy(Request $request): JsonResponse
    {
        $request->user()->token()->revoke();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }
}

