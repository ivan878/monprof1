import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/paiements/datas/models/payment_transaction.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/presentation/widgets/payment_service_logo.dart';

class PaymentTrackingScreen extends StatelessWidget {
  const PaymentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<PaiementsController>(
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('Suivi du paiement'.tr),
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: switch (controller.paymentFlowStatus) {
                  PaymentFlowStatus.success =>
                    _SuccessView(controller: controller),
                  PaymentFlowStatus.failed =>
                    _FailureView(controller: controller),
                  _ => _PendingView(controller: controller),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  final PaiementsController controller;

  const _PendingView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('payment-pending'),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 36),
        Center(
          child: Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Paiement en attente'.tr,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          'Confirmez la demande reçue sur le téléphone du payeur. Cette page se met à jour automatiquement.'
              .tr,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  PaymentServiceLogo(
                    imageUrl: controller.selectedPaymentService?.imageUrl,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.selectedPaymentService?.title ?? '-',
                      style: textStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: colors.outlineVariant),
              const SizedBox(height: 14),
              _InfoRow(
                label: 'Référence'.tr,
                value: controller.currentTransaction?.reference ?? '-',
              ),
              const SizedBox(height: 14),
              _InfoRow(
                label: 'Total à payer'.tr,
                value:
                    '${(controller.currentTransaction?.amount ?? controller.totalAmount).round()} XAF',
              ),
              const SizedBox(height: 14),
              _InfoRow(
                label: 'Vérification'.tr,
                value: 'Toutes les 7 secondes'.tr,
              ),
            ],
          ),
        ),
        if (controller.pollingError != null) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'La dernière vérification a échoué. Le suivi automatique continue.'
                  .tr,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(color: Colors.orange.shade900),
            ),
          ),
        ],
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: controller.checkTransactionStatus,
          icon: const Icon(Icons.refresh),
          label: Text('Vérifier maintenant'.tr),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: BorderSide(color: colors.primary),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final PaiementsController controller;

  const _SuccessView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ResultView(
      key: const ValueKey('payment-success'),
      icon: Icons.check_circle,
      color: const Color(0xFF15803D),
      title: 'Paiement réussi'.tr,
      message:
          "Votre paiement a été confirmé. Le code d'activation a été généré et envoyé au bénéficiaire."
              .tr,
      reference: controller.currentTransaction?.reference,
      primaryLabel: 'Terminer'.tr,
      onPrimaryPressed: () {
        controller.resetPaymentFlow();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

class _FailureView extends StatelessWidget {
  final PaiementsController controller;

  const _FailureView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ResultView(
      key: const ValueKey('payment-failed'),
      icon: Icons.cancel,
      color: const Color(0xFFB42318),
      title: 'Paiement échoué'.tr,
      message: controller.paymentFailureReason ??
          'Le paiement n’a pas pu être finalisé.'.tr,
      reference: controller.currentTransaction?.reference,
      primaryLabel: 'Réessayer'.tr,
      onPrimaryPressed: () {
        controller.resetPaymentFlow();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      secondaryLabel: 'Fermer'.tr,
      onSecondaryPressed: () {
        controller.resetPaymentFlow();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

class _ResultView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? reference;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  const _ResultView({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.reference,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(icon, size: 96, color: color),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (reference != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _InfoRow(label: 'Référence'.tr, value: reference!),
          ),
        ],
        const SizedBox(height: 32),
        DefaultButton(
          backgroundColor: color,
          onPressed: onPrimaryPressed,
          text: primaryLabel,
        ),
        if (secondaryLabel != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSecondaryPressed,
            child: Text(secondaryLabel!),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
