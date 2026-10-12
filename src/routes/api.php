<?php

use App\Http\Controllers\Api\AuthTokenController;
use App\Http\Controllers\Api\BookApiController;
use Illuminate\Support\Facades\Route;

// Login endpoint
Route::post('/login', [AuthTokenController::class, 'store']);

// Everything in this group needs a valid token
Route::middleware('auth:api')->group(function () { // authenticate requests using passport
    Route::post('/logout', [AuthTokenController::class, 'destroy']);
    Route::apiResource('books', BookApiController::class)->names('api.books');
});