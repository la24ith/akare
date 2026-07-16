// lib/features/favorites/presentation/screens/favorites_screen.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../../home/presentation/widgets/home_section_states.dart';
import '../../../home/presentation/widgets/property_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesCubit>()..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<FavoritesCubit>().load(),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.status == FavoritesStatus.loading ||
                state.status == FavoritesStatus.initial) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const PropertyListTileShimmer(),
              );
            }
            if (state.status == FavoritesStatus.error) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  SectionError(
                    message: state.errorMessage ?? 'حدث خطأ',
                    onRetry: () => context.read<FavoritesCubit>().load(),
                  ),
                ],
              );
            }
            if (state.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 60),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'لم تُضِف أي عقار للمفضلة بعد',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: state.properties.length,
              itemBuilder: (context, index) {
                final property = state.properties[index];
                return PropertyListTile(
                  property: property,
                  onTap: () => context.push('/property/${property.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
