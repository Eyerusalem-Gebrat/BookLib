import { Link, usePage } from '@inertiajs/react'; // usePage - shared page info supplied by Inertia
import type { ReactNode } from 'react';
import '../../css/common.css';
import '../../css/layout.css';

type SharedProps = {
  auth?: { user?: { name: string } | null };
}

export default function BooksLayout({ children }: { children: ReactNode }) {
  const { auth } = usePage<SharedProps>().props;

  return (
    <div className="app-shell">
      <header className="app-header">
        <Link href="/books" className="app-logo">
          BookLib
        </Link>

        <div className="app-header-right">
          {auth?.user && <span className="app-user">{auth.user.name}</span>}
          <Link href="/logout" method="post" as="button" className="btn">
            Log out
          </Link>
        </div>
      </header>

      <main className="app-main">{children}</main>  
    </div>
  );
}