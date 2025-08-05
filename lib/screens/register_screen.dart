part of '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _majorController = TextEditingController();
  final _classYearController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _studentNumberController.text,
        _majorController.text,
        int.tryParse(_classYearController.text) ?? 0,
        _passwordController.text,
        _passwordConfirmationController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registrasi Gagal';
        if (e is http.ClientException) {
          errorMessage = 'Gagal terhubung ke server: ${e.message}';
        } else if (e is TimeoutException) {
          errorMessage = 'Waktu koneksi habis, coba lagi';
        } else if (e is FormatException) {
          errorMessage = 'Format data tidak valid';
        } else {
          errorMessage = 'Error: ${e.toString().replaceFirst("Exception: ", "")}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );

      
        print('Error details: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentNumberController.dispose();
    _majorController.dispose();
    _classYearController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Satu Langkah Lagi!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Isi data di bawah untuk bergabung',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Nama Lengkap'),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentNumberController,
              decoration: const InputDecoration(hintText: 'Nomor Mahasiswa'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _majorController,
              decoration: const InputDecoration(hintText: 'Jurusan'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _classYearController,
              decoration: const InputDecoration(hintText: 'Angkatan (Tahun)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordConfirmationController,
              decoration: const InputDecoration(hintText: 'Konfirmasi Password'),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('DAFTAR'),
                  ),
          ],
        ),
      ),
    );
  }
}