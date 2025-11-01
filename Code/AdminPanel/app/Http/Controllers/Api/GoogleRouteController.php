<?php

namespace App\Http\Controllers\Api;

use App\Repository\PlaceRepositoryInterface;
use App\Repository\UserRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use App\Services\GoogleRoutesService;


class GoogleRouteController extends Controller
{
    protected $googleRoutesService;

    public function __construct(GoogleRoutesService $googleRoutesService)
    {
        $this->googleRoutesService = $googleRoutesService;
    }

    public function getRoute(Request $request)
    {
        //validate the request
        $request->validate([
            'origin_lat' => 'required|numeric',
            'origin_lng' => 'required|numeric',
            'destination_lat' => 'required|numeric',
            'destination_lng' => 'required|numeric',
        ]);
        $origin = [
            'latitude' => $request->origin_lat,
            'longitude' => $request->origin_lng
        ];
        $destination = [
            'latitude' => $request->destination_lat,
            'longitude' => $request->destination_lng
        ];
        //check if waypoints are provided
        if ($request->has('waypoints')) {
            $waypoints = $request->waypoints;
        } else {
            $waypoints = [];
        }


        $route = $this->googleRoutesService->computeRoutes($origin, $destination, $waypoints);

        return response()->json($route);
    }
}

