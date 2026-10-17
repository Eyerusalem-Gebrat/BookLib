import { Link, usePage } from '@inertiajs/react';
import { ExternalLink } from 'lucide-react';
import type { ReactNode } from 'react';
import '../../css/admin.css';

type SharedProps = {
    auth?: {
        user?: {
            id: number;
            name: string;
            email: string;
            is_admin?: boolean;
        } | null;
    };
};

export default function AdminLayout({ children }: { children: ReactNode }) {
    const { auth } = usePage<SharedProps>().props;

    return (
        <div className="admin-shell">
            <header className="admin-header">
                <div className="admin-header-left">
                    <Link href="/admin" className="admin-logo">
                        BookLib
                    </Link>
                    <span className="admin-badge">Admin</span>
                </div>

                <div className="admin-header-right">
                    <Link href="/books" className="admin-view-site-link">
                        <span>View Website</span>
                        <ExternalLink size={14} aria-hidden="true" />
                    </Link>

                    {auth?.user && (
                        <span className="admin-user-pill">
                            <span className="admin-user-dot" />
                            <span>{auth.user.name}</span>
                        </span>
                    )}

                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="admin-logout-btn"
                    >
                        Log out
                    </Link>
                </div>
            </header>

            <main className="admin-main">{children}</main>
        </div>
    );
}
