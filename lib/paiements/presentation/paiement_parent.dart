import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/presentation/payment_confirmation_screen.dart';
import 'package:monprof/paiements/presentation/widgets/payment_service_logo.dart';

class PaimentParentScreen extends StatefulWidget {
  const PaimentParentScreen({super.key});

  @override
  State<PaimentParentScreen> createState() => _PaimentParentScreenState();
}

class _PaimentParentScreenState extends State<PaimentParentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PaiementsController _controller;

  @override
  void initState() {
    super.initState();
    final homeController = Get.find<HomeController>();
    _controller = PaiementsController(
      repository: GetIt.instance<PaiementRepository>(),
      categorie: homeController.categorieParent,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getPaymentServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final colors = Theme.of(context).colorScheme;

    return GetBuilder<PaiementsController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Paiement d'un abonnement".tr)),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abonnement'.tr,
                          style: textStyle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<CategorieParentStatus>(
                          initialValue: controller.categorie,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null
                              ? 'Choisissez une catégorie'.tr
                              : null,
                          items:
                              (homeController.categorieParentState.data ?? [])
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.categorie.libelle ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged: controller.changeCategorieParent,
                        ),
                        const SizedBox(height: 16),
                        TextFielApp(
                          hinText: 'Quantité'.tr,
                          inputType: TextInputType.number,
                          controller: controller.controllerQuantite,
                          onChanged: controller.changeQuantity,
                          validator: (value) {
                            final quantity = int.tryParse(value ?? '');
                            if (quantity == null || quantity < 1) {
                              return 'Saisissez une quantité valide'.tr;
                            }
                            if (quantity > 100) {
                              return 'La quantité maximale est 100'.tr;
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _AmountRow(
                                label: 'Montant'.tr,
                                value: controller.totalPrice,
                              ),
                              if (controller.selectedPaymentService !=
                                  null) ...[
                                const SizedBox(height: 8),
                                _AmountRow(
                                  label: 'Frais de service'.tr,
                                  value: controller.serviceFee,
                                ),
                                const SizedBox(height: 8),
                                Divider(color: colors.outlineVariant),
                                const SizedBox(height: 4),
                                _AmountRow(
                                  label: 'Total à payer'.tr,
                                  value: controller.totalAmount,
                                  emphasize: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de paiement'.tr,
                          style: textStyle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFielApp(
                          lenght: 9,
                          controller: controller.controllerNumeroClient,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: ValidationBuilder(
                            requiredMessage: 'Numéro du bénéficiaire requis'.tr,
                          ).minLength(9).maxLength(9).build(),
                          inputType: TextInputType.phone,
                          hinText: 'Numéro du bénéficiaire'.tr,
                        ),
                        const SizedBox(height: 14),
                        TextFielApp(
                          lenght: 9,
                          controller: controller.controllerNumeroPayeur,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: ValidationBuilder(
                            requiredMessage: 'Numéro du payeur requis'.tr,
                          ).minLength(9).maxLength(9).build(),
                          inputType: TextInputType.phone,
                          hinText: 'Numéro du payeur'.tr,
                          onChanged: controller.selectPaymentServiceFromNumber,
                        ),
                        if (controller.selectedPaymentService != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              PaymentServiceLogo(
                                imageUrl:
                                    controller.selectedPaymentService!.imageUrl,
                                size: 36,
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
                  ),
                  if (controller.paymentServiceState.hasError) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: controller.getPaymentServices,
                      icon: const Icon(Icons.refresh),
                      label: Text('Recharger les services de paiement'.tr),
                    ),
                  ],
                  const SizedBox(height: 26),
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

class _AmountRow extends StatelessWidget {
  final String label;
  final int value;
  final bool emphasize;

  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '$value XAF',
          style: textStyle.copyWith(
            color: colors.primary,
            fontSize: emphasize ? 17 : 15,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
