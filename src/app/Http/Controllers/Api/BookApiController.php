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
            // Remember the path of the existing poster
            $oldPosterPath = $book->poster_path;

            // Store the new poster first
            $newPosterPath = $request->file('poster')
                ->store('posters', 'public');

            // Stop if the new poster could not be stored
            if (!$newPosterPath) {
                return response()->json([
                    'message' => 'Failed to upload the new poster.',
                ], 500);
            }

            // Use the new poster path for the database update
            $validated['poster_path'] = $newPosterPath;
        }

        unset($validated['poster']);

        // Update the book in the database
        $book->update($validated);

        // Delete the old poster only after the update succeeds
        if (
            isset($newPosterPath) &&
            $oldPosterPath &&
            $oldPosterPath !== $newPosterPath
        ) {
            Storage::disk('public')->delete($oldPosterPath);
        }

        return response()->json([
            'message' => 'Book updated successfully.',
            'book' => $book,
        ]);
    }

    // Delete a book (only if it is yours)
    public function destroy(Book $book): JsonResponse
    {
        Gate::authorize('delete', $book);

        $posterPath = $book->poster_path;

        $book->delete();

        if ($posterPath) {
            Storage::disk('public')->delete($posterPath);
        }

        return response()->json([
            'message' => 'Book deleted.',
        ]);
    }
}