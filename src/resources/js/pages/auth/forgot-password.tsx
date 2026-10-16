import { Form, Head, Link } from '@inertiajs/react';
import { login } from '@/routes';
import { email } from '@/routes/password';
import '../../../css/auth.css';

export default function ForgotPassword({ status }: { status?: string }) {
    return (
        <>
            <Head title="Forgot password" />

            {status && <div className="auth-status">{status}</div>}

            <Form {...email.form()} className="auth-form">
                {({ processing, errors }) => (
                    <>
                        <div className="auth-field">
                            <label htmlFor="email">Email address</label>
                            <input
                                id="email"
                                type="email"
                                name="email"
                                autoComplete="off"
                                autoFocus
                                placeholder="email@example.com"
                            />
                            {errors.email && (
                                <div className="auth-error">{errors.email}</div>
                            )}
                        </div>

                        <button
                            type="submit"
                            className="auth-btn"
                            disabled={processing}
                            data-test="email-password-reset-link-button"
                        >
                            {processing ? 'Sending...' : 'Email password reset link'}
                        </button>
                    </>
                )}
            </Form>

            <p className="auth-switch">
                Already have the link?{' '}
                <Link href="/verify-reset-link" className="auth-link">
                    Enter it here
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

ForgotPassword.layout = {
    title: 'Forgot password',
    description: 'Enter your email to receive a password reset link',
};