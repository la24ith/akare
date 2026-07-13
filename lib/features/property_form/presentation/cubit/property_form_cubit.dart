import "dart:io";
import "package:akare/core/usecace/usecase.dart";
import "package:akare/features/home/domain/entities/property_type_entity.dart";
import "package:akare/features/search/domain/entities/city_entity.dart";
import "package:collection/collection.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/entities/property_image_entity.dart";
import "../../domain/entities/property_submit_data.dart";
import "../../domain/usecases/delete_property_image_usecase.dart";
import "../../domain/usecases/get_form_lookups_usecase.dart";
import "../../domain/usecases/get_property_for_edit_usecase.dart";
import "../../domain/usecases/submit_property_usecase.dart";
import "../../domain/usecases/upload_property_image_usecase.dart";

part "property_form_state.dart";

class PropertyFormCubit extends Cubit<PropertyFormState> {
  final GetFormLookupsUseCase getFormLookupsUseCase;
  final GetPropertyForEditUseCase getPropertyForEditUseCase;
  final SubmitPropertyUseCase submitPropertyUseCase;
  final UploadPropertyImageUseCase uploadPropertyImageUseCase;
  final DeletePropertyImageUseCase deletePropertyImageUseCase;

  PropertyFormCubit({
    required this.getFormLookupsUseCase,
    required this.getPropertyForEditUseCase,
    required this.submitPropertyUseCase,
    required this.uploadPropertyImageUseCase,
    required this.deletePropertyImageUseCase,
  }) : super(const PropertyFormState());

