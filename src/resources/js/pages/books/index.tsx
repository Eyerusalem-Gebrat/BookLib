import { Head, router, Link } from '@inertiajs/react';

type Book = {
  id: number;
  title: string;
  author: string;
  genre: string | null;
  description: string | null;
  status: string;
  total_pages: number;
  current_page: number;
  poster_path: string | null;
}

type BooksIndexProps = {
  books: Book[];
}

// Maps the database value to a readable label
const statusLabels: Record<string, string> = {
  want_to_read: 'Want to Read',
  reading: 'Reading',
  finished: 'Finished',
};

export default function BooksIndex({ books }: BooksIndexProps) {
    return (
        <>
            <Head title="My Books"/>
            <div>
                <h1>My Reading List</h1>
                <ul>
                    {books.map(book => {
                        // Avoid dividing by zero
                        const percent = book.total_pages > 0
                            ? Math.round((book.current_page / book.total_pages) * 100)
                            : 0;

                        return (
                            <li key={book.id}>
                                {/* Poster: only shown if the book has one */}
                                {book.poster_path && (
                                    <img
                                        src={`/storage/${book.poster_path}`}
                                        alt={`Poster of ${book.title}`}
                                        width={80}
                                    />
                                )}

                                <h2>{book.title}</h2>
                                <p>Author: {book.author}</p>

                                {/* Genre: only shown if not null */}
                                {book.genre && <p>Genre: {book.genre}</p>}

                                {/* Description: only shown if not null */}
                                {book.description && <p>Description: {book.description}</p>}

                                <p>Status: {statusLabels[book.status]}</p>
                                <p>
                                    Progress: {book.current_page} / {book.total_pages} pages ({percent}%)
                                </p>

                                <button
                                    onClick={() => {
                                        if (confirm(`Are you sure you want to delete "${book.title}"?`)) {
                                            router.delete(`/books/${book.id}`);
                                        }
                                    }}
                                >
                                    Delete
                                </button>
                                <Link href={`/books/${book.id}/edit`}>Edit</Link>                               
                            </li>
                        );

                    })}
                </ul>
            </div>
        </>
    );
}
    
