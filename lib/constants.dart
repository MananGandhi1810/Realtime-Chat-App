class Constants {
  static const serverIp = '192.168.1.5';
  static const webServerPort = '3000';
  static const webSocketPort = '8080';
  static const String apiBaseUrl = 'http://$serverIp:$webServerPort';
  static const String webSocketBaseUrl = 'ws://$serverIp:$webSocketPort/';
}
