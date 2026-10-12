import { createInertiaApp } from '@inertiajs/react';
// Toastershows notifications like success or error messages
import { Toaster } from '@/components/ui/sonner'; 
// Enables small informational popups when hovering 
import { TooltipProvider } from '@/components/ui/tooltip';
import { initializeTheme } from '@/hooks/use-appearance'; // Apperance settings light/dark mode
import AuthLayout from '@/layouts/auth-layout';
import BooksLayout from '@/layouts/books-layout';
import SettingsLayout from '@/layouts/settings/layout';

const appName = import.meta.env.VITE_APP_NAME || 'BookLib';

void createInertiaApp({
    title: (title) => appName,
    layout: (name) => {
        switch (true) {
            case name === 'welcome':
                return null;
            case name.startsWith('auth/'):
                return AuthLayout;
            case name.startsWith('settings/'):
                return [BooksLayout, SettingsLayout];
            default:
                return BooksLayout;
        }
    },
    strictMode: true, // to detect potential problems in the application
    withApp(app) {  // app - the current page
        return (
            <TooltipProvider delayDuration={0}>
                {app}
                <Toaster />
            </TooltipProvider>
        );
    },
    progress: { // during inertia navigation
        color: '#4B5563',
    },
});

// This will set light / dark mode on load...
initializeTheme();