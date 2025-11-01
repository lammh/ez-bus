
import 'dart:convert';
import 'dart:io';

import 'package:ezbus/connection/response/auth_response.dart';
import 'package:ezbus/connection/response/devices_response.dart';
import 'package:ezbus/connection/response/notifications_response.dart';
import 'package:ezbus/connection/response/pay_response.dart';
import 'package:ezbus/connection/response/places_response.dart';
import 'package:ezbus/connection/response/reservations_response.dart';
import 'package:ezbus/connection/response/routes_response.dart';
import 'package:ezbus/connection/response/stops_response.dart';
import 'package:ezbus/connection/response/trip_search_response.dart';
import 'package:ezbus/model/constant.dart';
import 'package:ezbus/model/reservation.dart';
import 'package:ezbus/model/route_details.dart';
import 'package:ezbus/model/trip.dart';
import 'package:ezbus/model/user.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../model/place.dart';
import '../model/seat.dart';
import '../utils/config.dart';
import 'response/payments_response.dart';


class AllApis {

    bool localTest = false;
    Future<AuthResponse?> loginViaToken(String token, String deviceName,
        String firebaseToken) async { // login via token
        final params = {
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        // check if http or https
        final uri = getFullUrl('api/auth/loginViaToken');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }


    Future<AuthResponse?> verifyUser(String token, String deviceName) async {

        final uri = getFullUrl('api/auth/verify-user');

        final params = {
            'device_name': deviceName,
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<AuthResponse?> createUser(String name, String token,
        String deviceName, String firebaseToken) async { // create user
        final params = {
            'name': name,
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        final uri = getFullUrl('api/auth/createCustomer');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try
        {
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }


    Future<DevicesResponse> getAllDevices(String token) async { // get all devices of user including current device
        final uri = getFullUrl('api/users/devices');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var devices = body["devices"];
                // then parse the JSON.
                return DevicesResponse.fromJson(devices);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<String> deleteDevices(String token, int id) async { // deauthorize device
        final params = {
            'token_id': id.toString(),
        };

        final uri = getFullUrl('api/users/revoke-token');

        if(localTest) {
          await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //upload-avatar
    Future<String?> uploadAvatar(String? token, String? avatarLocalFilePath) async {
        final uri = getFullUrl('api/users/upload-avatar');

        File uploadImage = File(avatarLocalFilePath!);
        List<int> imageBytes = uploadImage.readAsBytesSync();
        String avatarBase64 = base64Encode(imageBytes);

        final params = {
            'avatar': avatarBase64
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            //get avatar_url
            var body = jsonDecode(resp.body);
            var avatarUrl = body["avatar_url"];
            return avatarUrl;
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<DbUser> updateProfile(String? token, String? address, String? telNumber) async {
        final uri = getFullUrl('api/users/update-profile');

        final params = {
            'address': address.toString(),
            'tel_number': telNumber.toString(),
        };

        if(localTest) {
          await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["user"];
            return DbUser.fromJson(user);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> getTerms() async {
        final uri = getFullUrl('api/docs/terms');

        Response resp = await http.get(uri).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var body = jsonDecode(resp.body);
            var terms = body["terms"];
            // then parse the JSON.
            return terms;
        } else {
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception('Failed to load ResponseInfo ');
        }
    }

    Future<PlacesResponse> getFavoritesOrRecentPlaces(String token, bool fav) async {
        final uri = fav ? getFullUrl('api/places/favorite-places') : getFullUrl('api/places/recent-places');

        if(localTest) {
          await Future.delayed(const Duration(seconds: 3));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var places = fav? body["favorite_places"] : body["recent_places"];
                // then parse the JSON.
                return PlacesResponse.fromJson(places);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<StopsResponse> getStops(String token) async {
        final uri = getFullUrl('api/stops/all');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var stops = body;
                // then parse the JSON.
                return StopsResponse.fromJson(stops);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<RoutesResponse> getRoutes(String token) async {
        final uri = getFullUrl('api/routes/all');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var routes = body;
                // then parse the JSON.
                return RoutesResponse.fromJson(routes);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }
    //Get RouteDetails
    Future<RouteDetails> getRouteDetails(String token, int? id) async {
        final uri = getFullUrl('api/routes/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return RouteDetails.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    // getTripDetails
    Future<Trip> getPlannedTripDetails(String token, int? id) async {

        final uri = getFullUrl('api/planned-trips/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var trip = body["trip"];
                // then parse the JSON.
                return Trip.fromJson(trip);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //get trip search results
    Future<TripSearchResponse> getTripSearchResults(String? token,
        String? startAddress, String? destinationAddress,
        double? startLat,
        double? startLng, double? endLat, double? endLng, DateTime? date) async {
        final params = {
            'start_address': startAddress.toString(),
            'destination_address': destinationAddress.toString(),
            'start_lat': startLat.toString(),
            'start_lng': startLng.toString(),
            'end_lat': endLat.toString(),
            'end_lng': endLng.toString(),
            'date': date.toString(),
        };
        Uri uri;
        if(token == null) {
            uri = getFullUrl('api/trips/search-by-guest', params);
        }
        else {
            uri = getFullUrl('api/trips/search-by-customer', params);
        }

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                // var details = body;
                // then parse the JSON.
                return TripSearchResponse.fromJson(body);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }


    Future<PayResponse> payForTrip(String token, int tripSearchResultID,
        PayMethod paymentMethod, {String? promoCode, Seat? seat}) async {
        final params = {
            'trip_search_result_id': tripSearchResultID.toString(),
            'payment_method': paymentMethod.index.toString(),
        };
        if(promoCode != null) {
            params['coupon_code'] = promoCode;
        }
        if(seat != null) {
            params['seat_number'] = seat.seatNumber.toString();
            params['row'] = seat.row.toString();
            params['column'] = seat.column.toString();
        }

        final uri = getFullUrl('api/trips/pay');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PayResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendNonceForTrip(String token, String nonce, String amount) async {
        final params = {
            'nonce': nonce,
            'amount': amount,
        };

        final uri = getFullUrl('api/users/nonce');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendRazorPayPaymentID(String token, String? paymentID) async {
        final params = {
            'paymentId': paymentID,
        };

        final uri = getFullUrl('api/users/capture-razorpay-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendPaytabsTransRef(String token, String? tranRef) async {
        final params = {
            'tran_ref': tranRef,
        };

        final uri = getFullUrl('api/users/capture-paytabs-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendFlutterwaveTransactionID(String token, String? transactionID) async {
        final params = {
            'transactionId': transactionID,
        };

        final uri = getFullUrl('api/users/verify-transaction');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //apply promo code
    Future<double> applyPromoCode(String? token, String? promoCode, int? tripSearchResultID, double? price) async {
        final uri = getFullUrl('api/coupons/apply-coupon');

        final params = {
            'coupon_code': promoCode,
            'trip_search_result_id': tripSearchResultID.toString(),
            'price': price.toString(),
        };

        if (localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var body = jsonDecode(resp.body);
            var discount = body["discount"];
            // then parse the JSON.
            return discount;
        }
        else {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["error"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }


    Future<String> requestDeleteAccount(String token) async {
        final uri = getFullUrl('api/users/request-delete-driver');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //getPayments
    Future<PaymentsResponse> getWalletCharges(String token) async {
        final uri = getFullUrl('api/users/wallet-charges');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                // then parse the JSON.
                return PaymentsResponse.fromJson(body);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    //getReservationDetails
    Future<Reservation> getReservationDetails(String token, int? id) async {
        final uri = getFullUrl('api/reservations/reservation/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                return http.Response('Error: time out',
                    500);
            },
        );
        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var reservation = body["reservation"];
                // then parse the JSON.
                return Reservation.fromJson(reservation);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else
            if (resp.statusCode == 404 && resp.reasonPhrase == "Not Found") {
                throw Exception("not found");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch (e) {
            throw Exception(e.toString());
        }
    }

    Future<ReservationsResponse> getReservations(String token) async {
        final uri = getFullUrl('api/users/reservations');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var reservations = body["reservations"];
                // then parse the JSON.
                return ReservationsResponse.fromJson(reservations);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<Place> createEditPlace(String token, Place place) async {
        final params = {
            'place': place.toJson(),
        };
        if(localTest) {
          await Future.delayed(const Duration(seconds: 3));
        }
        //token = token+"11";
        final uri = getFullUrl('api/places/add-edit-place');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var place = body["place"];
            return Place.fromJson(place);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> deletePlace(String token, int id) async {
        final params = {
            'id': id,
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 3));
            return "";
        }

        final uri = getFullUrl('api/places/delete-place');

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    getFullUrl(String s, [Map<String, String>? params]) {
        Uri uri;
        String webUrl = Config.webUrl;
        String? path;
        //get substring from first / if exists
        if (webUrl.contains("/")) {
            path = "${webUrl.substring(webUrl.indexOf("/"))}/";
            webUrl = webUrl.substring(0, webUrl.indexOf("/"));
        }
        if(path != null) {
            s = path + s;
        }

        if (Config.serverUrl.startsWith("https")) {
            uri = Uri.https(
                webUrl, s, params);
        } else {
            uri = Uri.http(
                webUrl, s, params);
        }
        return uri;
    }

    Future<void> createComplaint(String? token, String? complaint, int? reservationId,
        double? customerLat, double? customerLng) async {
        final uri = getFullUrl('api/complaints/create');

        final params = {
            'reservation_id': reservationId.toString(),
            'complaint': complaint,
            'customer_lat': customerLat.toString(),
            'customer_lng': customerLng.toString()
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode != 200) {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }

    //To be included in the next release
    /// ********************************************************************
    Future<NotificationsResponse> getNotifications(String token) async
    {
        Uri uri = getFullUrl('api/notifications/list-all');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            var body = jsonDecode(resp.body);
            // If the server did return a 200 OK response,
            var notifications = body["notifications"];
            // then parse the JSON.
            return NotificationsResponse.fromJson(notifications);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markNotificationAsSeen(String token, int id) async {
        final params = {
            'id': id.toString(),
        };

        Uri uri = getFullUrl('api/notifications/mark-as-seen');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markAllNotificationAsSeen(String token) async {
        //token = token+"11";
        Uri uri = getFullUrl('api/notifications/mark-all-as-seen');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },)
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }
/// ********************************************************************
}
