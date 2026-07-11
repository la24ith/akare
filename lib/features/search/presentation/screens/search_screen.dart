import 'dart:async';

import 'package:akare/core/constants/app_colors.dart';
import 'package:akare/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// exposes `sl` (GetIt.instance) — adjust path/name if yours differs
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../../home/presentation/widgets/home_section_states.dart';
import '../../../home/presentation/widgets/property_card.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/property_grid_tile.dart';
import '../widgets/view_mode_toggle.dart';

/// Public entry point. Provides its own [SearchCubit] so it works no matter
/// how it's navigated to.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..init(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _scrollController = ScrollController();
  final _keywordController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<SearchCubit>().loadMore();
    }
  }

  void _onKeywordChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchCubit>().updateKeyword(value);
      context.read<SearchCubit>().search();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'البحث',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _keywordController,
                            onChanged: _onKeywordChanged,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن شقة، فيلا، أرض ...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (p, c) =>
                      p.filter != c.filter ||
                      p.cities != c.cities ||
                      p.propertyTypes != c.propertyTypes,
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () => showFilterSheet(
                        context: context,
                        currentFilter: state.filter,
                        cities: state.cities,
                        propertyTypes: state.propertyTypes,
                        onApply: (filter) =>
                            context.read<SearchCubit>().applyFilter(filter),
                        onClear: () =>
                            context.read<SearchCubit>().clearFilters(),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: state.filter.hasActiveFilters
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: state.filter.hasActiveFilters
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (p, c) =>
                      p.results.length != c.results.length ||
                      p.resultsStatus != c.resultsStatus,
                  builder: (context, state) => Text(
                    state.resultsStatus == ResultsStatus.loaded
                        ? '${state.results.length} نتيجة'
                        : ' ',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (p, c) => p.viewMode != c.viewMode,
                  builder: (context, state) => ViewModeToggle(
                    mode: state.viewMode,
                    onChanged: (mode) =>
                        context.read<SearchCubit>().setViewMode(mode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.resultsStatus == ResultsStatus.loading ||
                    state.resultsStatus == ResultsStatus.initial) {
                  return state.viewMode == ViewMode.grid
                      ? const _GridShimmer()
                      : ListView.builder(
                          itemCount: 5,
                          itemBuilder: (_, __) =>
                              const PropertyListTileShimmer(),
                        );
                }

                if (state.resultsStatus == ResultsStatus.error) {
                  return SectionError(
                    message: state.errorMessage ?? 'حدث خطأ أثناء البحث',
                    onRetry: () => context.read<SearchCubit>().search(),
                  );
                }

                if (state.isEmpty) {
                  return const EmptyProperties(
                    message: ' لا توجد عقارات مطابقة لبحثك',
                  );
                }

                return state.viewMode == ViewMode.grid
                    ? _ResultsGrid(
                        scrollController: _scrollController,
                        state: state,
                      )
                    : _ResultsList(
                        scrollController: _scrollController,
                        state: state,
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final ScrollController scrollController;
  final SearchState state;
  const _ResultsList({required this.scrollController, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.results.length)
          return const PropertyListTileShimmer();
        final property = state.results[index];
        return PropertyListTile(
          property: property,
          onTap: () {
            // context.push('/property/${property.id}');
          },
        );
      },
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  final ScrollController scrollController;
  final SearchState state;
  const _ResultsGrid({required this.scrollController, required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final property = state.results[index];
        return PropertyGridTile(
          property: property,
          onTap: () {
            // context.push('/property/${property.id}');
          },
        );
      },
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerBox(
        height: double.infinity,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
