<?php

namespace App\Http\Middleware;

use App\Enums\Platform;
use App\Models\RequestLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class LogRequest
{
    // Runs BEFORE the request is handled
    public function handle(Request $request, Closure $next): Response
    {
        // On the website we note who is logged in right now. This matters for
        // "log out": after it, nobody is logged in any more, so we couldn't tell who it was.
        if (! $request->is('api/*')) {
            $request->attributes->set('log_user_id', $request->user()?->id);
        }

        return $next($request);
    }

    // Runs AFTER the response has been sent to the user
    public function terminate(Request $request, Response $response): void
    {
        $route = $request->route();

        // Ignore the health check and URLs that match no route (bots probing the site)
        if ($route === null || $request->is('up')) {
            return;
        }

        try {
            $isApi = $request->is('api/*');

            // Who made the request: noted earlier, or set by the login controller,
            // or the user the current request belongs to (the app uses the "api" guard)
            $userId = $request->attributes->get('log_user_id')
                ?? $request->user($isApi ? 'api' : null)?->id;

            RequestLog::create([
                'user_id' => $userId,
                'platform' => $isApi ? Platform::App : Platform::Web,
                'method' => $request->method(),
                'route_name' => $route->getName(),
                'route_uri' => $route->uri(), // the pattern, e.g. books/{book}
                'status_code' => $response->getStatusCode(),
                'ip_address' => $request->ip(),
            ]);
        } catch (Throwable $e) {
            // Logging must never break the app
            report($e);
        }
    }
}