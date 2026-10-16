<?php

namespace App\Http\Controllers;

use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    // Display a listing of the resource.
    public function index(Request $request)
    {
        $user = $request->user();
        $books = $user->books()->latest()->get();
        return inertia('books/index', [
            'books' => $books,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return inertia('books/create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'author' => ['required', 'string', 'max:255'],
            'genre' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['required', 'in:reading,finished,want_to_read'],
            'total_pages' => ['required', 'integer', 'min:1'],
            'current_page' => ['required', 'integer', 'min:0', 'lte:total_pages'],
            'poster' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        // Save the uploaded file and keep only its path
        if ($request->hasFile('poster')) {
            $validated['poster_path'] = $request->file('poster')->store('posters', 'public');
        }

        // "poster" is a file object, not a database column
        // removes the poster entry into a database
        unset($validated['poster']);

        $request->user()->books()->create($validated);

        return redirect()->route('books.index')->with('success', 'Book created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Book $book)
    {
        // to ask BookPolicy.php whether a user is allowed to perform the action
        Gate::authorize('view', $book); 
        return inertia('books/show', [
            'book' => $book,
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Book $book)
    {
        Gate::authorize('update', $book);
        return inertia('books/edit', [
            'book' => $book,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Book $book): RedirectResponse
   {
        Gate::authorize('update', $book);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'author' => ['required', 'string', 'max:255'],
            'genre' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status' => ['required', 'in:reading,finished,want_to_read'],
            'total_pages' => ['required', 'integer', 'min:1'],
            'current_page' => ['required', 'integer', 'min:0', 'lte:total_pages'],
            'poster' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        $newPosterPath = null;
        $oldPosterPath = $book->poster_path;

        if ($request->hasFile('poster')) {
            $newPosterPath = $request->file('poster')->store('posters', 'public');

            if (!$newPosterPath) {
                return back()
                    ->withErrors(['poster' => 'Failed to upload the new cover image.'])
                    ->withInput();
            }

            $validated['poster_path'] = $newPosterPath;
        }

        // "poster" is a file object, not a database column
        unset($validated['poster']);

        $book->update($validated);

        // Delete the old cover only after the database update succeeds.
        if (
            $newPosterPath &&
            $oldPosterPath &&
            $oldPosterPath !== $newPosterPath
        ) {
            Storage::disk('public')->delete($oldPosterPath);
        }

        return redirect()->route('books.index')
            ->with('success', 'Book updated successfully.');
        }

    /**
     * Remove the specified resource from storage.
     */ 
     
    public function destroy(Book $book): RedirectResponse
    {
        Gate::authorize('delete', $book);

        $posterPath = $book->poster_path;

        // Delete the database record first.
        $book->delete();

        // Remove the image only after deletion succeeds.
        if ($posterPath) {
            Storage::disk('public')->delete($posterPath);
        }

        return redirect()->route('books.index')
            ->with('success', 'Book deleted successfully.');
    }
}
