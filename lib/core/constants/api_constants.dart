class ApiConstants {
  // Replace with your actual machine IP if testing on a real device, 
  // or use 'http://10.0.2.2:5000' for Android Emulator.
  // 'http://localhost:5000' only works for iOS Simulator.
  static const String baseUrl = 'http://10.0.2.2:5000'; 
  static const String registerDevice = '$baseUrl/api/register-device';
}