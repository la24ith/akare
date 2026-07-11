import "package:equatable/equatable.dart";

enum PropertyStatusFilter { all, pending, active, rejected, sold, rented }

class MyPropertyEntity extends Equatable {
  final String id;
  final String title;
  final double price;
  final String listingType; // sale | rent
  final String status; // pending | active | rejected | sold | rented
  final String? rejectionReason;
  final int viewsCount;
  final String? primaryImageUrl;
  final String cityName;
  final String propertyTypeName;
  final DateTime createdAt;

  const MyPropertyEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.listingType,
    required this.status,
    this.rejectionReason,
    required this.viewsCount,
    this.primaryImageUrl,
    required this.cityName,
    required this.propertyTypeName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        listingType,
        status,
        rejectionReason,
        viewsCount,
        primaryImageUrl,
        cityName,
        propertyTypeName,
        createdAt,
      ];
}
