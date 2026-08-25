import 'package:flutter/material.dart';

class PaymentServiceLogo extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const PaymentServiceLogo({
    super.key,
    required this.imageUrl,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = imageUrl?.trim();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * .24),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.onSurfaceVariant,
              size: size * .58,
            )
          : url.startsWith('http')
              ? Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Center(
                          child: SizedBox(
                            width: size * .4,
                            height: size * .4,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colors.onSurfaceVariant,
                    size: size * .58,
                  ),
                )
              : Image.asset(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colors.onSurfaceVariant,
                    size: size * .58,
                  ),
                ),
    );
  }
}
