<?php

namespace App\Traits;

use App\Models\AuthSetting;
use Illuminate\Support\Facades\Log;

/**
 * AuthSec trait: simplified safe no-op implementations
 * to remove dependency on external BtcId activation / encryption.
 *
 * We keep method names and signatures so existing callers keep working.
 */
trait AuthSec
{
    /**
     * Return the bearer token from the request (no external calls).
     * If no bearer token present, return null.
     */
    public function get_bearer($request)
    {
        try {
            // prefer HTTP Authorization Bearer token
            $token = $request->bearerToken();
            return $token ?: null;
        } catch (\Throwable $e) {
            Log::warning('AuthSec::get_bearer fallback: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Previously would encode/transform token using secure keys.
     * Now just return the same value (no-op) so existing code that
     * expects a "secure id" will still get a usable token string.
     */
    public function get_sec_id($id)
    {
        try {
            // If null or empty, return null
            if ($id === null || $id === '') {
                return null;
            }
            return $id;
        } catch (\Throwable $e) {
            Log::warning('AuthSec::get_sec_id fallback: ' . $e->getMessage());
            return $id;
        }
    }

    /**
     * Previously would decode a secure id back to original id.
     * Now return the input unchanged.
     */
    public function get_id($sec_id)
    {
        try {
            if ($sec_id === null || $sec_id === '') {
                return null;
            }
            return $sec_id;
        } catch (\Throwable $e) {
            Log::warning('AuthSec::get_id fallback: ' . $e->getMessage());
            return $sec_id;
        }
    }
}
