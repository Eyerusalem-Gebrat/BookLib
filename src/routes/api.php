<?php

use App\Http\Controllers\Api\AuthTokenController;
use App\Http\Controllers\Api\BookApiController;
use App\Http\Controllers\Api\PasswordResetApiController;
use Illuminate\Support\Facades\Route;

// Login endpoint
Route::post('/login', [AuthTokenController::class, 'store']);

// Password recovery: no login token required
Route::post('/forgot-password', [PasswordResetApiController::class, 'forgotPassword'])->middleware('throttle:6,1');
Route::post('/reset-password/verify', [PasswordResetApiController::class, 'verifyLink'])->middleware('throttle:6,1');
Route::post('/reset-password', [PasswordResetApiController::class, 'resetPassword'])->middleware('throttle:6,1');

// Everything in this group needs a valid token
Route::middleware(['auth:api', 'verified'])->group(function () { // authenticate requests using passport
    Route::post('/logout', [AuthTokenController::class, 'destroy']);
    Route::apiResource('books', BookApiController::class)->names('api.books');
});