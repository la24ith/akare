// lib/features/notifications/data/models/notification_model.dart
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.relatedPropertyId,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromSupabase(Map<String, dynamic> row) {
    return NotificationModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      body: row['body'] ?? '',
      type: row['type'] ?? 'property_status',
      relatedPropertyId: row['related_property_id']?.toString(),
      isRead: row['is_read'] ?? false,
      createdAt: DateTime.parse(row['created_at']),
    );
  }
}
