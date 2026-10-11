import { Head, Link, usePage } from '@inertiajs/react';
import '../../css/welcome.css';
import '../../css/common.css';

type SharedProps = {
  auth?: { user?: { name: string } | null };
}

export default function Welcome() {
  const { auth } = usePage<SharedProps>().props;

  return (
    <>
      <Head title="BookLib - Track your reading" />
      <div className="welcome-page">
        <header className="welcome-header">
          <span className="welcome-logo">BookLib</span>
          <nav className="welcome-nav">
            {auth?.user ? (
              <Link href="/books" className="btn btn-primary">My Books</Link>
            ) : (
              <>
                <Link href="/login" className="btn">Log in</Link>
                <Link href="/register" className="btn btn-primary">Register</Link>
              </>
            )}
          </nav>
        </header>

        <main className="welcome-hero">
          <h1>Track every book you read</h1>
          <p>
            Add the books you want to read, upload their posters, and watch
            your reading progress grow, page by page.
          </p>

          {auth?.user ? (
            <Link href="/books" className="btn btn-primary welcome-cta">
              Go to my books
            </Link>
          ) : (
            <Link href="/register" className="btn btn-primary welcome-cta">
              Get started
            </Link>
          )}
        </main>

        <section className="welcome-features">
          <div className="welcome-feature">
            <h2>Organize</h2>
            <p>Mark books as Want to Read, Reading, or Finished.</p>
          </div>
          <div className="welcome-feature">
            <h2>Track progress</h2>
            <p>Enter the pages you have read and see your percentage.</p>
          </div>
          <div className="welcome-feature">
            <h2>Keep it private</h2>
            <p>Your books are visible only to you.</p>
          </div>
        </section>
      </div>
    </>
  );
}