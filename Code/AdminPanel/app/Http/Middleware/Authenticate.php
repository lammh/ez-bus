<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Auth\Middleware\Authenticate as Middleware;

//AuthSec
use App\Traits\AuthSec;

//Log
use Illuminate\Support\Facades\Log;
class Authenticate extends Middleware
{
    use AuthSec;
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        if (! $request->expectsJson()) {
            return url(env('SPA_URL') . '/login');
        }
    }

    //handle

public function handle($request, Closure $next, ...$guards)
{
    // Retrieve bearer token but don't overwrite $request
    $token = $this->get_bearer($request);

    if ($token === null) {
        return response()->json(['error' => ['Unauthorized']], 401);
    }

    // Authenticate via Sanctum
    $user = auth('sanctum')->user();

    // Optional: you can check that the user is authenticated
    if (!$user) {
        return response()->json(['error' => ['Unauthenticated']], 401);
    }

    // Check if user is suspended
    if (($user->role == 1 && $user->status_id != 1) ||
        ($user->role == 2 && $user->status_id == 3)) {
        return response()->json(['error' => ['Unauthorized']], 401);
    }

    // Proceed with normal auth pipeline
    $this->authenticate($request, $guards);
    return $next($request);
}
}
