// lib/features/property_details/presentation/widgets/share_property_image.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/property_details_entity.dart';
import 'property_share_card.dart';

/// يبني بطاقة PropertyShareCard خارج الشاشة المرئية (بدون ما المستخدم يشوفها
/// وميضة على الشاشة)، يلتقطها كصورة PNG بجودة عالية، ثم يفتح شيت المشاركة
/// الأصلي للنظام (واتساب/انستغرام/إلخ) مع الصورة + نص وصفي.
Future<void> sharePropertyAsImage(
  BuildContext context,
  PropertyDetailsEntity property,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final overlay = Overlay.of(context);
  final boundaryKey = GlobalKey();
  late OverlayEntry entry;

  final completer = Completer<void>();

  entry = OverlayEntry(
    builder: (context) => Positioned(
      // بعيد جدًا عن حدود الشاشة عشان ما يظهر ولا يتفاعل معه المستخدم إطلاقًا
      left: -3000,
      top: -3000,
      child: Material(
        color: Colors.transparent,
        child: RepaintBoundary(
          key: boundaryKey,
          child: PropertyShareCard(
            imageUrl: property.imageUrls.isNotEmpty
                ? property.imageUrls.first
                : null,
            title: property.title,
            price: property.price,
            isForSale: property.isForSale,
            cityName: property.cityName,
            areaSqm: property.areaSqm,
            roomsCount: property.roomsCount,
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  try {
    // فريمين ضروريين لضمان اكتمال تحميل الصورة الشبكية داخل البطاقة قبل الالتقاط
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('تعذّر تجهيز البطاقة');

    final image = await boundary.toImage(
      pixelRatio: 1.5,
    ); // 1080×1350 أصلًا كافية، pixelRatio زيادة جودة إضافية
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('تعذّر إنشاء الصورة');

    final bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/property_${property.id}.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text:
            '${property.title} — ${property.price.toStringAsFixed(0)} د.أ — ${property.cityName}',
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('تعذّرت المشاركة، حاول مرة أخرى')),
    );
  } finally {
    entry.remove();
    completer.complete();
  }

  await completer.future;
}
