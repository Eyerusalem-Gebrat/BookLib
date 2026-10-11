import { Form, Head, Link } from '@inertiajs/react';
import AuthPasswordInput from '@/components/auth-password-input';
import { register } from '@/routes';
import { store } from '@/routes/login';
import { request } from '@/routes/password';
import '../../../css/auth.css';
import '../../../css/login.css';

type Props = {
    status?: string;
    canResetPassword: boolean;
};

export default function Login({ status, canResetPassword }: Props) {
    return (
        <>
            <Head title="Log in" />

            {status && <div className="auth-status">{status}</div>}

            <Form
                {...store.form()}
                resetOnSuccess={['password']}
                className="auth-form login-form"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="auth-field">
                            <label htmlFor="email">Email address</label>
                            <input
                                id="email"
                                type="email"
                                name="email"
                                required
                                autoFocus
                                tabIndex={1}
                                autoComplete="email"
                                placeholder="email@example.com"
                            />
                            {errors.email && (
                                <div className="auth-error">{errors.email}</div>
                            )}
                        </div>

                        <div className="auth-field">
                            <label htmlFor="password">Password</label>
                            <AuthPasswordInput
                                id="password"
                                name="password"
                                required
                                tabIndex={2}
                                autoComplete="current-password"
                                placeholder="Password"
                            />
                            {errors.password && (
                                <div className="auth-error">{errors.password}</div>
                            )}
                        </div>

                        <div className="login-options">
                            <label className="login-remember" htmlFor="remember">
                                <input
                                    id="remember"
                                    type="checkbox"
                                    name="remember"
                                    tabIndex={3}
                                />
                                Remember me
                            </label>

                            {canResetPassword && (
                                <Link
                                    href={request()}
                                    className="auth-link"
                                    tabIndex={5}
                                >
                                    Forgot your password?
                                </Link>
                            )}
                        </div>

                        <button
                            type="submit"
                            className="auth-btn"
                            tabIndex={4}
                            disabled={processing}
                            data-test="login-button"
                        >
                            {processing ? 'Logging in...' : 'Log in'}
                        </button>

                        <p className="auth-switch">
                            Don't have an account?{' '}
                            <Link href={register()} className="auth-link" tabIndex={6}>
                                Sign up
                            </Link>
                        </p>
                    </>
                )}
            </Form>
        </>
    );
}

Login.layout = {
    title: 'Log in to your account',
    description: 'Enter your email and password below to log in',
};