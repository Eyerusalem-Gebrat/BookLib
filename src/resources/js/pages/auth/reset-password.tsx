import { Form, Head } from '@inertiajs/react';
import AuthPasswordInput from '@/components/auth-password-input';
import { update } from '@/routes/password';
import '../../../css/auth.css';

type Props = {
    token: string;
    email: string;
};

export default function ResetPassword({ token, email }: Props) {
    return (
        <>
            <Head title="Reset password" />

            <Form
                {...update.form()}
                transform={(data) => ({ ...data, token, email })}
                resetOnSuccess={['password', 'password_confirmation']}
                className="auth-form"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="auth-field">
                            <label htmlFor="email">Email</label>
                            <input
                                id="email"
                                type="email"
                                name="email"
                                value={email}
                                readOnly
                            />
                            {errors.email && (
                                <div className="auth-error">{errors.email}</div>
                            )}
                        </div>

                        <div className="auth-field">
                            <label htmlFor="password">New password</label>
                            <AuthPasswordInput
                                id="password"
                                name="password"
                                autoComplete="new-password"
                                autoFocus
                                placeholder="New password"
                            />
                            {errors.password && (
                                <div className="auth-error">{errors.password}</div>
                            )}
                        </div>

                        <div className="auth-field">
                            <label htmlFor="password_confirmation">Confirm password</label>
                            <AuthPasswordInput
                                id="password_confirmation"
                                name="password_confirmation"
                                autoComplete="new-password"
                                placeholder="Confirm password"
                            />
                            {errors.password_confirmation && (
                                <div className="auth-error">
                                    {errors.password_confirmation}
                                </div>
                            )}
                        </div>

                        <button
                            type="submit"
                            className="auth-btn"
                            disabled={processing}
                            data-test="reset-password-button"
                        >
                            {processing ? 'Resetting...' : 'Reset password'}
                        </button>
                    </>
                )}
            </Form>
        </>
    );
}

ResetPassword.layout = {
    title: 'Reset password',
    description: 'Please enter your new password below',
};