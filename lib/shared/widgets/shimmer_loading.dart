import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_spacing.dart';

/// Base shimmer wrapper that provides consistent shimmer effect.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer wrapper that applies the shimmer effect to its children.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: isDark
          ? colorScheme.surfaceContainerHighest
          : Colors.grey.shade300,
      highlightColor: isDark
          ? colorScheme.surfaceContainerHighest.withAlpha(128)
          : Colors.grey.shade100,
      child: child,
    );
  }
}

/// Shimmer skeleton for a conversation card in the list.
class ShimmerConversationCard extends StatelessWidget {
  const ShimmerConversationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const ShimmerBox(width: 44, height: 44, borderRadius: AppRadius.md),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: MediaQuery.of(context).size.width * 0.4, height: 16),
                    const SizedBox(height: AppSpacing.sm),
                    ShimmerBox(width: MediaQuery.of(context).size.width * 0.25, height: 12),
                  ],
                ),
              ),
              const ShimmerBox(width: 40, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a list of conversation cards.
class ShimmerConversationList extends StatelessWidget {
  final int itemCount;

  const ShimmerConversationList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerConversationCard(),
    );
  }
}

/// Shimmer skeleton for a project grid card.
class ShimmerProjectGridCard extends StatelessWidget {
  const ShimmerProjectGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 40, height: 40, borderRadius: AppRadius.sm),
                const Spacer(),
                const ShimmerBox(width: 24, height: 24, borderRadius: AppRadius.xs),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const ShimmerBox(width: 120, height: 16),
            const SizedBox(height: AppSpacing.sm),
            const ShimmerBox(width: 80, height: 12),
            const Spacer(),
            const ShimmerBox(width: 100, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a project grid.
class ShimmerProjectGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerProjectGrid({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerProjectGridCard(),
    );
  }
}

/// Shimmer skeleton for chat message bubbles.
class ShimmerMessageBubble extends StatelessWidget {
  final bool isUser;

  const ShimmerMessageBubble({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: EdgeInsets.only(
          left: isUser ? 80 : 16,
          right: isUser ? 16 : 80,
          top: 8,
          bottom: 8,
        ),
        child: isUser
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 48,
                      borderRadius: AppRadius.xl,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ShimmerBox(width: 32, height: 32, borderRadius: 10),
                      const SizedBox(width: 12),
                      const ShimmerBox(width: 60, height: 14),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  ShimmerBox(width: MediaQuery.of(context).size.width * 0.6, height: 14),
                  const SizedBox(height: 8),
                  ShimmerBox(width: MediaQuery.of(context).size.width * 0.4, height: 14),
                ],
              ),
      ),
    );
  }
}

/// Shimmer skeleton for chat messages list.
class ShimmerChatMessages extends StatelessWidget {
  const ShimmerChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ShimmerMessageBubble(isUser: true),
        ShimmerMessageBubble(isUser: false),
        ShimmerMessageBubble(isUser: true),
        ShimmerMessageBubble(isUser: false),
      ],
    );
  }
}

/// Shimmer skeleton for the dashboard stats row.
class ShimmerStatsRow extends StatelessWidget {
  const ShimmerStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == 2 ? 0 : 6,
              ),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the dashboard home tile items.
class ShimmerHomeTile extends StatelessWidget {
  const ShimmerHomeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a quiz card in the list.
class ShimmerQuizCard extends StatelessWidget {
  const ShimmerQuizCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const ShimmerBox(
                  width: 48, height: 48, borderRadius: AppRadius.md),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 16),
                    const SizedBox(height: AppSpacing.sm),
                    const Row(
                      children: [
                        ShimmerBox(width: 50, height: 14, borderRadius: 4),
                        SizedBox(width: AppSpacing.sm),
                        ShimmerBox(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
              const ShimmerBox(width: 32, height: 32, borderRadius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the quiz list.
class ShimmerQuizList extends StatelessWidget {
  final int itemCount;
  const ShimmerQuizList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpacing.md),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerQuizCard(),
    );
  }
}

/// Shimmer skeleton for knowledge tab (mastery header + topic cards).
class ShimmerKnowledgeTab extends StatelessWidget {
  const ShimmerKnowledgeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Mastery header
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Topic cards
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(width: 48, height: 48, borderRadius: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 16),
                          const SizedBox(height: AppSpacing.sm),
                          const Row(
                            children: [
                              ShimmerBox(
                                  width: 60, height: 14, borderRadius: 4),
                              SizedBox(width: AppSpacing.sm),
                              ShimmerBox(width: 70, height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 20, height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
