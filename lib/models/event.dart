// =============================================================================
// | models/event.dart                                                       |
// =============================================================================
part of '../main.dart';

class Event {
  final int id;
  final String name;
  final String description;
  final String date;
  final String time;
  final String location;
  final int maxParticipants;
  final int currentParticipants;
  final String category;
  final String createdAt;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.category,
    required this.createdAt,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? (json['start_date'] != null
          ? json['start_date'].toString().split('T').first
          : ''),
      time: json['time'] ?? (json['start_date'] != null
          ? json['start_date'].toString().split('T')[1].substring(0, 8)
          : ''),
      location: json['location'] ?? '',
      maxParticipants: json['max_attendees'] ?? json['max_participants'] ?? 0,
      currentParticipants: json['registrations_count'] ?? json['current_participants'] ?? 0,
      category: json['category'] ?? '',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}