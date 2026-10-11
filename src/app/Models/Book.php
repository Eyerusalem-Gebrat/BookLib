<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

#[Fillable(['title', 'author', 'genre', 'description', 'status', 'total_pages', 'current_page', 'poster_path'])]
class Book extends Model
{
    /**
     * One book belongs to one user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
    /** @use HasFactory<\Database\Factories\BookFactory> */
    use HasFactory;

    protected static function booted(): void
    {
    static::saving(function (Book $book) {
        $isComplete = $book->total_pages > 0
            && $book->current_page >= $book->total_pages;

        if ($book->status === 'finished' || $isComplete) {
            $book->status = 'finished';
            $book->current_page = $book->total_pages;
        }
    });

    // Remove the poster file when the book is deleted
    static::deleting(function (Book $book) {
        if ($book->poster_path) {
            Storage::disk('public')->delete($book->poster_path);
        }
    });
    }
}
