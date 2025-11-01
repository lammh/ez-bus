<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AuthSetting;
use Validator;
use DB;

class ActivationController extends Controller
{
    /**
     * Return a secure_key to indicate the system is activated.
     * If no AuthSetting exists, create a dummy one (safe).
     */
    public function load(Request $request)
    {
        // ensure a row exists with safe defaults
        $authSetting = AuthSetting::first();
        if (!$authSetting) {
            // create a dummy row (safe defaults)
            try {
                AuthSetting::create([
                    'secure_key' => 'NO_LICENSE_NEEDED',
                    'u1' => 'DUMMY_U1',
                    'u2' => 'DUMMY_U2',
                    'u3' => 'DUMMY_U3'
                ]);
                $authSetting = AuthSetting::first();
            } catch (\Exception $e) {
                // ignore failure and continue returning a default value
            }
        }

        // always return a non-null secure_key to indicate activation not required
        return response()->json(['secure_key' => $authSetting->secure_key ?? 'NO_LICENSE_NEEDED']);
    }

    /**
     * Activation endpoint should gracefully accept any request,
     * but we will not validate or call external services.
     * Just ensure dummy data is present.
     */
    public function activate(Request $request)
    {
        // If an activation code is passed, ignore validation and just create dummy row.
        DB::beginTransaction();
        try {
            // delete previous and create a safe dummy row
            AuthSetting::query()->delete();
            AuthSetting::create([
                'secure_key' => 'NO_LICENSE_NEEDED',
                'u1' => 'DUMMY_U1',
                'u2' => 'DUMMY_U2',
                'u3' => 'DUMMY_U3'
            ]);
            DB::commit();
            return response()->json(['success' => ['activated successfully']]);
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(['errors' => ['Error' => [$e->getMessage()]]], 422);
        }
    }
}
