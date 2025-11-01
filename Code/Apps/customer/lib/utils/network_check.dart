

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class NetworkCheck {
    final Connectivity _connectivity = Connectivity();
    // Platform messages are asynchronous, so we initialize in an async method.
    Future<List<ConnectivityResult>?> initConnectivity() async {
        late List<ConnectivityResult> result;
        // Platform messages may fail, so we use a try/catch PlatformException.
        try {
            result = await _connectivity.checkConnectivity();
        } on PlatformException catch (e) {
            print('Couldn\'t check connectivity status: ${e.toString()}');
            return null;
        }

        return result;
    }

    //check if the device is connected to the internet
    static Future<bool> isConnect() async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
            return true;
        }
        else {
            return false;
        }
    }

// static Future<bool> isConnect() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//         return true;
//     }
//     else {
//         return false;
//     }
// }
}
