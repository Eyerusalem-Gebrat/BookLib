<?php

use App\Http\Controllers\Api\AuthTokenController;
use App\Http\Controllers\Api\BookApiController;
use Illuminate\Support\Facades\Route;

// No register endpoint on purpose: users must register on the website first.
Route::post('/login', [AuthTokenController::class, 'store']);

// Everything in this group needs a valid token
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthTokenController::class, 'destroy']);
    Route::apiResource('books', BookApiController::class);
});