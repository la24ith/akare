import "package:akare/core/constants/app_colors.dart";
import "package:akare/core/di/injection_container.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "../cubit/property_form_cubit.dart";
import "../widgets/form_section_card.dart";
import "../widgets/property_images_grid.dart";

class PropertyFormScreen extends StatelessWidget {
  final String? propertyId; // null = إضافة، غير null = تعديل
  const PropertyFormScreen({super.key, this.propertyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PropertyFormCubit>()..init(editingPropertyId: propertyId),
      child: const _PropertyFormView(),
    );
  }
}

class _PropertyFormView extends StatefulWidget {
  const _PropertyFormView();

  @override
  State<_PropertyFormView> createState() => _PropertyFormViewState();
}

class _PropertyFormViewState extends State<_PropertyFormView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      context.read<PropertyFormCubit>().addLocalImage(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        title: Text(
          context.select((PropertyFormCubit c) => c.state.isEditing)
              ? "تعديل العقار"
              : "إضافة عقار",
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<PropertyFormCubit, PropertyFormState>(
        listenWhen: (p, c) =>
            p.submitStatus != c.submitStatus || p.submitError != c.submitError,
        listener: (context, state) {
          if (state.submitStatus == PropertyFormSubmitStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم إرسال عقارك للمراجعة")),
            );
            context.pop();
          } else if (state.submitStatus == PropertyFormSubmitStatus.error &&
              state.submitError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.submitError!)));
          }
        },
        builder: (context, state) {
          if (state.loadStatus == PropertyFormLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.loadStatus == PropertyFormLoadStatus.error) {
            return Center(child: Text(state.loadError ?? "حدث خطأ"));
          }

          if (!_controllersInitialized) {
            _titleController.text = state.title;
            _descriptionController.text = state.description;
            _priceController.text = state.price?.toString() ?? "";
            _areaController.text = state.areaSqm?.toString() ?? "";
            _addressController.text = state.addressText;
            _controllersInitialized = true;
          }

          final cubit = context.read<PropertyFormCubit>();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FormSectionCard(
                    title: "معلومات أساسية",
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          onChanged: cubit.setTitle,
                          decoration: InputDecoration(
                            labelText: "العنوان",
                            errorText: state.fieldErrors["title"],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          onChanged: cubit.setDescription,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "الوصف",
                            errorText: state.fieldErrors["description"],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: state.propertyTypeId,
                          decoration: InputDecoration(
                            labelText: "نوع العقار",
                            errorText: state.fieldErrors["propertyType"],
                            border: const OutlineInputBorder(),
                          ),
                          items: state.propertyTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.nameAr),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) cubit.setPropertyType(v);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ListingTypeButton(
                                label: "بيع",
                                selected: state.listingType == "sale",
                                onTap: () => cubit.setListingType("sale"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ListingTypeButton(
                                label: "إيجار",
                                selected: state.listingType == "rent",
                                onTap: () => cubit.setListingType("rent"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FormSectionCard(
                    title: "السعر والمساحة",
                    child: Column(
                      children: [
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => cubit.setPrice(double.tryParse(v)),
                          decoration: InputDecoration(
                            labelText: "السعر (\$)",
                            errorText: state.fieldErrors["price"],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _areaController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => cubit.setArea(double.tryParse(v)),
                          decoration: InputDecoration(
                            labelText: "المساحة (م²)",
                            errorText: state.fieldErrors["area"],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (!state.isLand) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StepperField(
                                  label: "غرف",
                                  value: state.roomsCount,
                                  onChanged: cubit.setRooms,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StepperField(
                                  label: "حمامات",
                                  value: state.bathroomsCount,
                                  onChanged: cubit.setBathrooms,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  FormSectionCard(
                    title: "الموقع",
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: state.cityId,
                          decoration: InputDecoration(
                            labelText: "المدينة",
                            errorText: state.fieldErrors["city"],
                            border: const OutlineInputBorder(),
                          ),
                          items: state.cities
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nameAr),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) cubit.setCity(v);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          onChanged: cubit.setAddress,
                          decoration: const InputDecoration(
                            labelText: "العنوان النصي (اختياري)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FormSectionCard(
                    title: "الصور",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.fieldErrors["images"] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              state.fieldErrors["images"]!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        PropertyImagesGrid(
                          images: state.images,
                          isUploading: state.isUploadingImage,
                          onAdd: () => _pickImage(context),
                          onRemove: cubit.removeImage,
                          onSetPrimary: cubit.setPrimaryImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  onPressed:
                      state.submitStatus == PropertyFormSubmitStatus.submitting
                      ? null
                      : () => cubit.submit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      state.submitStatus == PropertyFormSubmitStatus.submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("نشر العقار"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ListingTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ListingTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepButton(
                Icons.remove_circle_outline,
                () => onChanged(value - 1),
              ),
              SizedBox(
                width: 20,
                child: Text(
                  "$value",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _stepButton(Icons.add_circle_outline, () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
