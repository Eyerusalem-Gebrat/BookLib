<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookController;

Route::inertia('/', 'welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'dashboard')->name('dashboard');
    // Only logged-in users can access the books.
    Route::resource('books', BookController::class);
});

require __DIR__.'/settings.php';
