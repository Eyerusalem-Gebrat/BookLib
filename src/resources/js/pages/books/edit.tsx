import { FormEvent } from 'react';
import { Head, useForm } from '@inertiajs/react';

type Book = {
  id: number;
  title: string;
  author: string;
  genre: string | null;
  description: string | null;
  status: string;
  total_pages: number;
  current_page: number;
}

type BooksEditProps = {
  book: Book;
}

export default function BooksEdit({ book }: BooksEditProps) {
  const { data, setData, put, processing, errors } = useForm({
    title: book.title,
    author: book.author,
    genre: book.genre ?? '',
    description: book.description ?? '',
    status: book.status,
    total_pages: String(book.total_pages),
    current_page: String(book.current_page),
  });

  const submit = (e: FormEvent) => {
    e.preventDefault();
    put(`/books/${book.id}`);
  };

  return (
    <>
      <Head title="Edit Book" />
      <div>
        <h1>Edit Book</h1>

        <form onSubmit={submit}>
          <div>
            <label htmlFor="title">Title</label>
            <input
              id="title"
              type="text"
              value={data.title}
              onChange={(e) => setData('title', e.target.value)}
            />
            {errors.title && <div>{errors.title}</div>}
          </div>

          <div>
            <label htmlFor="author">Author</label>
            <input
              id="author"
              type="text"
              value={data.author}
              onChange={(e) => setData('author', e.target.value)}
            />
            {errors.author && <div>{errors.author}</div>}
          </div>

          <div>
            <label htmlFor="genre">Genre</label>
            <input
              id="genre"
              type="text"
              value={data.genre}
              onChange={(e) => setData('genre', e.target.value)}
            />
            {errors.genre && <div>{errors.genre}</div>}
          </div>

          <div>
            <label htmlFor="description">Description</label>
            <textarea
              id="description"
              value={data.description}
              onChange={(e) => setData('description', e.target.value)}
            />
            {errors.description && <div>{errors.description}</div>}
          </div>

          <div>
            <label htmlFor="status">Status</label>
            <select
              id="status"
              value={data.status}
              onChange={(e) => setData('status', e.target.value)}
            >
              <option value="want_to_read">Want to Read</option>
              <option value="reading">Reading</option>
              <option value="finished">Finished</option>
            </select>
            {errors.status && <div>{errors.status}</div>}
          </div>

          <div>
            <label htmlFor="total_pages">Total pages</label>
            <input
              id="total_pages"
              type="number"
              min={1}
              value={data.total_pages}
              onChange={(e) => setData('total_pages', e.target.value)}
            />
            {errors.total_pages && <div>{errors.total_pages}</div>}
          </div>

          <div>
            <label htmlFor="current_page">Pages read</label>
            <input
              id="current_page"
              type="number"
              min={0}
              value={data.current_page}
              onChange={(e) => setData('current_page', e.target.value)}
            />
            {errors.current_page && <div>{errors.current_page}</div>}
          </div>

          <button type="submit" disabled={processing}>
            Save Changes
          </button>
        </form>
      </div>
    </>
  );
}