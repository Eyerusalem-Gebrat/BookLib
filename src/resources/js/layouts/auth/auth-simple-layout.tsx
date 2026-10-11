import { Link } from '@inertiajs/react';
import { home } from '@/routes';
import type { AuthLayoutProps } from '@/types';
import '../../../css/auth.css';

export default function AuthSimpleLayout({
    children,
    title,
    description,
}: AuthLayoutProps) {
    return (
        <div className="auth-page">
            <div className="auth-card">
                <Link href={home()} className="auth-brand">
                    BookLib
                </Link>

                <div className="auth-heading">
                    <h1>{title}</h1>
                    <p>{description}</p>
                </div>

                {children}
            </div>
        </div>
    );
}