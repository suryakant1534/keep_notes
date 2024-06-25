import 'dart:io';

class CheckNetwork {
  static Future<bool> isInternetAvailable() async {
    HttpClient client = HttpClient();

    try {
      Uri url = Uri.parse("https://www.google.com");

      final HttpClientRequest request = await client.getUrl(url);

      final HttpClientResponse response = await request.close();
      request.close();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      client.close();
    }
  }

  CheckNetwork._();
}
