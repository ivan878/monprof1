import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/presentation/categorie_summary_widget.dart';
import 'package:monprof/paiements/presentation/payment_confirmation_screen.dart';
import 'package:monprof/paiements/presentation/widgets/payment_service_logo.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PaiementsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaiementsController(
      repository: GetIt.instance<PaiementRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getPaymentServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaiementsController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Paiement d'une place".tr)),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _SectionTitle(
                    icon: Icons.school_outlined,
                    title: 'Votre commande'.tr,
                  ),
                  const SizedBox(height: 10),
                  const _Card(child: CategorieSummaryWidget()),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.phone_android,
                    title: 'Informations de paiement'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentForm(controller),
                  const SizedBox(height: 28),
                  DefaultButton(
                    onPressed: controller.paymentServiceState.hasData
                        ? () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            if (!controller.validateSelectedPaymentService()) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PaymentConfirmationScreen(),
                              ),
                            );
                          }
                        : null,
                    text: 'Continuer'.tr,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentForm(PaiementsController controller) {
    final colors = Theme.of(context).colorScheme;
    if (controller.paymentServiceState.isLoading ||
        controller.paymentServiceState.status == AppStatus.starting) {
      return const _Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.paymentServiceState.hasError ||
        (controller.paymentServiceState.data?.isEmpty ?? true)) {
      return _Card(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              controller.paymentServiceState.errorModel?.error ??
                  'Aucun service de paiement entrant disponible'.tr,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: controller.getPaymentServices,
              icon: const Icon(Icons.refresh),
              label: Text('Réessayer'.tr),
            ),
          ],
        ),
      );
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Numéro du bénéficiaire'.tr,
            style: textStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFielApp(
            lenght: 9,
            controller: controller.controllerNumeroClient,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: ValidationBuilder(
              requiredMessage: 'Numéro du bénéficiaire requis'.tr,
            ).minLength(9, 'Numéro invalide'.tr).maxLength(9).build(),
            inputType: TextInputType.phone,
            hinText: '6XX XXX XXX',
          ),
          const SizedBox(height: 18),
          Text(
            'Numéro du payeur'.tr,
            style: textStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFielApp(
            lenght: 9,
            controller: controller.controllerNumeroPayeur,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: ValidationBuilder(
              requiredMessage: 'Numéro du payeur requis'.tr,
            ).minLength(9, 'Numéro invalide'.tr).maxLength(9).build(),
            inputType: TextInputType.phone,
            hinText: '6XX XXX XXX',
            onChanged: controller.selectPaymentServiceFromNumber,
            suffixIcon: controller.selectedPaymentService == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(7),
                    child: PaymentServiceLogo(
                      imageUrl: controller.selectedPaymentService!.imageUrl,
                      size: 34,
                    ),
                  ),
          ),
          if (controller.selectedPaymentService != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                PaymentServiceLogo(
                  imageUrl: controller.selectedPaymentService!.imageUrl,
                  size: 34,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    controller.selectedPaymentService!.title,
                    style: textStyle.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 9),
        Text(
          title,
          style: textStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
