<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('BOOKLIB_ADMIN_EMAIL');
        $password = env('BOOKLIB_ADMIN_PASSWORD');

        if (! $email || ! $password) {
            throw new \RuntimeException(
                'Set BOOKLIB_ADMIN_EMAIL and BOOKLIB_ADMIN_PASSWORD in .env first.'
            );
        }

        $admin = User::firstOrNew(['email' => $email]);

        $admin->name = 'BookLib Admin';
        $admin->password = Hash::make($password);
        $admin->email_verified_at = now();
        $admin->forceFill(['is_admin' => true]);
        $admin->save();
    }
}
