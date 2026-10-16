import { Form, Head, Link } from '@inertiajs/react';
import { login } from '@/routes';
import '../../../css/auth.css';

export default function VerifyResetLink() {
    return (
        <>
            <Head title="Verify reset link" />

            <Form action="/verify-reset-link" method="post" className="auth-form">
                {({ processing, errors }) => (
                    <>
                        <div className="auth-field">
                            <label htmlFor="link">Link from your email</label>
                            <textarea
                                id="link"
                                name="link"
                                rows={4}
                                autoFocus
                                placeholder="Paste the full link here"
                            />
                            {errors.link && (
                                <div className="auth-error">{errors.link}</div>
                            )}
                        </div>

                        <button
                            type="submit"
                            className="auth-btn"
                            disabled={processing}
                        >
                            {processing ? 'Verifying...' : 'Verify'}
                        </button>
                    </>
                )}
            </Form>

            <p className="auth-switch">
                Did not get an email?{' '}
                <Link href="/forgot-password" className="auth-link">
                    Request a new link
                </Link>
            </p>
            <p className="auth-switch">
                Or return to{' '}
                <Link href={login()} className="auth-link">
                    log in
                </Link>
            </p>
        </>
    );
}

VerifyResetLink.layout = {
    title: 'Verify your link',
    description: 'Paste the password reset link you received by email',
};