part of '../main.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _createEvent() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.createEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        time: _timeController.text,
        location: _locationController.text,
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
        category: _categoryController.text,
        imageUrl: _imageUrlController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal membuat event';
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

        // Debugging
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
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Event Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nama Event', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Contoh: Konser Musik Indie'),
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Jelaskan tentang acaramu'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  _dateController.text = picked.toIso8601String().split('T').first;
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                hintText: 'HH:MM:SS (Contoh: 14:00:00)',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Contoh: GBK, Jakarta'),
            ),
            const SizedBox(height: 16),
            const Text('Jumlah Peserta Maksimal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _maxParticipantsController,
              decoration: const InputDecoration(hintText: 'Contoh: 100'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(hintText: 'Contoh: Workshop, Seminar, Konser'),
            ),
            const SizedBox(height: 16),
            const Text('URL Gambar Event', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(hintText: 'Contoh: https://example.com/event.jpg'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createEvent,
                    child: const Text('PUBLIKASIKAN EVENT'),
                  ),
          ],
        ),
      ),
    );
  }
}