<?php

namespace Database\Factories;

use App\Models\Book;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Book>
 */
class BookFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'title' => fake()->sentence(),
            'author' => fake()->name(),
            'genre' => fake()->randomElement(['Novel', 'Biography', 'Fiction', 'Non-fiction', 'Science Fiction', 'Fantasy', 'Mystery', 'Romance', 'Crime', 'Thriller', 'Horror', 'Self-help', 'History', 'Philosophy', 'Poetry']),
            'description' => fake()->paragraph(),
            'status' => fake()->randomElement(['want_to_read', 'reading', 'finished']),
        ];
    }
}
