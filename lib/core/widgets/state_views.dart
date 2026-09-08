import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Нишондиҳандаи боркунӣ (истифодаи ягона дар тамоми барнома).
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Ҳолати хатогӣ бо тугмаи "Аз нав кӯшиш кардан".
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.message = AppStrings.somethingWentWrong,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ҳолати "ҳеҷ чиз ёфт нашуд".
class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({
    super.key,
    this.message = AppStrings.empty,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Банда барои "Интернет пайваст нест".
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Text(
        AppStrings.noInternet,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
