import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/presentation/payment_tracking_screen.dart';
import 'package:monprof/paiements/presentation/widgets/payment_service_logo.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GetBuilder<PaiementsController>(
      builder: (controller) {
        final service = controller.selectedPaymentService;
        final quantity = int.tryParse(controller.controllerQuantite.text) ?? 1;

        return Scaffold(
          appBar: AppBar(title: Text('Confirmation du paiement'.tr)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colors.primary,
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vérifiez les informations'.tr,
                              style: textStyle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Une demande de confirmation sera envoyée au numéro du payeur.'
                                  .tr,
                              style: textStyle.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _SummaryCard(
                  children: [
                    _ServiceSummary(
                      title: service?.title ?? 'Indisponible'.tr,
                      imageUrl: service?.imageUrl,
                    ),
                    _SummaryRow(
                      label: 'Numéro du payeur'.tr,
                      value: controller.controllerNumeroPayeur.text,
                    ),
                    _SummaryRow(
                      label: 'Bénéficiaire'.tr,
                      value: controller.controllerNumeroClient.text,
                    ),
                    _SummaryRow(
                      label: 'Catégorie'.tr,
                      value: controller.selectedCategory?.libelle ??
                          'Abonnement'.tr,
                    ),
                    _SummaryRow(
                      label: 'Quantité'.tr,
                      value: quantity.toString(),
                    ),
                    _SummaryRow(
                      label: 'Montant'.tr,
                      value: '${controller.totalPrice} XAF',
                    ),
                    _SummaryRow(
                      label: 'Frais de service'.tr,
                      value: '${controller.serviceFee} XAF',
                    ),
                    _SummaryRow(
                      label: 'Total à payer'.tr,
                      value: '${controller.totalAmount} XAF',
                      emphasize: true,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                DefaultButton(
                  onPressed: controller.paymentCreationState.isLoading
                      ? null
                      : () async {
                          final created = await controller.requestPayment();
                          if (!context.mounted) return;

                          if (created ||
                              controller.paymentCreationState.hasError) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PaymentTrackingScreen(),
                              ),
                            );
                          } else {
                            Notify.showFailure(
                              context,
                              controller
                                      .paymentCreationState.errorModel?.error ??
                                  controller.paymentFailureReason ??
                                  'Impossible de démarrer le paiement'.tr,
                            );
                          }
                        },
                  wdiget: controller.paymentCreationState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirmer et payer'.tr,
                          style: textStyle.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.paymentCreationState.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text('Modifier les informations'.tr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<Widget> children;

  const _SummaryCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool showDivider;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textStyle.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: textStyle.copyWith(
                    color: emphasize ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colors.outlineVariant,
          ),
      ],
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  final String title;
  final String? imageUrl;

  const _ServiceSummary({required this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              PaymentServiceLogo(imageUrl: imageUrl, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service de paiement'.tr,
                      style: textStyle.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: textStyle.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.outlineVariant),
      ],
    );
  }
}
