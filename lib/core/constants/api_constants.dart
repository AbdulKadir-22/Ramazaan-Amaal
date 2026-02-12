class ApiConstants {
  // Replace with your actual machine IP if testing on a real device, 
  // or use 'http://10.0.2.2:5000' for Android Emulator.
  // 'http://localhost:5000' only works for iOS Simulator.
  static const String baseUrl = 'https://ramanzaan-amaal-backend.onrender.com'; 
  static const String registerDevice = '$baseUrl/api/register-device';
  static const String sendNotification = '$baseUrl/api/send-notification';
  
  // Header Keys
  static const String adminKey = 'my_super_secret_admin_key_123'; 
}