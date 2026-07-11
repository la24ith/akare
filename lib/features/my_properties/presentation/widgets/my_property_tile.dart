import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "../../domain/entities/my_property_entity.dart";
import "status_badge.dart";

class MyPropertyTile extends StatelessWidget {
  final MyPropertyEntity property;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewAsUser;
  final VoidCallback? onMarkSold;
  final VoidCallback? onMarkRented;

  const MyPropertyTile({
    super.key,
    required this.property,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onViewAsUser,
    this.onMarkSold,
    this.onMarkRented,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("تعديل"),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined),
              title: const Text("عرض كمستخدم"),
              onTap: () {
                Navigator.pop(context);
                onViewAsUser();
              },
            ),
            if (property.status == "active" &&
                property.listingType == "sale" &&
                onMarkSold != null)
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: const Text("تحديد كمباع"),
                onTap: () {
                  Navigator.pop(context);
                  onMarkSold!();
                },
              ),
            if (property.status == "active" &&
                property.listingType == "rent" &&
                onMarkRented != null)
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text("تحديد كمؤجر"),
                onTap: () {
                  Navigator.pop(context);
                  onMarkRented!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("حذف", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptions(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: property.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: property.primaryImageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_outlined),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${property.price.toStringAsFixed(0)} \$",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE7A94C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusBadge(status: property.status),
                          const SizedBox(width: 8),
                          Icon(Icons.remove_red_eye_outlined,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 2),
                          Text("${property.viewsCount}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptions(context),
                ),
              ],
            ),
            if (property.status == "rejected" &&
                property.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD64545).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "سبب الرفض: ${property.rejectionReason}",
                  style: const TextStyle(color: Color(0xFFD64545), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
