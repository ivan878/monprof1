// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/prepa/subscription/controllers/init_payment_controller.dart';
import 'package:monprof/prepa/subscription/controllers/payment_services_controller.dart';
import 'package:monprof/prepa/subscription/data/models/payment_service_model.dart';
import 'package:monprof/prepa/subscription/data/models/transaction_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class PaymentScreen extends StatefulWidget {
  final ConcoursModel concours;

  const PaymentScreen({super.key, required this.concours});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  late final PaymentServicesController _servicesCtrl;
  late final InitPaymentController _paymentCtrl;

  PaymentServiceModel? _selectedService;
  int _count = 1;

  bool get _hasSession => widget.concours.activeSession != null;
  SessionModel get _session => widget.concours.activeSession!;

  // ── Préfixes opérateurs Cameroun ──────────────────────────────────────────
  static const _orangePrefixes = [
    '640',
    '655', '656', '657', '658', '659',
    '686', '687', '688', '689',
    '690', '691', '692', '693', '694',
    '695', '696', '697', '698', '699',
  ];
  static const _mtnPrefixes = [
    '650', '651', '652', '653', '654',
    '670', '671', '672', '673', '674',
    '675', '676', '677', '678', '679',
    '680', '681', '682', '683',
  ];

  @override
  void initState() {
    super.initState();
    _servicesCtrl = PaymentServicesController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    _paymentCtrl = InitPaymentController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    _phoneCtrl.addListener(_onPhoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _servicesCtrl.loadDebitServices();
    });
  }

  void _onPhoneChanged() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 3) return;

    final prefix = phone.substring(0, 3);
    final services = _servicesCtrl.state.data ?? [];
    if (services.isEmpty) return;

    PaymentServiceModel? match;
    if (_orangePrefixes.contains(prefix)) {
      try {
        match = services.firstWhere(
          (s) => s.name?.toLowerCase().contains('orange') == true,
        );
      } catch (_) {}
    } else if (_mtnPrefixes.contains(prefix)) {
      try {
        match = services.firstWhere(
          (s) => s.name?.toLowerCase().contains('mtn') == true,
        );
      } catch (_) {}
    }

    if (match != null && match.id != _selectedService?.id) {
      setState(() => _selectedService = match);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    _servicesCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SimpleText(
              text: 'Souscription',
              size: 17,
              weight: FontWeight.bold,
            ),
            if (widget.concours.name != null)
              SimpleText(
                text: widget.concours.name!,
                size: 12,
                color: onGrey300,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListenableBuilder(
        listenable: _paymentCtrl,
        builder: (context, _) {
          if (_paymentCtrl.initiationState.hasData) {
            return _PollingView(
              ctrl: _paymentCtrl,
              concours: widget.concours,
              count: _count,
              onRetry: () {
                _paymentCtrl.reset();
                setState(() {});
              },
            );
          }

          if (!_hasSession) {
            return _NoSessionView(concoursName: widget.concours.name);
          }

          return _FormView(
            concours: widget.concours,
            session: _session,
            count: _count,
            formKey: _formKey,
            phoneCtrl: _phoneCtrl,
            selectedService: _selectedService,
            servicesCtrl: _servicesCtrl,
            paymentCtrl: _paymentCtrl,
            onCountChanged: (v) => setState(() => _count = v),
            onServiceSelected: (s) => setState(() => _selectedService = s),
            onSubmit: _submit,
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
    if (!_hasSession) return;

    _paymentCtrl.initiate(
      sessionId: _session.id,
      paymentServiceId: _selectedService!.id,
      phoneNumber: _phoneCtrl.text.trim(),
      count: _count,
    );
  }
}

// ── Formulaire ────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final ConcoursModel concours;
  final SessionModel session;
  final int count;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final PaymentServiceModel? selectedService;
  final PaymentServicesController servicesCtrl;
  final InitPaymentController paymentCtrl;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<PaymentServiceModel> onServiceSelected;
  final VoidCallback onSubmit;

  const _FormView({
    required this.concours,
    required this.session,
    required this.count,
    required this.formKey,
    required this.phoneCtrl,
    required this.selectedService,
    required this.servicesCtrl,
    required this.paymentCtrl,
    required this.onCountChanged,
    required this.onServiceSelected,
    required this.onSubmit,
  });

  double get _subscriptionFee => (session.amount ?? 0) * count;

  double get _combinedProviderRate =>
      (selectedService?.rate ?? 0) + (selectedService?.providerRate ?? 0);

  double get _total =>
      (_subscriptionFee * (1 + _combinedProviderRate)).roundToDouble();

  double get _providerFee => _total - _subscriptionFee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // ── Récapitulatif ─────────────────────────────────────────────
              _SummaryBlock(
                concours: concours,
                session: session,
                count: count,
                subscriptionFee: _subscriptionFee,
                providerFee: _providerFee,
                total: _total,
              ),
              Divider(height: 1, color: Colors.grey.shade100),

              // ── Nombre de places ──────────────────────────────────────────
              _SectionHeader(label: 'PLACES'),
              _CountRow(count: count, onChanged: onCountChanged),
              Divider(height: 1, color: Colors.grey.shade100),

              // ── Mode de paiement ──────────────────────────────────────────
              _SectionHeader(label: 'MODE DE PAIEMENT'),
              ListenableBuilder(
                listenable: servicesCtrl,
                builder: (context, _) {
                  if (servicesCtrl.state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: prepaPrimaryColor)),
                    );
                  }
                  if (servicesCtrl.state.hasError) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SimpleText(
                        text: servicesCtrl.state.errorModel?.error ??
                            'Impossible de charger les opérateurs',
                        color: Colors.red.shade600,
                        size: 13,
                      ),
                    );
                  }
                  final services = servicesCtrl.state.data ?? [];
                  return Column(
                    children: [
                      for (int i = 0; i < services.length; i++) ...[
                        _ServiceRow(
                          service: services[i],
                          isSelected: selectedService?.id == services[i].id,
                          onTap: () => onServiceSelected(services[i]),
                        ),
                        if (i < services.length - 1)
                          Divider(
                              height: 1,
                              indent: 72,
                              color: Colors.grey.shade100),
                      ],
                    ],
                  );
                },
              ),
              Divider(height: 1, color: Colors.grey.shade100),

              // ── Numéro ────────────────────────────────────────────────────
              _SectionHeader(label: 'NUMÉRO MOBILE MONEY'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Form(
                  key: formKey,
                  child: TextFielApp(
                    controller: phoneCtrl,
                    hinText: 'Ex : 6XXXXXXXX',
                    inputType: TextInputType.phone,
                    prefixIcon:
                        const Icon(Icons.phone_rounded, color: Colors.grey),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Entrez votre numéro';
                      }
                      if (v.trim().length < 8) return 'Numéro invalide';
                      if (selectedService?.regExp != null) {
                        if (!RegExp(selectedService!.regExp!)
                            .hasMatch(v.trim())) {
                          return 'Numéro incompatible avec cet opérateur';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SimpleText(
                  text:
                      'Une demande de confirmation sera envoyée sur ce numéro.',
                  size: 12,
                  color: onGrey300,
                ),
              ),

              // ── Erreur initiation ─────────────────────────────────────────
              if (paymentCtrl.initiationState.hasError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SimpleText(
                          text:
                              paymentCtrl.initiationState.errorModel?.error ??
                                  "Erreur lors de l'initiation",
                          color: Colors.red.shade700,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // ── Bouton collé en bas ────────────────────────────────────────────
        _BottomPayButton(
          loading: paymentCtrl.initiationState.isLoading,
          total: _total,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// ── Récapitulatif concours + session ─────────────────────────────────────────

class _SummaryBlock extends StatelessWidget {
  final ConcoursModel concours;
  final SessionModel session;
  final int count;
  final double subscriptionFee;
  final double providerFee;
  final double total;

  const _SummaryBlock({
    required this.concours,
    required this.session,
    required this.count,
    required this.subscriptionFee,
    required this.providerFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Concours name — prominent
          SimpleText(
            text: concours.name ?? session.concoursName ?? 'Concours',
            size: 22,
            weight: FontWeight.bold,
            color: darkColor,
          ),
          const SizedBox(height: 4),
          SimpleText(
            text: session.name ?? 'Session',
            size: 14,
            color: onGrey300,
          ),
          if (session.startDate != null || session.endDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                SimpleText(
                  text: [
                    if (session.startDate != null)
                      fmt.format(session.startDate!),
                    if (session.endDate != null) fmt.format(session.endDate!),
                  ].join(' – '),
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _SummaryAmountRow(
            label: 'Frais d’abonnement',
            amount: subscriptionFee,
            detail: count > 1
                ? '$count × ${session.amount?.toStringAsFixed(0)} FCFA'
                : null,
          ),
          const SizedBox(height: 12),
          _SummaryAmountRow(
            label: 'Frais fournisseur',
            amount: providerFee,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text: 'TOTAL',
                    size: 11,
                    weight: FontWeight.bold,
                    color: onGrey300,
                  ),
                ],
              ),
              SimpleText(
                text: '${total.toStringAsFixed(0)} FCFA',
                size: 26,
                weight: FontWeight.bold,
                color: darkColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryAmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final String? detail;

  const _SummaryAmountRow({
    required this.label,
    required this.amount,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SimpleText(
                text: label,
                size: 13,
                color: onGrey300,
              ),
              if (detail != null)
                SimpleText(
                  text: detail!,
                  size: 11,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SimpleText(
          text: '${amount.toStringAsFixed(0)} FCFA',
          size: 14,
          weight: FontWeight.w600,
          color: darkColor,
        ),
      ],
    );
  }
}

// ── En-tête de section ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: SimpleText(
        text: label,
        size: 11,
        weight: FontWeight.bold,
        color: onGrey300,
      ),
    );
  }
}

// ── Compteur de places ────────────────────────────────────────────────────────

class _CountRow extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;

  const _CountRow({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 20, color: prepaPrimaryColor),
          const SizedBox(width: 12),
          const Expanded(
            child: SimpleText(
              text: 'Nombre de personnes',
              size: 14,
            ),
          ),
          _CountBtn(
            icon: Icons.remove,
            enabled: count > 1,
            onTap: () => onChanged(count - 1),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: SimpleText(
                text: '$count',
                size: 16,
                weight: FontWeight.bold,
                color: darkColor,
              ),
            ),
          ),
          _CountBtn(
            icon: Icons.add,
            enabled: count < 10,
            onTap: () => onChanged(count + 1),
          ),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CountBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? prepaPrimaryColor : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? prepaPrimaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }
}

// ── Ligne de service de paiement ─────────────────────────────────────────────

class _ServiceRow extends StatelessWidget {
  final PaymentServiceModel service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? prepaPrimaryColor.withValues(alpha: 0.04)
              : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: prepaPrimaryColor, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            // Logo
            _ServiceLogo(logoUrl: service.logoUrl, name: service.name),
            const SizedBox(width: 14),
            // Nom + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text: service.name ?? 'Opérateur',
                    size: 14,
                    weight: FontWeight.w600,
                    color: darkColor,
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
            // Indicateur de sélection
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? prepaPrimaryColor : Colors.grey.shade300,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceLogo extends StatelessWidget {
  final String? logoUrl;
  final String? name;

  const _ServiceLogo({this.logoUrl, this.name});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: logoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          placeholder: (_, __) => _placeholder(),
          errorWidget: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SimpleText(
          text: (name ?? '?').substring(0, 1).toUpperCase(),
          size: 18,
          weight: FontWeight.bold,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ── Bouton de paiement ────────────────────────────────────────────────────────

class _BottomPayButton extends StatelessWidget {
  final bool loading;
  final double total;
  final VoidCallback onPressed;

  const _BottomPayButton({
    required this.loading,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: DefaultButton(
        backgroundColor: prepaPrimaryColor,
        text: loading ? 'Initiation…' : 'Payer ${total.toStringAsFixed(0)} FCFA',
        onPressed: loading ? null : onPressed,
        wdiget: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : null,
      ),
    );
  }
}

// ── Polling ───────────────────────────────────────────────────────────────────

class _PollingView extends StatelessWidget {
  final InitPaymentController ctrl;
  final ConcoursModel concours;
  final int count;
  final VoidCallback onRetry;

  const _PollingView({
    required this.ctrl,
    required this.concours,
    required this.count,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final pollingState = ctrl.pollingState;
        final tx = pollingState.data;
        final status = tx?.status?.toUpperCase() ?? '';

        if (status == 'SUCCESS') {
          return _SuccessView(concours: concours, count: count, tx: tx!);
        }

        if (status == 'FAILED' || status == 'CANCELED') {
          return _FailureView(reason: tx?.raisonReject, onRetry: onRetry);
        }

        if (pollingState.hasError) {
          return _FailureView(
              reason: pollingState.errorModel?.error, onRetry: onRetry);
        }

        return _PendingView(tx: tx);
      },
    );
  }
}

class _PendingView extends StatelessWidget {
  final TransactionModel? tx;
  const _PendingView({this.tx});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: prepaPrimaryColor,
              ),
            ),
            const SizedBox(height: 32),
            SimpleText(
              text: 'En attente de confirmation',
              size: 18,
              weight: FontWeight.bold,
              color: darkColor,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SimpleText(
              text:
                  'Confirmez la demande sur votre téléphone Mobile Money.',
              size: 14,
              color: onGrey300,
              align: TextAlign.center,
            ),
            if (tx?.phoneNumber != null) ...[
              const SizedBox(height: 8),
              SimpleText(
                text: tx!.phoneNumber!,
                size: 14,
                weight: FontWeight.w600,
                color: darkColor,
              ),
            ],
            const SizedBox(height: 32),
            SimpleText(
              text: 'Vérification automatique toutes les 10 s',
              size: 12,
              color: Colors.grey.shade400,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final ConcoursModel concours;
  final int count;
  final TransactionModel tx;

  const _SuccessView({
    required this.concours,
    required this.count,
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade100, width: 2),
            ),
            child: Icon(Icons.check_rounded,
                color: Colors.green.shade600, size: 36),
          ),
          const SizedBox(height: 24),
          SimpleText(
            text: 'Paiement confirmé',
            size: 20,
            weight: FontWeight.bold,
            color: darkColor,
            align: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SimpleText(
            text:
                'Votre souscription à ${concours.name ?? 'ce concours'} est maintenant active.',
            size: 14,
            color: onGrey300,
            align: TextAlign.center,
          ),
          if (count > 1) ...[
            const SizedBox(height: 8),
            SimpleText(
              text: '$count places réservées',
              size: 13,
              weight: FontWeight.w600,
              color: Colors.green.shade600,
            ),
          ],
          const SizedBox(height: 40),
          DefaultButton(
            backgroundColor: prepaPrimaryColor,
            text: 'Retour à l\'accueil',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  final String? reason;
  final VoidCallback onRetry;

  const _FailureView({this.reason, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade100, width: 2),
            ),
            child:
                Icon(Icons.close_rounded, color: Colors.red.shade600, size: 36),
          ),
          const SizedBox(height: 24),
          SimpleText(
            text: 'Paiement échoué',
            size: 20,
            weight: FontWeight.bold,
            color: darkColor,
            align: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SimpleText(
            text: reason ??
                'Le paiement n\'a pas pu être confirmé. Vérifiez votre solde.',
            size: 14,
            color: onGrey300,
            align: TextAlign.center,
          ),
          const SizedBox(height: 36),
          DefaultButton(
            backgroundColor: prepaPrimaryColor,
            text: 'Réessayer',
            onPressed: onRetry,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SimpleText(
                text: 'Annuler',
                size: 14,
                color: onGrey300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pas de session active ─────────────────────────────────────────────────────

class _NoSessionView extends StatelessWidget {
  final String? concoursName;
  const _NoSessionView({this.concoursName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            SimpleText(
              text: concoursName != null
                  ? 'Aucune session active pour $concoursName'
                  : 'Aucune session active pour ce concours',
              size: 16,
              weight: FontWeight.bold,
              color: darkColor,
              align: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SimpleText(
              text: 'La prochaine session sera disponible prochainement.',
              size: 13,
              color: onGrey300,
              align: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SimpleText(
                  text: 'Retour',
                  size: 14,
                  color: onGrey300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
