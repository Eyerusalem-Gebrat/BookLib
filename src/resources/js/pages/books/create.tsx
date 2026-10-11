import { FormEvent } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import '../../../css/common.css';
import '../../../css/create.css';

export default function BooksCreate() {
  const { data, setData, post, processing, errors } = useForm({
    title: '',
    author: '',
    genre: '',
    description: '',
    status: 'want_to_read',
    total_pages: '',
    current_page: '0',
    poster: null as File | null,
  });

  const submit = (e: FormEvent) => {
    e.preventDefault();
    post('/books');
  };

  return (
    <>
      <Head title="Add Book" />
      <div className="form-page">
        <Link href="/books" className="back-link">← Back to my books</Link>
        <h1>Add a New Book</h1>

        <form onSubmit={submit} className="form-card">
          <div className="form-group">
            <label htmlFor="title">Title</label>
            <input
              id="title"
              type="text"
              value={data.title}
              onChange={(e) => setData('title', e.target.value)}
            />
            {errors.title && <div className="form-error">{errors.title}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="author">Author</label>
            <input
              id="author"
              type="text"
              value={data.author}
              onChange={(e) => setData('author', e.target.value)}
            />
            {errors.author && <div className="form-error">{errors.author}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="genre">Genre</label>
            <input
              id="genre"
              type="text"
              value={data.genre}
              onChange={(e) => setData('genre', e.target.value)}
            />
            {errors.genre && <div className="form-error">{errors.genre}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="description">Description</label>
            <textarea
              id="description"
              value={data.description}
              onChange={(e) => setData('description', e.target.value)}
            />
            {errors.description && <div className="form-error">{errors.description}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="poster">Poster</label>
            <input
              id="poster"
              type="file"
              accept="image/*"
              onChange={(e) => setData('poster', e.target.files?.[0] ?? null)}
            />
            {errors.poster && <div className="form-error">{errors.poster}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="status">Status</label>
            <select
              id="status"
              value={data.status}
              onChange={(e) => {
                const value = e.target.value;
                setData((prev) => ({
                  ...prev,
                  status: value,
                  current_page:
                    value === 'finished' && prev.total_pages !== ''
                      ? prev.total_pages
                      : prev.current_page,
                }));
              }}
            >
              <option value="want_to_read">Want to Read</option>
              <option value="reading">Reading</option>
              <option value="finished">Finished</option>
            </select>
            {errors.status && <div className="form-error">{errors.status}</div>}
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="total_pages">Total pages</label>
              <input
                id="total_pages"
                type="number"
                min={1}
                value={data.total_pages}
                onChange={(e) => {
                  const value = e.target.value;
                  setData((prev) => ({
                    ...prev,
                    total_pages: value,
                    current_page:
                      prev.status === 'finished' ? value : prev.current_page,
                  }));
                }}
              />
              {errors.total_pages && <div className="form-error">{errors.total_pages}</div>}
            </div>

            <div className="form-group">
              <label htmlFor="current_page">Pages read</label>
              <input
                id="current_page"
                type="number"
                min={0}
                value={data.current_page}
                onChange={(e) => {
                  const value = e.target.value;
                  setData((prev) => {
                    const total = Number(prev.total_pages);
                    let status = prev.status;

                    if (total > 0 && value !== '' && Number(value) >= total) {
                      status = 'finished';
                    } else if (prev.status === 'finished') {
                      status = 'reading';
                    }

                    return { ...prev, current_page: value, status };
                  });
                }}
              />
              {errors.current_page && <div className="form-error">{errors.current_page}</div>}
            </div>
          </div>

          <div className="form-actions">
            <button type="submit" className="btn btn-primary" disabled={processing}>
              Save Book
            </button>
            <Link href="/books" className="btn">Cancel</Link>
          </div>
        </form>
      </div>
    </>
  );
}