  Future<void> init({String? editingPropertyId}) async {
    emit(
      state.copyWith(
        loadStatus: PropertyFormLoadStatus.loading,
        isEditing: editingPropertyId != null,
        editingPropertyId: editingPropertyId,
      ),
    );

    final lookupsResult = await getFormLookupsUseCase(NoParams());
    final failure = lookupsResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          loadStatus: PropertyFormLoadStatus.error,
          loadError: failure.message,
        ),
      );
      return;
    }
    final lookups = lookupsResult.getOrElse(() => throw StateError(""));

    if (editingPropertyId == null) {
      emit(
        state.copyWith(
          loadStatus: PropertyFormLoadStatus.ready,
          propertyTypes: lookups.propertyTypes,
          cities: lookups.cities,
        ),
      );
      return;
    }

    final editResult = await getPropertyForEditUseCase(editingPropertyId);
    editResult.fold(
      (f) => emit(
        state.copyWith(
          loadStatus: PropertyFormLoadStatus.error,
          loadError: f.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          loadStatus: PropertyFormLoadStatus.ready,
          propertyTypes: lookups.propertyTypes,
          cities: lookups.cities,
          title: data.title,
          description: data.description,
          propertyTypeId: data.propertyTypeId,
          listingType: data.listingType,
          price: data.price,
          areaSqm: data.areaSqm,
          roomsCount: data.roomsCount ?? 0,
          bathroomsCount: data.bathroomsCount ?? 0,
          cityId: data.cityId,
          addressText: data.addressText ?? "",
          latitude: data.latitude,
          longitude: data.longitude,
          images: data.images,
        ),
      ),
    );
  }

  // ---- تحديث الحقول ----
  void setTitle(String v) => emit(state.copyWith(title: v));
  void setDescription(String v) => emit(state.copyWith(description: v));
  void setPropertyType(int id) => emit(state.copyWith(propertyTypeId: id));
  void setListingType(String v) => emit(state.copyWith(listingType: v));
  void setPrice(double? v) => emit(state.copyWith(price: v));
  void setArea(double? v) => emit(state.copyWith(areaSqm: v));
  void setRooms(int v) => emit(state.copyWith(roomsCount: v < 0 ? 0 : v));
  void setBathrooms(int v) =>
      emit(state.copyWith(bathroomsCount: v < 0 ? 0 : v));
  void setCity(int id) => emit(state.copyWith(cityId: id));
  void setAddress(String v) => emit(state.copyWith(addressText: v));
  void setCoordinates(double lat, double lng) =>
      emit(state.copyWith(latitude: lat, longitude: lng));

  // ---- الصور ----
  void addLocalImage(String localPath) {
    final nextOrder = state.images.length;
    final img = PropertyImageEntity(
      localPath: localPath,
      isPrimary: state.images.isEmpty,
      sortOrder: nextOrder,
    );
    emit(state.copyWith(images: [...state.images, img]));
  }

  Future<bool> uploadPendingImages(String propertyId) async {
    final pending = state.images.where((i) => !i.isUploaded).toList();
    bool allSucceeded = true;

    for (final img in pending) {
      if (img.localPath == null) continue;
      emit(state.copyWith(isUploadingImage: true));
      final result = await uploadPropertyImageUseCase(
        UploadPropertyImageParams(
          file: File(img.localPath!),
          propertyId: propertyId,
          isPrimary: img.isPrimary,
          sortOrder: img.sortOrder,
        ),
      );
      result.fold(
        (f) {
          allSucceeded = false;
          emit(state.copyWith(isUploadingImage: false, submitError: f.message));
        },
        (url) {
          final updated = state.images.map((e) {
            if (e == img) return e.copyWith(remoteUrl: url);
            return e;
          }).toList();
          emit(state.copyWith(images: updated, isUploadingImage: false));
        },
      );
    }
    return allSucceeded;
  }

  Future<void> removeImage(PropertyImageEntity image) async {
    if (image.id != null) {
      await deletePropertyImageUseCase(image.id!);
    }
    final updated = state.images.where((e) => e != image).toList();
    emit(state.copyWith(images: updated));
  }

  void setPrimaryImage(PropertyImageEntity image) {
    final updated = state.images
        .map((e) => e.copyWith(isPrimary: e == image))
        .toList();
    emit(state.copyWith(images: updated));
  }

  // ---- التحقق والإرسال ----
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.title.trim().isEmpty) errors["title"] = "العنوان مطلوب";
    if (state.description.trim().isEmpty) {
      errors["description"] = "الوصف مطلوب";
    }
    if (state.propertyTypeId == null) {
      errors["propertyType"] = "الرجاء اختيار نوع العقار";
    }
    if (state.cityId == null) errors["city"] = "الرجاء اختيار المدينة";
    if (state.price == null || state.price! <= 0) {
      errors["price"] = "الرجاء إدخال سعر صحيح";
    }
    if (state.areaSqm == null || state.areaSqm! <= 0) {
      errors["area"] = "الرجاء إدخال مساحة صحيحة";
    }
    if (state.images.isEmpty) errors["images"] = "أضف صورة واحدة على الأقل";
    return errors;
  }

  Future<bool> submit() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return false;
    }
    emit(
      state.copyWith(
        submitStatus: PropertyFormSubmitStatus.submitting,
        fieldErrors: {},
      ),
    );

    final data = PropertySubmitData(
      title: state.title.trim(),
      description: state.description.trim(),
      price: state.price!,
      listingType: state.listingType,
      propertyTypeId: state.propertyTypeId!,
      cityId: state.cityId!,
      addressText: state.addressText.trim().isEmpty
          ? null
          : state.addressText.trim(),
      latitude: state.latitude,
      longitude: state.longitude,
      roomsCount: state.isLand ? null : state.roomsCount,
      bathroomsCount: state.isLand ? null : state.bathroomsCount,
      areaSqm: state.areaSqm!,
    );

    final result = await submitPropertyUseCase(
      SubmitPropertyParams(
        data: data,
        editingPropertyId: state.editingPropertyId,
      ),
    );

    String? propertyId;
    String? errorMessage;
    result.fold((f) => errorMessage = f.message, (id) => propertyId = id);

    if (propertyId == null) {
      emit(
        state.copyWith(
          submitStatus: PropertyFormSubmitStatus.error,
          submitError: errorMessage,
        ),
      );
      return false;
    }

    final imagesUploaded = await uploadPendingImages(propertyId!);

    if (!imagesUploaded) {
      emit(
        state.copyWith(
          submitStatus: PropertyFormSubmitStatus.error,
          submitError: state.submitError ?? "فشل رفع بعض الصور، حاول مرة أخرى",
          editingPropertyId: propertyId,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        submitStatus: PropertyFormSubmitStatus.success,
        editingPropertyId: propertyId,
      ),
    );
    return true;
  }

  void setLocation(double lat, double lng) {
    emit(state.copyWith(latitude: lat, longitude: lng));
  }
}
