// Link navigates between pages using inertia without a full page reload
// router.delete sends a DELETE request to the server to delete a book
// usePage is used to access shared props, such as flash messages, from the server.
import { Head, Link, router, usePage } from '@inertiajs/react';
import { useEffect, useState } from 'react';
import '../../../css/common.css';
import '../../../css/index.css';

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

// The data the page expects to receive
type BooksIndexProps = {
  books: Book[];
}

// Flash messages, ? means optional
type SharedProps = {
  flash?: { success?: string | null };
}

// Maps the database value to a readable label
const statusLabels: Record<string, string> = {
  want_to_read: 'Want to Read',
  reading: 'Reading',
  finished: 'Finished',
};

export default function BooksIndex({ books }: BooksIndexProps) {
  const { flash } = usePage<SharedProps>().props;

  const [showFlash, setShowFlash] = useState(true);

  useEffect(() => {
    if (!flash?.success) return;

    setShowFlash(true);
    const timer = setTimeout(() => setShowFlash(false), 3000);

    // Clean up the timer if the page changes before it finishes
    return () => clearTimeout(timer);
  }, [flash]);

  return (
    // <> groups elements without adding an extra HTML element
    <>
      <Head title="My Books" />
      <div className="books-page">
        <div className="books-header">
          <h1>My Reading List</h1>
          <Link href="/books/create" className="btn btn-primary">
            Add Book
          </Link>
        </div>

        {flash?.success && showFlash && (
          <div className="flash-success">{flash.success}</div>
        )}

        {books.length === 0 ? (
          <p className="empty-message">You haven't added any books yet.</p>
        ) : (
          <ul className="book-list">
            {books.map((book) => {
              // Avoid dividing by zero
              const percent = book.total_pages > 0
                ? Math.round((book.current_page / book.total_pages) * 100)
                : 0;

              return (
                <li key={book.id} className="book-card">
                  {book.poster_path ? (
                    <img
                      className="book-poster"
                      src={`/storage/${book.poster_path}`}
                      alt={`Poster of ${book.title}`}
                    />
                  ) : (
                    <div className="book-poster book-poster-empty">No poster</div>
                  )}

                  <div className="book-info">
                    <h2>
                      <Link href={`/books/${book.id}`}>{book.title}</Link>
                    </h2>
                    <p className="book-meta">by {book.author}</p>
                    {book.genre && <p className="book-meta">Genre: {book.genre}</p>}

                    <span className={`status-badge status-${book.status}`}>
                      {statusLabels[book.status]}
                    </span>

                    <div className="progress">
                      <div className="progress-bar">
                        <div
                          className="progress-fill"
                          style={{ width: `${percent}%` }}
                        />
                      </div>
                      <p className="progress-text">
                        {book.current_page} / {book.total_pages} pages ({percent}%)
                      </p>
                    </div>

                    {book.description && (
                      <p className="book-description">{book.description}</p>
                    )}

                    <div className="book-actions">
                      <Link href={`/books/${book.id}/edit`} className="btn">
                        Edit
                      </Link>
                      <button
                        type="button"
                        className="btn btn-danger"
                        onClick={() => {
                          if (confirm(`Are you sure you want to delete "${book.title}"?`)) {
                            // send a delete request to this url 
                            router.delete(`/books/${book.id}`);
                          }
                        }}
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </>
  );
}