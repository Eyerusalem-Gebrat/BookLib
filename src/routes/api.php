<?php

use App\Http\Controllers\Api\AuthTokenController;
use App\Http\Controllers\Api\BookApiController;
use Illuminate\Support\Facades\Route;

// Registration endpoint
Route::post('/register', [AuthTokenController::class, 'register']);

// Login endpoint
Route::post('/login', [AuthTokenController::class, 'store']);

// Everything in this group needs a valid token
Route::middleware('auth:sanctum')->group(function () { // authenticate requests using Sanctum
    Route::post('/logout', [AuthTokenController::class, 'destroy']);
    Route::apiResource('books', BookApiController::class)->names('api.books');
});