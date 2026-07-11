import "package:equatable/equatable.dart";

class PropertyImageEntity extends Equatable {
  final String? id; // null لو صورة محلية لم تُرفع بعد
  final String? remoteUrl;
  final String? localPath;
  final bool isPrimary;
  final int sortOrder;

  const PropertyImageEntity({
    this.id,
    this.remoteUrl,
    this.localPath,
    required this.isPrimary,
    required this.sortOrder,
  });

  bool get isUploaded => remoteUrl != null;

  PropertyImageEntity copyWith({
    String? id,
    String? remoteUrl,
    bool? isPrimary,
    int? sortOrder,
  }) {
    return PropertyImageEntity(
      id: id ?? this.id,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, remoteUrl, localPath, isPrimary, sortOrder];
}
