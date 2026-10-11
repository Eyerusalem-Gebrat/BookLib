<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class BookApiController extends Controller
{
    // Same rules as the website
    private function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'author' => ['required', 'string', 'max:255'],
            'genre' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['required', 'in:reading,finished,want_to_read'],
            'total_pages' => ['required', 'integer', 'min:1'],
            'current_page' => ['required', 'integer', 'min:0', 'lte:total_pages'],
            'poster' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ];
    }

    // List only the logged-in user's books
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            $request->user()->books()->latest()->get()
        );
    }

    // Create a book for the logged-in user
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate($this->rules());

        if ($request->hasFile('poster')) {
            $validated['poster_path'] = $request->file('poster')->store('posters', 'public');
        }
        unset($validated['poster']);

        $book = $request->user()->books()->create($validated);

        return response()->json($book, 201);
    }

    // Show one book (only if it is yours)
    public function show(Book $book): JsonResponse
    {
        Gate::authorize('view', $book);

        return response()->json($book);
    }

    // Update a book (only if it is yours)
    public function update(Request $request, Book $book): JsonResponse
    {
        Gate::authorize('update', $book);

        $validated = $request->validate($this->rules());

        if ($request->hasFile('poster')) {
            // Delete the old file first
            if ($book->poster_path) {
                Storage::disk('public')->delete($book->poster_path);
            }
            $validated['poster_path'] = $request->file('poster')->store('posters', 'public');
        }
        unset($validated['poster']);

        $book->update($validated);

        return response()->json($book);
    }

    // Delete a book (only if it is yours)
    public function destroy(Book $book): JsonResponse
    {
        Gate::authorize('delete', $book);

        $book->delete();

        return response()->json(['message' => 'Book deleted.']);
    }
}