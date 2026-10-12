<?php

use App\Http\Controllers\BookController;
use App\Models\Book;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::inertia('/', 'welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    // The starter kit's dashboard is replaced by the books list
    Route::redirect('dashboard', '/books')->name('dashboard');

    // N+1 demo: shows the number of queries before and after the fix
    Route::get('demo/n-plus-one', function () {
        // BAD: 1 query for the books, then 1 more query per book to load its user
        DB::flushQueryLog(); // Clears the currently recorded entries in the log
        DB::enableQueryLog();
        $books = Book::all();
        foreach ($books as $book) {
            $book->user->name;
        }
        $without = count(DB::getQueryLog());

        // GOOD: eager loading, only 2 queries in total
        DB::flushQueryLog();
        $books = Book::with('user')->get(); // loads the user relationships along with the books
        foreach ($books as $book) {
            $book->user->name;
        }
        $with = count(DB::getQueryLog());

        return response()->json([
            'books' => $books->count(),
            'queries_without_eager_loading' => $without,
            'queries_with_eager_loading' => $with,
        ]);
    })->name('demo.n-plus-one');

    // Only logged-in users can access the books.
    // generates the conventional routes for managing books
    Route::resource('books', BookController::class);
});

require __DIR__.'/settings.php';