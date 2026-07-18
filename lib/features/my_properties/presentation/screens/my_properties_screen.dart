import "package:akare/core/theme/app_colors.dart";
import "package:akare/core/di/injection_container.dart";
import "package:akare/features/home/presentation/widgets/home_section_states.dart";
import "package:akare/features/home/presentation/widgets/home_shimmer.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../domain/entities/my_property_entity.dart";
import "../cubit/my_properties_cubit.dart";
import "../widgets/my_property_tile.dart";
import "../widgets/property_filter_chips.dart";

class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyPropertiesCubit>()..loadFirstPage(),
      child: const _MyPropertiesView(),
    );
  }
}

class _MyPropertiesView extends StatefulWidget {
  const _MyPropertiesView();

  @override
  State<_MyPropertiesView> createState() => _MyPropertiesViewState();
}

class _MyPropertiesViewState extends State<_MyPropertiesView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<MyPropertiesCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        title: const Text("عقاراتي"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push("/agent/properties/add"),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<MyPropertiesCubit, MyPropertiesState>(
        listenWhen: (p, c) => p.actionMessage != c.actionMessage,
        listener: (context, state) {
          if (state.actionMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 8),
              PropertyFilterChips(
                selected: state.filter,
                onChanged: (f) =>
                    context.read<MyPropertiesCubit>().changeFilter(f),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyPropertiesState state) {
    if (state.status == MyPropertiesStatus.loading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ShimmerBox(
            height: 100,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (state.status == MyPropertiesStatus.error && state.properties.isEmpty) {
      return SectionError(
        message: state.errorMessage ?? "تعذّر تحميل العقارات",
        onRetry: () => context.read<MyPropertiesCubit>().loadFirstPage(),
      );
    }

    if (state.properties.isEmpty) {
      return const EmptyProperties(message: "لا توجد عقارات ضمن هذا التصنيف");
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MyPropertiesCubit>().loadFirstPage(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 90, top: 4),
        itemCount: state.properties.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.properties.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final property = state.properties[index];
          return MyPropertyTile(
            property: property,
            onTap: () => context.push("/agent/property/${property.id}"),
            onEdit: () => context.push("/agent/properties/edit/${property.id}"),
            onViewAsUser: () => context.push("/property/${property.id}"),
            onDelete: () => _confirmDelete(context, property),
            onMarkSold: () => context.read<MyPropertiesCubit>().updateStatus(
              property.id,
              "sold",
            ),
            onMarkRented: () => context.read<MyPropertiesCubit>().updateStatus(
              property.id,
              "rented",
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, MyPropertyEntity property) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("حذف العقار"),
        content: Text("هل أنت متأكد من حذف \"${property.title}\"؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MyPropertiesCubit>().deleteProperty(property.id);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
