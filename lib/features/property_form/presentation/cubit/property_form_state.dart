part of "property_form_cubit.dart";

enum PropertyFormLoadStatus { loading, ready, error }
enum PropertyFormSubmitStatus { idle, submitting, success, error }

class PropertyFormState extends Equatable {
  final PropertyFormLoadStatus loadStatus;
  final PropertyFormSubmitStatus submitStatus;
  final String? loadError;
  final String? submitError;

  final List<PropertyTypeEntity> propertyTypes;
  final List<CityEntity> cities;

  final bool isEditing;
  final String? editingPropertyId;

  // حقول الفورم
  final String title;
  final String description;
  final int? propertyTypeId;
  final String listingType; // sale | rent
  final double? price;
  final double? areaSqm;
  final int roomsCount;
  final int bathroomsCount;
  final int? cityId;
  final String addressText;
  final double? latitude;
  final double? longitude;
  final List<PropertyImageEntity> images;
  final bool isUploadingImage;

  final Map<String, String> fieldErrors;

  const PropertyFormState({
    this.loadStatus = PropertyFormLoadStatus.loading,
    this.submitStatus = PropertyFormSubmitStatus.idle,
    this.loadError,
    this.submitError,
    this.propertyTypes = const [],
    this.cities = const [],
    this.isEditing = false,
    this.editingPropertyId,
    this.title = "",
    this.description = "",
    this.propertyTypeId,
    this.listingType = "sale",
    this.price,
    this.areaSqm,
    this.roomsCount = 0,
    this.bathroomsCount = 0,
    this.cityId,
    this.addressText = "",
    this.latitude,
    this.longitude,
    this.images = const [],
    this.isUploadingImage = false,
    this.fieldErrors = const {},
  });

  bool get isLand {
    final type = propertyTypes.firstWhereOrNull((t) => t.id == propertyTypeId);
    return type?.iconName == "land";
  }

  PropertyFormState copyWith({
    PropertyFormLoadStatus? loadStatus,
    PropertyFormSubmitStatus? submitStatus,
    String? loadError,
    String? submitError,
    List<PropertyTypeEntity>? propertyTypes,
    List<CityEntity>? cities,
    bool? isEditing,
    String? editingPropertyId,
    String? title,
    String? description,
    int? propertyTypeId,
    String? listingType,
    double? price,
    double? areaSqm,
    int? roomsCount,
    int? bathroomsCount,
    int? cityId,
    String? addressText,
    double? latitude,
    double? longitude,
    List<PropertyImageEntity>? images,
    bool? isUploadingImage,
    Map<String, String>? fieldErrors,
  }) {
    return PropertyFormState(
      loadStatus: loadStatus ?? this.loadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      loadError: loadError,
      submitError: submitError,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      isEditing: isEditing ?? this.isEditing,
      editingPropertyId: editingPropertyId ?? this.editingPropertyId,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      listingType: listingType ?? this.listingType,
      price: price ?? this.price,
      areaSqm: areaSqm ?? this.areaSqm,
      roomsCount: roomsCount ?? this.roomsCount,
      bathroomsCount: bathroomsCount ?? this.bathroomsCount,
      cityId: cityId ?? this.cityId,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        submitStatus,
        loadError,
        submitError,
        propertyTypes,
        cities,
        isEditing,
        editingPropertyId,
        title,
        description,
        propertyTypeId,
        listingType,
        price,
        areaSqm,
        roomsCount,
        bathroomsCount,
        cityId,
        addressText,
        latitude,
        longitude,
        images,
        isUploadingImage,
        fieldErrors,
      ];
}
