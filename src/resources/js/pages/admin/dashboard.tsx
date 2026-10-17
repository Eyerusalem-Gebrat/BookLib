import { Head } from '@inertiajs/react';
import { Activity, Globe, Smartphone, Users } from 'lucide-react';
import '../../../css/admin.css';

type DashboardUser = {
    id: number;
    name: string;
    email: string;
    web_requests_count: number;
    app_requests_count: number;
    total_requests_count: number;
};

type Props = {
    users: DashboardUser[];
    totals: {
        users: number;
        web_requests: number;
        app_requests: number;
        all_requests: number;
    };
};

function getInitials(name: string): string {
    const parts = name.trim().split(/\s+/).filter(Boolean);
    if (parts.length >= 2) {
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return (name[0] || '?').toUpperCase();
}

export default function AdminDashboard({ users, totals }: Props) {
    const cards = [
        {
            label: 'Registered Users',
            value: totals.users,
            hint: 'Excludes admin accounts',
            icon: Users,
            iconClass: 'terracotta',
        },
        {
            label: 'Website Requests',
            value: totals.web_requests,
            hint: 'Web platform activity',
            icon: Globe,
            iconClass: 'green',
        },
        {
            label: 'App Requests',
            value: totals.app_requests,
            hint: 'Mobile API requests',
            icon: Smartphone,
            iconClass: 'peach',
        },
        {
            label: 'Total Requests',
            value: totals.all_requests,
            hint: 'Combined across platforms',
            icon: Activity,
            iconClass: 'brown',
        },
    ];

    return (
        <>
            <Head title="Admin Dashboard" />

            <div className="admin-page-header">
                <h1 className="admin-page-title">Admin Dashboard</h1>
                <p className="admin-page-subtitle">
                    Monitor users and platform activity
                </p>
            </div>

            {/* 4 Metric Summary Cards */}
            <div className="admin-metrics-grid">
                {cards.map((card) => {
                    const IconComponent = card.icon;
                    return (
                        <div key={card.label} className="admin-metric-card">
                            <div className="admin-metric-top">
                                <span className="admin-metric-label">
                                    {card.label}
                                </span>
                                <div
                                    className={`admin-metric-icon ${card.iconClass}`}
                                >
                                    <IconComponent
                                        size={18}
                                        aria-hidden="true"
                                    />
                                </div>
                            </div>
                            <div>
                                <div className="admin-metric-value">
                                    {card.value.toLocaleString()}
                                </div>
                                <p className="admin-metric-hint">{card.hint}</p>
                            </div>
                        </div>
                    );
                })}
            </div>

            {/* Per-user Activity Table Section */}
            <section className="admin-section">
                <div className="admin-section-header">
                    <h2 className="admin-section-title">User Activity</h2>
                    <p className="admin-section-desc">
                        Website and mobile API requests attributed to each
                        regular user.
                    </p>
                </div>

                {users.length === 0 ? (
                    <div className="admin-empty-state">
                        <Users
                            className="admin-empty-icon"
                            aria-hidden="true"
                        />
                        <h3 className="admin-empty-title">
                            No regular users found
                        </h3>
                        <p className="admin-empty-desc">
                            When users register and interact with the website or
                            mobile app, their requests will appear here.
                        </p>
                    </div>
                ) : (
                    <div className="admin-table-container">
                        <table className="admin-table">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Email</th>
                                    <th className="num-col">
                                        Website Requests
                                    </th>
                                    <th className="num-col">App Requests</th>
                                    <th className="num-col">Total Requests</th>
                                </tr>
                            </thead>
                            <tbody>
                                {users.map((user) => (
                                    <tr key={user.id}>
                                        <td>
                                            <div className="admin-user-cell">
                                                <div
                                                    className="admin-avatar"
                                                    aria-hidden="true"
                                                >
                                                    {getInitials(user.name)}
                                                </div>
                                                <span className="admin-user-name">
                                                    {user.name}
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <span className="admin-user-email">
                                                {user.email}
                                            </span>
                                        </td>
                                        <td className="num-col">
                                            <span className="admin-count-pill">
                                                {user.web_requests_count.toLocaleString()}
                                            </span>
                                        </td>
                                        <td className="num-col">
                                            <span className="admin-count-pill">
                                                {user.app_requests_count.toLocaleString()}
                                            </span>
                                        </td>
                                        <td className="num-col">
                                            <span className="admin-count-pill total">
                                                {user.total_requests_count.toLocaleString()}
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </section>
        </>
    );
}
