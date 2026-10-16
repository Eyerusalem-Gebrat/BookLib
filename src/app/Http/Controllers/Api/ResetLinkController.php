<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Support\ResetLink;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response;

class ResetLinkController extends Controller
{
    // GET /verify-reset-link: the page with the box to paste the link
    public function show(): Response
    {
        return Inertia::render('auth/verify-reset-link');
    }

    // POST /verify-reset-link: check the link, then open the new-password page
    public function verify(Request $request): RedirectResponse
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

        // Fortify's own page for choosing a new password
        return redirect()->route('password.reset', [
            'token' => $result['token'],
            'email' => $result['email'],
        ]);
    }
}