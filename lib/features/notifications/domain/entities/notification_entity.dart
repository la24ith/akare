// lib/features/notifications/domain/entities/notification_entity.dart
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? relatedPropertyId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedPropertyId,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    relatedPropertyId,
    isRead,
    createdAt,
  ];
}
