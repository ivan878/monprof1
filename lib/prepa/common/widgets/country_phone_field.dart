import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:country_flags/country_flags.dart';

// ── Country data ──────────────────────────────────────────────────────────────

class CountryData {
  final String isoCode;
  final String name;
  final String dialCode;
  final String flag;

  const CountryData({
    required this.isoCode,
    required this.name,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryData> kCountries = [
  // Cameroun en premier
  CountryData(isoCode: 'CM', name: 'Cameroun', dialCode: '+237', flag: '🇨🇲'),
  // Afrique (ordre alphabétique)
  CountryData(
      isoCode: 'ZA', name: 'Afrique du Sud', dialCode: '+27', flag: '🇿🇦'),
  CountryData(isoCode: 'DZ', name: 'Algérie', dialCode: '+213', flag: '🇩🇿'),
  CountryData(isoCode: 'AO', name: 'Angola', dialCode: '+244', flag: '🇦🇴'),
  CountryData(isoCode: 'BJ', name: 'Bénin', dialCode: '+229', flag: '🇧🇯'),
  CountryData(isoCode: 'BW', name: 'Botswana', dialCode: '+267', flag: '🇧🇼'),
  CountryData(
      isoCode: 'BF', name: 'Burkina Faso', dialCode: '+226', flag: '🇧🇫'),
  CountryData(isoCode: 'BI', name: 'Burundi', dialCode: '+257', flag: '🇧🇮'),
  CountryData(
      isoCode: 'CV', name: 'Cabo Verde', dialCode: '+238', flag: '🇨🇻'),
  CountryData(
      isoCode: 'CF', name: 'Centrafrique', dialCode: '+236', flag: '🇨🇫'),
  CountryData(isoCode: 'KM', name: 'Comores', dialCode: '+269', flag: '🇰🇲'),
  CountryData(isoCode: 'CG', name: 'Congo', dialCode: '+242', flag: '🇨🇬'),
  CountryData(
      isoCode: 'CD', name: 'Congo (RDC)', dialCode: '+243', flag: '🇨🇩'),
  CountryData(
      isoCode: 'CI', name: "Côte d'Ivoire", dialCode: '+225', flag: '🇨🇮'),
  CountryData(isoCode: 'DJ', name: 'Djibouti', dialCode: '+253', flag: '🇩🇯'),
  CountryData(isoCode: 'EG', name: 'Égypte', dialCode: '+20', flag: '🇪🇬'),
  CountryData(isoCode: 'ER', name: 'Érythrée', dialCode: '+291', flag: '🇪🇷'),
  CountryData(isoCode: 'SZ', name: 'Eswatini', dialCode: '+268', flag: '🇸🇿'),
  CountryData(isoCode: 'ET', name: 'Éthiopie', dialCode: '+251', flag: '🇪🇹'),
  CountryData(isoCode: 'GA', name: 'Gabon', dialCode: '+241', flag: '🇬🇦'),
  CountryData(isoCode: 'GM', name: 'Gambie', dialCode: '+220', flag: '🇬🇲'),
  CountryData(isoCode: 'GH', name: 'Ghana', dialCode: '+233', flag: '🇬🇭'),
  CountryData(isoCode: 'GN', name: 'Guinée', dialCode: '+224', flag: '🇬🇳'),
  CountryData(
      isoCode: 'GQ',
      name: 'Guinée Équatoriale',
      dialCode: '+240',
      flag: '🇬🇶'),
  CountryData(
      isoCode: 'GW', name: 'Guinée-Bissau', dialCode: '+245', flag: '🇬🇼'),
  CountryData(isoCode: 'KE', name: 'Kenya', dialCode: '+254', flag: '🇰🇪'),
  CountryData(isoCode: 'LS', name: 'Lesotho', dialCode: '+266', flag: '🇱🇸'),
  CountryData(isoCode: 'LR', name: 'Libéria', dialCode: '+231', flag: '🇱🇷'),
  CountryData(isoCode: 'LY', name: 'Libye', dialCode: '+218', flag: '🇱🇾'),
  CountryData(
      isoCode: 'MG', name: 'Madagascar', dialCode: '+261', flag: '🇲🇬'),
  CountryData(isoCode: 'MW', name: 'Malawi', dialCode: '+265', flag: '🇲🇼'),
  CountryData(isoCode: 'ML', name: 'Mali', dialCode: '+223', flag: '🇲🇱'),
  CountryData(isoCode: 'MA', name: 'Maroc', dialCode: '+212', flag: '🇲🇦'),
  CountryData(isoCode: 'MU', name: 'Maurice', dialCode: '+230', flag: '🇲🇺'),
  CountryData(
      isoCode: 'MR', name: 'Mauritanie', dialCode: '+222', flag: '🇲🇷'),
  CountryData(isoCode: 'YT', name: 'Mayotte', dialCode: '+262', flag: '🇾🇹'),
  CountryData(
      isoCode: 'MZ', name: 'Mozambique', dialCode: '+258', flag: '🇲🇿'),
  CountryData(isoCode: 'NA', name: 'Namibie', dialCode: '+264', flag: '🇳🇦'),
  CountryData(isoCode: 'NE', name: 'Niger', dialCode: '+227', flag: '🇳🇪'),
  CountryData(isoCode: 'NG', name: 'Nigéria', dialCode: '+234', flag: '🇳🇬'),
  CountryData(isoCode: 'UG', name: 'Ouganda', dialCode: '+256', flag: '🇺🇬'),
  CountryData(isoCode: 'RE', name: 'Réunion', dialCode: '+262', flag: '🇷🇪'),
  CountryData(isoCode: 'RW', name: 'Rwanda', dialCode: '+250', flag: '🇷🇼'),
  CountryData(isoCode: 'SN', name: 'Sénégal', dialCode: '+221', flag: '🇸🇳'),
  CountryData(
      isoCode: 'SC', name: 'Seychelles', dialCode: '+248', flag: '🇸🇨'),
  CountryData(
      isoCode: 'SL', name: 'Sierra Leone', dialCode: '+232', flag: '🇸🇱'),
  CountryData(isoCode: 'SO', name: 'Somalie', dialCode: '+252', flag: '🇸🇴'),
  CountryData(isoCode: 'SD', name: 'Soudan', dialCode: '+249', flag: '🇸🇩'),
  CountryData(
      isoCode: 'SS', name: 'Soudan du Sud', dialCode: '+211', flag: '🇸🇸'),
  CountryData(
      isoCode: 'ST',
      name: 'São Tomé-et-Príncipe',
      dialCode: '+239',
      flag: '🇸🇹'),
  CountryData(isoCode: 'TZ', name: 'Tanzanie', dialCode: '+255', flag: '🇹🇿'),
  CountryData(isoCode: 'TD', name: 'Tchad', dialCode: '+235', flag: '🇹🇩'),
  CountryData(isoCode: 'TG', name: 'Togo', dialCode: '+228', flag: '🇹🇬'),
  CountryData(isoCode: 'TN', name: 'Tunisie', dialCode: '+216', flag: '🇹🇳'),
  CountryData(isoCode: 'ZM', name: 'Zambie', dialCode: '+260', flag: '🇿🇲'),
  CountryData(isoCode: 'ZW', name: 'Zimbabwe', dialCode: '+263', flag: '🇿🇼'),
  // Europe
  CountryData(isoCode: 'DE', name: 'Allemagne', dialCode: '+49', flag: '🇩🇪'),
  CountryData(isoCode: 'BE', name: 'Belgique', dialCode: '+32', flag: '🇧🇪'),
  CountryData(isoCode: 'ES', name: 'Espagne', dialCode: '+34', flag: '🇪🇸'),
  CountryData(isoCode: 'FR', name: 'France', dialCode: '+33', flag: '🇫🇷'),
  CountryData(
      isoCode: 'GB', name: 'Royaume-Uni', dialCode: '+44', flag: '🇬🇧'),
  CountryData(isoCode: 'IT', name: 'Italie', dialCode: '+39', flag: '🇮🇹'),
  CountryData(isoCode: 'NL', name: 'Pays-Bas', dialCode: '+31', flag: '🇳🇱'),
  CountryData(isoCode: 'PT', name: 'Portugal', dialCode: '+351', flag: '🇵🇹'),
  CountryData(isoCode: 'CH', name: 'Suisse', dialCode: '+41', flag: '🇨🇭'),
  // Amériques
  CountryData(isoCode: 'BR', name: 'Brésil', dialCode: '+55', flag: '🇧🇷'),
  CountryData(isoCode: 'CA', name: 'Canada', dialCode: '+1', flag: '🇨🇦'),
  CountryData(isoCode: 'US', name: 'États-Unis', dialCode: '+1', flag: '🇺🇸'),
  // Asie / Moyen-Orient
  CountryData(isoCode: 'CN', name: 'Chine', dialCode: '+86', flag: '🇨🇳'),
  CountryData(isoCode: 'IN', name: 'Inde', dialCode: '+91', flag: '🇮🇳'),
  CountryData(isoCode: 'JP', name: 'Japon', dialCode: '+81', flag: '🇯🇵'),
  CountryData(isoCode: 'LB', name: 'Liban', dialCode: '+961', flag: '🇱🇧'),
  CountryData(
      isoCode: 'SA', name: 'Arabie Saoudite', dialCode: '+966', flag: '🇸🇦'),
  CountryData(
      isoCode: 'AE',
      name: 'Émirats Arabes Unis',
      dialCode: '+971',
      flag: '🇦🇪'),
];

CountryData _findByDialCode(String dialCode) {
  return kCountries.firstWhere(
    (c) => c.dialCode == dialCode,
    orElse: () => kCountries.first,
  );
}

/// Parse a full international number (e.g. "+237654321234") into country + local part.
(CountryData, String) parseInternationalPhone(String fullPhone) {
  final sorted = [...kCountries]
    ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
  for (final country in sorted) {
    if (fullPhone.startsWith(country.dialCode)) {
      return (country, fullPhone.substring(country.dialCode.length));
    }
  }
  return (kCountries.first, fullPhone);
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Champ téléphone avec sélecteur de pays intégré.
///
/// [controller] reçoit uniquement les chiffres locaux (sans indicatif).
/// [onDialCodeChanged] est appelé à chaque changement de pays.
/// [initialPhone] optionnel: numéro international complet pour pré-remplir
///   (ex. "+237654321234" → sélectionne 🇨🇲 +237 et affiche "654321234").
class CountryPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? initialPhone;
  final String initialDialCode;
  final void Function(String dialCode)? onDialCodeChanged;
  final String? Function(String?)? validator;

  const CountryPhoneField({
    super.key,
    required this.controller,
    this.initialPhone,
    this.initialDialCode = '+237',
    this.onDialCodeChanged,
    this.validator,
  });

  @override
  State<CountryPhoneField> createState() => _CountryPhoneFieldState();
}

class _CountryPhoneFieldState extends State<CountryPhoneField> {
  late CountryData _selectedCountry;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPhone;
    if (initial != null && initial.isNotEmpty) {
      final (country, local) = parseInternationalPhone(initial);
      _selectedCountry = country;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.text = local;
        widget.onDialCodeChanged?.call(country.dialCode);
      });
    } else {
      _selectedCountry = _findByDialCode(widget.initialDialCode);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDialCodeChanged?.call(_selectedCountry.dialCode);
      });
    }
  }

  void _openPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPickerSheet(
        selected: _selectedCountry,
        onSelected: (country) {
          setState(() => _selectedCountry = country);
          widget.onDialCodeChanged?.call(country.dialCode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 0.3),
    );

    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: widget.validator,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        hintText: '6 XX XX XX XX',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        border: borderStyle,
        enabledBorder: borderStyle,
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        prefixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _openPicker,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag.fromCountryCode(
                        _selectedCountry.isoCode,
                        theme: const ImageTheme(
                          width: 28,
                          height: 20,
                          shape: RoundedRectangle(4),
                        ),
                      ),
                      // Text(
                      //   _selectedCountry.flag,
                      //   style: const TextStyle(fontSize: 22),
                      // ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountry.dialCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(0xFFB3B3B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Country picker sheet ───────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  final CountryData selected;
  final void Function(CountryData) onSelected;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<CountryData> _filtered = kCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? kCountries
          : kCountries
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.dialCode.contains(q) ||
                  c.isoCode.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sélectionner un pays',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays ou indicatif...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('Aucun résultat',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        final isSelected =
                            c.isoCode == widget.selected.isoCode &&
                                c.dialCode == widget.selected.dialCode;
                        return ListTile(
                          // leading: Text(
                          //   c.flag,
                          //   style: const TextStyle(fontSize: 26),
                          // ),
                          leading: CountryFlag.fromCountryCode(
                            c.isoCode,
                            theme: const ImageTheme(
                              width: 32,
                              height: 22,
                              shape: RoundedRectangle(4),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            c.dialCode,
                            style: TextStyle(
                              color:
                                  isSelected ? prepaPrimaryColor : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor:
                              prepaPrimaryColor.withValues(alpha: 0.05),
                          onTap: () {
                            widget.onSelected(c);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
