import { Head, Link } from '@inertiajs/react';
import '../../../css/common.css';
import '../../../css/show.css';

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

type BooksShowProps = {
  book: Book;
}

const statusLabels: Record<string, string> = {
  want_to_read: 'Want to Read',
  reading: 'Reading',
  finished: 'Finished',
};

export default function BooksShow({ book }: BooksShowProps) {
  const percent = book.total_pages > 0
    ? Math.round((book.current_page / book.total_pages) * 100)
    : 0;

  return (
    <>
      <Head title={book.title} />
      <div className="show-page">
        <Link href="/books" className="back-link">← Back to my books</Link>

        <div className="show-layout">
          {book.poster_path ? (
            <img
              className="show-poster"
              src={`/storage/${book.poster_path}`}
              alt={`Poster of ${book.title}`}
            />
          ) : (
            <div className="show-poster book-poster-empty">No poster</div>
          )}

          <div className="show-info">
            <h1>{book.title}</h1>
            <p className="book-meta">by {book.author}</p>
            {book.genre && <p className="book-meta">Genre: {book.genre}</p>}

            <span className={`status-badge status-${book.status}`}>
              {statusLabels[book.status]}
            </span>

            <div className="progress">
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: `${percent}%` }} />
              </div>
              <p className="progress-text">
                {book.current_page} / {book.total_pages} pages ({percent}%)
              </p>
            </div>

            {book.description && (
              <p className="show-description">{book.description}</p>
            )}

            <div className="book-actions">
              <Link href={`/books/${book.id}/edit`} className="btn btn-primary">
                Edit
              </Link>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}