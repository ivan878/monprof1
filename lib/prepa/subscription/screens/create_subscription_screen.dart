// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/prepa/subscription/controllers/create_subscription_controller.dart';
import 'package:monprof/prepa/subscription/controllers/payment_services_controller.dart';
import 'package:monprof/prepa/subscription/data/models/payment_service_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';
import 'package:monprof/prepa/subscription/screens/mes_subscriptions_screen.dart';
import 'package:page_transition/page_transition.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  final SessionModel session;

  const CreateSubscriptionScreen({super.key, required this.session});

  @override
  State<CreateSubscriptionScreen> createState() =>
      _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  PaymentServiceModel? _selectedService;

  late final PaymentServicesController _paymentCtrl;
  late final CreateSubscriptionController _createCtrl;

  @override
  void initState() {
    super.initState();
    _paymentCtrl = PaymentServicesController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    _createCtrl = CreateSubscriptionController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _paymentCtrl.loadDebitServices(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _paymentCtrl.dispose();
    _createCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey300,
      appBar: AppBar(
        title: const SimpleText(
          text: "S'inscrire",
          size: 20,
          weight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _createCtrl,
        builder: (context, _) {
          if (_createCtrl.state.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Notify.toastSuccess('Inscription réussie !');
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const MesSubscriptionsScreen(),
                ),
                (route) => route.isFirst,
              );
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SessionSummaryCard(session: widget.session),

              const SizedBox(height: 20),

              SimpleText(
                text: 'Mode de paiement',
                size: 16,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 10),

              ListenableBuilder(
                listenable: _paymentCtrl,
                builder: (context, _) {
                  if (_paymentCtrl.state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (_paymentCtrl.state.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SimpleText(
                        text: _paymentCtrl.state.errorModel?.error ??
                            'Impossible de charger les opérateurs',
                        color: Colors.red,
                        size: 13,
                      ),
                    );
                  }
                  final services = _paymentCtrl.state.data ?? [];
                  return Column(
                    children: services.map((service) {
                      final isSelected = _selectedService?.id == service.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedService = service),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SimpleText(
                                      text: service.name ?? 'Opérateur',
                                      size: 14,
                                      weight: FontWeight.w600,
                                    ),
                                    if (service.description != null)
                                      SimpleText(
                                        text: service.description!,
                                        size: 12,
                                        color: onGrey300,
                                      ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              SimpleText(
                text: 'Numéro de paiement',
                size: 16,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: TextFielApp(
                  controller: _phoneController,
                  hinText: 'Ex: 6XXXXXXXX',
                  inputType: TextInputType.phone,
                  prefixIcon:
                      const Icon(Icons.phone_rounded, color: Colors.grey),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Entrez votre numéro de téléphone';
                    }
                    if (v.trim().length < 8) return 'Numéro invalide';
                    if (_selectedService?.regExp != null) {
                      final reg = RegExp(_selectedService!.regExp!);
                      if (!reg.hasMatch(v.trim())) {
                        return 'Numéro incompatible avec cet opérateur';
                      }
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 28),

              if (_createCtrl.state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SimpleText(
                      text: _createCtrl.state.errorModel?.error ??
                          "Erreur lors de l'inscription",
                      color: Colors.red.shade700,
                      size: 13,
                    ),
                  ),
                ),

              DefaultButton(
                text: _createCtrl.state.isLoading
                    ? 'Paiement en cours...'
                    : 'Payer ${widget.session.amount?.toStringAsFixed(0) ?? ''} FCFA',
                onPressed:
                    _createCtrl.state.isLoading ? null : _submit,
                wdiget: _createCtrl.state.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _submit() {
    if (_selectedService == null) {
      Notify.toast('Veuillez sélectionner un mode de paiement');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    _createCtrl.createSubscription(
      concoursSessionId: widget.session.id,
      paymentServiceId: _selectedService!.id,
      phoneNumber: _phoneController.text.trim(),
    );
  }
}

// ── Résumé de la session ─────────────────────────────────────────────────────

class _SessionSummaryCard extends StatelessWidget {
  final SessionModel session;

  const _SessionSummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: SimpleText(
                  text: session.concoursName ?? 'Concours',
                  size: 13,
                  color: Colors.white70,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SimpleText(
            text: session.name ?? 'Session',
            size: 17,
            weight: FontWeight.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SimpleText(
                text: 'Montant à payer',
                size: 13,
                color: Colors.white70,
              ),
              SimpleText(
                text: '${session.amount?.toStringAsFixed(0) ?? '0'} FCFA',
                size: 20,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
