<?php

namespace App\Http\Controllers;

use App\Models\User;
use Inertia\Inertia;
use Inertia\Response;

class AdminDashboardController extends Controller
{
    public function index(): Response
    {
        // Only an administrator can view this dashboard.
        abort_unless(auth()->user()->is_admin, 403);

        // Include users with zero requests, and exclude admin accounts.
        $users = User::query()
            ->where('is_admin', false)
            ->withCount([
                'requestLogs as web_requests_count' => fn ($query) =>
                    $query->where('platform', 'web'),

                'requestLogs as app_requests_count' => fn ($query) =>
                    $query->where('platform', 'app'),

                'requestLogs as total_requests_count',
            ])
            ->orderBy('name')
            ->get(['id', 'name', 'email']);

        return Inertia::render('admin/dashboard', [
            'users' => $users,
            'totals' => [
                'users' => $users->count(),
                'web_requests' => $users->sum('web_requests_count'),
                'app_requests' => $users->sum('app_requests_count'),
                'all_requests' => $users->sum('total_requests_count'),
            ],
        ]);
    }
}
