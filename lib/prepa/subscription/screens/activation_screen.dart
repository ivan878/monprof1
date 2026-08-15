import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/subscription/controllers/activate_code_controller.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

/// Saisie d'un code d'activation reçu d'un acheteur : ouvre l'accès au concours
/// pour l'utilisateur connecté. Un code n'est utilisable qu'une seule fois.
class ActivationScreen extends StatefulWidget {
  /// Session que l'utilisateur cherche à activer. Renseignée depuis la page
  /// d'un concours : le serveur refuse alors un code acheté pour un autre
  /// concours sans le consommer. Nulle, le code active son propre concours.
  final String? concoursSessionId;

  /// Nom du concours en contexte, pour l'affichage uniquement.
  final String? concoursName;

  const ActivationScreen({
    super.key,
    this.concoursSessionId,
    this.concoursName,
  });

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeCtrl = TextEditingController();
  late final ActivateCodeController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ActivateCodeController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    _codeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  /// 8 caractères hors tirets — format XXXX-XXXX.
  bool get _isComplete =>
      _codeCtrl.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').length == 8;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _ctrl.activate(
      _codeCtrl.text,
      concoursSessionId: widget.concoursSessionId,
    );
    if (!mounted) return;

    if (_ctrl.state.hasData) {
      final name = _ctrl.state.data?.concoursName;
      Notify.toastSuccess(
        name != null ? 'Accès activé pour $name !' : 'Accès activé !',
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final loading = _ctrl.state.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const SimpleText(
              text: 'Activer un accès',
              size: 17,
              weight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: prepaPrimaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      size: 32,
                      color: prepaPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: SimpleText(
                    text: 'Activation par code',
                    size: 20,
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SimpleText(
                    text: widget.concoursName != null
                        ? 'Saisissez le code acheté pour\n« ${widget.concoursName} ».'
                        : 'Saisissez le code reçu pour\ndébloquer votre accès.',
                    size: 14,
                    color: onGrey300,
                    align: TextAlign.center,
                  ),
                ),
                if (widget.concoursName != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: SimpleText(
                      text: 'Un code acheté pour un autre concours sera refusé.',
                      size: 12,
                      color: Colors.grey.shade400,
                      align: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                SimpleText(
                  text: 'CODE D\'ACTIVATION',
                  size: 11,
                  weight: FontWeight.bold,
                  color: onGrey300,
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _codeCtrl,
                  enabled: !loading,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (_isComplete && !loading) _submit();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                    LengthLimitingTextInputFormatter(9), // 8 + tiret
                    _UpperCaseFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXX-XXXX',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      letterSpacing: 5,
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: prepaPrimaryColor, width: 1.5),
                    ),
                  ),
                ),

                // Erreur backend (code invalide, déjà utilisé, accès existant…)
                if (_ctrl.state.hasError) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 17, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SimpleText(
                            text: _ctrl.state.errorModel?.error ??
                                'Code invalide ou déjà utilisé',
                            size: 13,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isComplete && !loading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prepaPrimaryColor,
                      disabledBackgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : SimpleText(
                            text: 'Activer',
                            size: 15,
                            weight: FontWeight.bold,
                            color: _isComplete
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: SimpleText(
                    text: 'Un code ne peut être utilisé qu\'une seule fois.',
                    size: 12,
                    color: Colors.grey.shade400,
                    align: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Force la saisie en majuscules sans déplacer le curseur.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
