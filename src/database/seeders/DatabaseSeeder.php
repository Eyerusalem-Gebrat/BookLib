<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Book;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        // Create 10 books for the user
        Book::factory()->count(10)->for($user)->create();

        $user1 = User::factory()->create([
            'name' => 'Test User 1',
            'email' => 'test1@example.com',
        ]);

        // Create 3 books for the user
        Book::factory()->count(3)->for($user1)->create();
    }
}
