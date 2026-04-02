import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/theme/theme.dart';

class CourtsListPageWidget extends StatelessWidget {
  const CourtsListPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _shopsSection();
  }

  Widget _shopsSection() {
    return ListView(
      key: const ValueKey<String>('shops'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                LightColor.primaryGreen,
                LightColor.secondaryGreen,
                LightColor.accentGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.primaryGreen.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Ready to launch a new shop?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a verified shop profile with registration and branding details.',
                style: TextStyle(color: Color(0xE8FFFFFF), fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightColor.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Create Shop'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Bhatbhateni Outlet',
          subtitle: 'Active · Kathmandu, Nepal',
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Hamro Mart',
          subtitle: 'Pending verification · Lalitpur, Nepal',
          icon: Icons.domain_verification_outlined,
        ),
      ],
    );
  }
}
class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: LightColor.orange.withAlpha(30), //Color(0xfffeece2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LightColor.orange),
        ),
        title: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: LightColor.titleTextColor,
          ),
        ),
        subtitle: Text(subtitle, style: AppTheme.subTitleStyle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: LightColor.darkgrey,
        ),
      ),
    );
  }
}
