<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
}
