<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('request_logs', function (Blueprint $table) {
            $table->id();

            // Who made the request. Empty when nobody was logged in (a failed login...).
            // If the user is deleted, the log stays and user_id becomes null.
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            // constrained() tells laravel to use the users table for user id foreign key, shorthand for foreignId('user_id')->references('id')->on('users')
            $table->string('platform', 10);             // "web" or "app"
            $table->string('method', 10);               // GET, POST, PUT, DELETE
            $table->string('route_name')->nullable();   // e.g. books.store
            $table->string('route_uri');                // e.g. books/{book} (the pattern, never the real URL)
            $table->unsignedSmallInteger('status_code'); // 200, 302, 422...
            $table->string('ip_address', 45)->nullable();

            $table->timestamp('created_at')->useCurrent(); // a log entry is never edited, so no updated_at

            // Fast counting for the future admin screens
            $table->index(['platform', 'created_at']);
            $table->index(['user_id', 'platform', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('request_logs');
    }
};
