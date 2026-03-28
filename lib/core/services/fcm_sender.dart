import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

class FcmSender {
  static const _serviceAccount = {
    "type": "service_account",
  "project_id": "sehha-app-84ede",
  "private_key_id": "d18bb8c4a52c79063499940ece697d757a30ad19",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDVtS9CZObwqTra\nHv33z23RreS+jC/n3jG9IIwepIo2yquPRhHMZm5iSxkaL5k01EAqvnUj/oGWOYXi\nKGdmA1CD+kd8RLlo47tBDxT3SHMs7hlz1mk93oc/IGk5Gx6PDkmSxAF+tKDPQXNP\nssvk9B8rXaRo3TFi2NO3r6G4fp8OTp9FMCy04gSu/yO43Dx4GuK8vUHjhi1BjDNG\nKjeyWcIiWJMSXJS2ujqdPWzWaKFAX0oCrdVjhH8SRVLzlL7b5077qqjZZdVMWtYM\nkRKycm/4Yr+gMj+fmoATwmxNBbN47y9DVvHP7ztEDo9gUCP0uiCY7lCLHgvhBfHM\ncZqrRZXxAgMBAAECggEAFSxqARM4nMHt//88fNL80UUZxsjih8yVJphII1KvrWIP\n9JZyqP4oRzpww3SePB4gOJvwkZ8wfUI4KGiF/66p/LyzwtvKqvPCCve3K6qH9TAN\nLlO6zzoLy46NUYhR7MaNNfdcvPShTvRWVaBXYNkD3yrcYTwytzwLlF8LkAxeyFUf\nfohbmE/DsqyPWRJPTKzxv+zB72mbWlHaQPpy6xBwMRlW8ZA5L+B5BwlQ9cs0POZb\naw6QlGzSI1flo0ioqdNX6pvyMMDenRlIHzP3ihXDQ8XDHOndnaL3DoyQ2J3JtEXs\nsBV+PLNz5vXEWkt35ja18cmQ3y9qmh4k000cbHBYCQKBgQDrx0wp4cwiwhOjebSu\n+dyFXHhXVaEgkVxUd8X1ZGJncDnxSxXItgksjqg39zWKvmE+zXsV900Z0n0F4P3k\njrjGJY5FCafA9kvMlpDWovwNegRJC84sGZlw7jjcxMXoIWH+z7QElx6WK3gf/EPA\nImuSv7d8n2Zhhfw7vtMtCHZk2wKBgQDoCU5snf8H6ipsfDcKUumxWbRa4TY0guDq\nylu3LpfEnKSliyE31hv9T/wTnaLBqMOSET4VziBlWmK3lhYjJDHDB+M05hAkR/7n\nMErgv4C1WoOZV6b8F7MACsInGglr2aPUQggUq/NlDVs+nFb95QCQQerB2ZH3icyU\nY75Df+UkIwKBgEt7aVm7LPQvt8PNMdgWq8+SFAC5rDTV9H4iPiDae1psJlCmXhn8\nlSFLpnUMUnrRiiZl+DLHEkrjBR19syqZunPNECfv+GGhOBEOXt4oHZNe7cJI4j9i\nDqqFyXR8FnPDRDEkY5hYnPUsg2+R/kqjelbnw6FFEqzEDUU/STIQlH6jAoGBAL8F\n0lNnKuqYI77V7/YG1i7UG79pgtduG74PQ7wllnodPwqt5HX0RWygKXT4pGHsDr00\nhrkqzc7Cv1xGKglaJcFav/jvocBMqRQo1Kv72/jxAEAAQg9tb0aMlNPeAn2QWehH\nSCHEgYbinQiJarBwk6svKRXXiOyRvCM5jgxBwSGjAoGBALa+w4/t6iIuPnCMxQmZ\neKGAkdmoNn2LlK6ucvEc+qBBXBjZ0cWDU9f8q67FVN7dZMjIfp5Zj+Srei1Pd6xy\nGEAMlcuX5SV+jh7CUjGbnYmMxm6Blt+mzsCKDRzKQJtwIg3glBbqSCex9ZkeWOuL\nxVsceis7ICpyBf7CFouywuCR\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@sehha-app-84ede.iam.gserviceaccount.com",
  "client_id": "100361634737814800544",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  static const _projectId = 'sehha-app-84ede';

  static Future<void> send({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'high_importance_channel',
                'sound': 'default',
                'icon': 'launcher_icon',
                'color': '#2FB7B0',
              },
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'badge': 1,
                },
              },
            },
          },
        }),
      );

      print('FCM Status: ${response.statusCode}');
      print('FCM Body: ${response.body}');
    } catch (e) {
      print('FCM Error: $e');
    }
  }

  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      _serviceAccount,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final token = client.credentials.accessToken.data;
    client.close();

    return token;
  }
}