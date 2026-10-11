import { Form, Head, Link } from '@inertiajs/react';
import AuthPasswordInput from '@/components/auth-password-input';
import { login } from '@/routes';
import { store } from '@/routes/register';
import '../../../css/auth.css';
import '../../../css/register.css';

export default function Register() {
    return (
        <>
            <Head title="Register" />

            <Form
                {...store.form()}
                resetOnSuccess={['password', 'password_confirmation']}
                disableWhileProcessing
                className="auth-form register-form"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="auth-field">
                            <label htmlFor="name">Name</label>
                            <input
                                id="name"
                                type="text"
                                name="name"
                                required
                                autoFocus
                                tabIndex={1}
                                autoComplete="name"
                                placeholder="Full name"
                            />
                            {errors.name && (
                                <div className="auth-error">{errors.name}</div>
                            )}
                        </div>

                        <div className="auth-field">
                            <label htmlFor="email">Email address</label>
                            <input
                                id="email"
                                type="email"
                                name="email"
                                required
                                tabIndex={2}
                                autoComplete="email"
                                placeholder="email@example.com"
                            />
                            {errors.email && (
                                <div className="auth-error">{errors.email}</div>
                            )}
                        </div>

                        <div className="register-passwords">
                            <div className="auth-field">
                                <label htmlFor="password">Password</label>
                                <AuthPasswordInput
                                    id="password"
                                    name="password"
                                    required
                                    tabIndex={3}
                                    autoComplete="new-password"
                                    placeholder="Password"
                                />
                                {errors.password && (
                                    <div className="auth-error">{errors.password}</div>
                                )}
                            </div>

                            <div className="auth-field">
                                <label htmlFor="password_confirmation">
                                    Confirm password
                                </label>
                                <AuthPasswordInput
                                    id="password_confirmation"
                                    name="password_confirmation"
                                    required
                                    tabIndex={4}
                                    autoComplete="new-password"
                                    placeholder="Confirm password"
                                />
                                {errors.password_confirmation && (
                                    <div className="auth-error">
                                        {errors.password_confirmation}
                                    </div>
                                )}
                            </div>
                        </div>

                        <button
                            type="submit"
                            className="auth-btn"
                            tabIndex={5}
                            disabled={processing}
                            data-test="register-user-button"
                        >
                            {processing ? 'Creating account...' : 'Create account'}
                        </button>

                        <p className="auth-switch">
                            Already have an account?{' '}
                            <Link href={login()} className="auth-link" tabIndex={6}>
                                Log in
                            </Link>
                        </p>
                    </>
                )}
            </Form>
        </>
    );
}

Register.layout = {
    title: 'Create an account',
    description: 'Enter your details below to create your account',
};