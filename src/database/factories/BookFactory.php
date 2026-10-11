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
        $my_status = fake()->randomElement(['want_to_read', 'reading', 'finished']);
        $pages = fake()->numberBetween(0, 1000);
        return [
            'user_id' => User::factory(),
            'title' => fake()->sentence(),
            'author' => fake()->name(),
            'genre' => fake()->randomElement(['Novel', 'Biography', 'Fiction', 'Non-fiction', 'Science Fiction', 'Fantasy', 'Mystery', 'Romance', 'Crime', 'Thriller', 'Horror', 'Self-help', 'History', 'Philosophy', 'Poetry']),
            'description' => fake()->paragraph(),
            'status' => $my_status,
            'total_pages' => $pages,
            'current_page' => $my_status === 'finished' ? $pages : ($my_status === 'reading' ? fake()->numberBetween(0, $pages) : 0),
            'poster_path' => null,
        ];
    }
}
