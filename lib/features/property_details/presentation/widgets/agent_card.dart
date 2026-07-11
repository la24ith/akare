import 'package:akare/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/agent_entity.dart';

class AgentCard extends StatelessWidget {
  final AgentEntity agent;
  const AgentCard({super.key, required this.agent});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: agent.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    // Assumes E.164-formatted phone numbers (e.g. 9627XXXXXXXX) as stored in `users.phone`.
    final digits = agent.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.background,
            backgroundImage: agent.avatarUrl != null
                ? CachedNetworkImageProvider(agent.avatarUrl!)
                : null,
            child: agent.avatarUrl == null
                ? const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        agent.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (agent.isVerifiedAgent) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  agent.companyName ?? 'وكيل عقاري',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _ContactIconButton(
            icon: Icons.call_outlined,
            color: AppColors.primary,
            onTap: _call,
          ),
          const SizedBox(width: 8),
          _ContactIconButton(
            icon: Icons.chat_outlined,
            color: const Color(0xFF25D366),
            onTap: _whatsapp,
          ),
        ],
      ),
    );
  }
}

class _ContactIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ContactIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}
