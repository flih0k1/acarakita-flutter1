// =============================================================================
// | services/api_service.dart                                               |
// =============================================================================
part of '../main.dart';

class ApiService {
  // PENTING: Pastikan IP address ini sesuai dengan server API kamu.
  // Jika server kamu menggunakan 103.160.63.105, ubah baris di bawah ini.
  final String _baseUrl = 'http://103.160.63.165/api';

  // Mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Registrasi Pengguna
  Future<Map<String, dynamic>> register(String name,
      String email,
      String studentNumber,
      String major,
      int classYear,
      String password,
      String passwordConfirmation,) async {
    final url = Uri.parse('$_baseUrl/register');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = {
      'name': name,
      'email': email,
      'student_number': studentNumber,
      'major': major,
      'class_year': classYear.toString(), // Convert to string
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Login Pengguna
  Future<String> login(String studentNumber, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'student_number': studentNumber,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true && responseBody['data'] != null &&
            responseBody['data']['token'] != null) {
          return responseBody['data']['token'];
        } else {
          throw Exception(
              responseBody['message'] ?? 'Respons login tidak valid.');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Login gagal.');
      }
    } catch (e) {
      throw Exception(
          'Gagal terhubung ke server atau format respons tidak sesuai: $e');
    }
  }

  // Mendapatkan Daftar Event dengan filter opsional
  Future<List<Event>> getEvents({
    String? search,
    String? category,
    String? date,
    int? limit,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (limit != null && limit > 0) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$_baseUrl/events').replace(
        queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Perhatikan struktur response yang sebenarnya dari API
        if (responseBody['success'] == true) {
          if (responseBody['data'] != null &&
              responseBody['data']['events'] is List) {
            final List<dynamic> eventData = responseBody['data']['events'];
            return eventData.map((json) =>
                Event.fromJson({
                  'id': json['id'],
                  'name': json['title'],
                  'description': json['description'],
                  'date': json['start_date']
                      .toString()
                      .split('T')
                      .first,
                  'time': json['start_date'].toString().split('T')[1].substring(
                      0, 8),
                  'location': json['location'],
                  'max_participants': json['max_attendees'],
                  'current_participants': json['registrations_count'],
                  'category': json['category'],
                  'created_at': json['created_at'],
                  'image_url': '', // Sesuaikan jika API menyediakan field ini
                })).toList();
          } else {
            return []; // Return empty list if no events
          }
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to load events');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Waktu koneksi habis, coba lagi');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Membuat Event Baru
  Future<void> createEvent({
    required String name,
    required String description,
    required String date,
    required String time,
    required String location,
    required int maxParticipants,
    required String category,
    required String imageUrl,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('$_baseUrl/events');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Gabungkan tanggal dan waktu dengan format yang benar
      final startDateTime = DateTime.parse('$date ${time.padLeft(8, '0')}');
      final endDateTime = startDateTime.add(const Duration(hours: 2)); // Default durasi 2 jam

      final body = {
        'title': name,
        'description': description,
        'start_date': startDateTime.toIso8601String(),
        'end_date': endDateTime.toIso8601String(),
        'location': location,
        'max_attendees': maxParticipants,
        'category': category,
        'price': 0, // Default harga 0
        'status': 'active', // Default status aktif
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create event. Status: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Format tanggal/waktu tidak valid. Pastikan format: YYYY-MM-DD untuk tanggal dan HH:MM:SS untuk waktu');
    } catch (e) {
      throw Exception('Gagal membuat event: ${e.toString()}');
    }
  }
}
