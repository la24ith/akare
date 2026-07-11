import 'package:akare/core/constants/app_colors.dart';
import 'package:akare/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// exposes `sl` (GetIt.instance) — adjust path/name if yours differs
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_section_states.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/property_card.dart';

/// Public entry point. Provides its own [HomeCubit] so this screen works
/// no matter how it's pushed (`Navigator.push`, `IndexedStack` in a bottom
/// nav bar, GoRouter, etc.) without the caller needing to remember to wrap
/// it in a BlocProvider.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHome(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scrollController = ScrollController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<HomeCubit>().loadMoreLatest();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<HomeCubit>().refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _HeaderSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _CategoriesSliver(
              selectedCategoryId: _selectedCategoryId,
              onSelect: (id) => setState(() => _selectedCategoryId = id),
            ),
            const _FeaturedSliver(),
            const _LatestHeaderSliver(),
            const _LatestListSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Gradient hero header with a greeting + notifications, and the floating
/// search bar overlapping its bottom edge for a layered, modern feel.
class _HeaderSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أهلاً بك 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'اعثر على عقارك المثالي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            HomeSearchBar(
              onTap: () {
                context.push('/search');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSliver extends StatelessWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelect;
  const _CategoriesSliver({
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (p, c) =>
            p.categoriesStatus != c.categoriesStatus ||
            p.categories != c.categories,
        builder: (context, state) {
          if (state.categoriesStatus == SectionStatus.loading ||
              state.categoriesStatus == SectionStatus.initial) {
            return SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.only(right: 16),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      ShimmerBox(
                        width: 58,
                        height: 58,
                        borderRadius: BorderRadius.all(Radius.circular(29)),
                      ),
                      SizedBox(height: 6),
                      ShimmerBox(width: 50, height: 10),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state.categoriesStatus == SectionStatus.error)
            return const SizedBox.shrink();

          return SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL-friendly horizontal scroll
              padding: const EdgeInsets.only(right: 16),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final type = state.categories[index];
                return CategoryChip(
                  type: type,
                  isSelected: selectedCategoryId == type.id,
                  onTap: () =>
                      onSelect(selectedCategoryId == type.id ? null : type.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedSliver extends StatelessWidget {
  const _FeaturedSliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (p, c) =>
            p.featuredStatus != c.featuredStatus ||
            p.featuredProperties != c.featuredProperties,
        builder: (context, state) {
          if (state.featuredStatus == SectionStatus.error)
            return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'عقارات مميزة'),
              SizedBox(
                height: 232,
                child:
                    (state.featuredStatus == SectionStatus.loading ||
                        state.featuredStatus == SectionStatus.initial)
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.only(right: 20),
                        itemCount: 3,
                        itemBuilder: (_, __) => const PropertyCardShimmer(),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.only(right: 20),
                        itemCount: state.featuredProperties.length,
                        itemBuilder: (context, index) {
                          final property = state.featuredProperties[index];
                          return PropertyCard(
                            property: property,
                            onTap: () {
                              context.push('/property/${property.id}');
                            },
                            onFavoriteTap: () {
                              // context.read<HomeCubit>().toggleFavorite(property.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LatestHeaderSliver extends StatelessWidget {
  const _LatestHeaderSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SectionHeader(title: 'أحدث العقارات'),
    );
  }
}

class _LatestListSliver extends StatelessWidget {
  const _LatestListSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.latestStatus == SectionStatus.loading ||
            state.latestStatus == SectionStatus.initial) {
          return SliverList.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const PropertyListTileShimmer(),
          );
        }

        if (state.latestStatus == SectionStatus.error) {
          return SliverToBoxAdapter(
            child: SectionError(
              message: state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
              onRetry: () => context.read<HomeCubit>().refresh(),
            ),
          );
        }

        if (state.isLatestEmpty) {
          return const SliverToBoxAdapter(child: EmptyProperties());
        }

        return SliverList.builder(
          itemCount:
              state.latestProperties.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.latestProperties.length) {
              return const PropertyListTileShimmer();
            }
            final property = state.latestProperties[index];
            return PropertyListTile(
              property: property,
              onTap: () {
                // context.push('/property/${property.id}');
              },
              onFavoriteTap: () {
                // context.read<HomeCubit>().toggleFavorite(property.id);
              },
            );
          },
        );
      },
    );
  }
}
