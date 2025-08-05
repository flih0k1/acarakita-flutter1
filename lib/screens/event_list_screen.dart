part of '../main.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Event>> _eventsFuture;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryFilterController = TextEditingController();
  final TextEditingController _dateFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = _apiService.getEvents(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        category: _categoryFilterController.text.isNotEmpty ? _categoryFilterController.text : null,
        date: _dateFilterController.text.isNotEmpty ? _dateFilterController.text : null,
      );
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryFilterController.dispose();
    _dateFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari event berdasarkan nama...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadEvents();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadEvents(),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _categoryFilterController,
                        decoration: InputDecoration(
                          hintText: 'Filter kategori...',
                          prefixIcon: const Icon(Icons.category),
                          suffixIcon: _categoryFilterController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _categoryFilterController.clear();
                                    _loadEvents();
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _loadEvents(),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dateFilterController,
                        decoration: InputDecoration(
                          hintText: 'Filter tanggal (YYYY-MM-DD)',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: _dateFilterController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _dateFilterController.clear();
                                    _loadEvents();
                                  },
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            _dateFilterController.text = picked.toIso8601String().split('T').first;
                            _loadEvents();
                          }
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loadEvents,
                  child: const Text('Terapkan Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadEvents(),
              child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Gagal memuat event: ${snapshot.error.toString().replaceFirst("Exception: ", "")}\n\nPastikan token Anda valid. Coba logout dan login kembali.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada event. Jadilah yang pertama!'));
                  }

                  final events = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (event.imageUrl.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      event.imageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  event.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.description,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const Divider(color: Colors.white30, height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('${event.date} at ${event.time}', style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(event.location, style: const TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 16, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('Peserta: ${event.currentParticipants}/${event.maxParticipants}', style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.category, size: 16, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('Kategori: ${event.category}', style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Dibuat pada: ${event.createdAt.split('T').first}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
          if (result == true) {
            _loadEvents();
          }
        },
        label: const Text('Buat Event'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}
