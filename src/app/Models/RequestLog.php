<?php

namespace App\Models;

use App\Enums\Platform;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['user_id', 'platform', 'method', 'route_name', 'route_uri', 'status_code', 'ip_address'])]
class RequestLog extends Model
{
    // The table has only created_at (no updated_at)
    public const UPDATED_AT = null;

    protected function casts(): array
    {
        return [
            'platform' => Platform::class, // reads as an enum: Platform::Web or Platform::App
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}