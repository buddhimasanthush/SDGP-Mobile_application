import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_success_page.dart';

class PaymentGatewayPage extends StatefulWidget {
  final String amount;
  final String pharmacyName;

  const PaymentGatewayPage({
    super.key,
    required this.amount,
    required this.pharmacyName,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _isVisa = true;
  bool _obscureCvv = true;
  bool _isProcessing = false;

  // Parse base amount and compute fee + total
  double get _baseAmount {
    final cleaned = widget.amount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  double get _processingFee => (_baseAmount * 0.03).roundToDouble();
  double get _totalAmount => _baseAmount + _processingFee;

  String get _displayCardNumber {
    final raw = _cardNumberCtrl.text.replaceAll(' ', '');
    if (raw.isEmpty) return '**** **** **** ****';
    final padded = raw.padRight(16, '*');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }

  String get _displayName => _cardNameCtrl.text.isEmpty
      ? 'FULL NAME'
      : _cardNameCtrl.text.toUpperCase();

  String get _displayExpiry =>
      _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _pay() async {
    if (_cardNumberCtrl.text.replaceAll(' ', '').length < 16 ||
        _cardNameCtrl.text.isEmpty ||
        _expiryCtrl.text.length < 5 ||
        _cvvCtrl.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all card details',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFFEF5350),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
                  amount: 'RS.${_totalAmount.toStringAsFixed(0)}',
                  pharmacyName: widget.pharmacyName,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  ),
                ),
                const Expanded(
                  child: Text('Secure Payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 40),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(children: [
                  // ── Card preview ────────────────────────────────────
                  _buildCardPreview(),
                  const SizedBox(height: 16),

                  // ── Visa / Mastercard toggle ────────────────────────
                  _buildToggle(),
                  const SizedBox(height: 24),

                  // ── Form fields ─────────────────────────────────────
                  _formLabel('Card Number'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _cardNumberCtrl,
                    hint: '0000 0000 0000 0000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [_CardNumberFormatter()],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  _formLabel('Cardholder Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _cardNameCtrl,
                    hint: 'Name on card',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel('Expiry Date'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _expiryCtrl,
                              hint: 'MM / YY',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_ExpiryFormatter()],
                              onChanged: (_) => setState(() {}),
                            ),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel('CVV'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _cvvCtrl,
                              hint: '•••',
                              obscure: _obscureCvv,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4)
                              ],
                              suffix: GestureDetector(
                                onTap: () =>
                                    setState(() => _obscureCvv = !_obscureCvv),
                                child: Icon(
                                    _obscureCvv
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white54,
                                    size: 18),
                              ),
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Amount breakdown ────────────────────────────────
                  _buildAmountBreakdown(),
                  const SizedBox(height: 20),

                  // ── Pay button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _pay,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0796DE),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF0796DE).withValues(alpha: 0.5)),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text('Pay RS.${_totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 14),
                    const SizedBox(width: 6),
                    Text('256-bit SSL encrypted & secure',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontFamily: 'Poppins')),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    final gradient = _isVisa
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF11A2EB), Color(0xFF0567A8)])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]);

    return Container(
      height: 185,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF0796DE).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10))
          ]),
      child: Stack(children: [
        // Decorative circles on card
        Positioned(
            right: -20,
            top: -20,
            child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08)))),
        Positioned(
            right: 30,
            bottom: -30,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06)))),
        Padding(
          padding: const EdgeInsets.all(22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Icon(Icons.wifi_rounded, color: Colors.white70, size: 24),
              // Card brand
              _isVisa
                  ? const Text('VISA',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic))
                  : Row(children: [
                      Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEB001B))),
                      Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF79E1B)
                                    .withValues(alpha: 0.85))),
                      ),
                    ]),
            ]),
            const Spacer(),
            Text(_displayCardNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CARD HOLDER',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontFamily: 'Poppins',
                        letterSpacing: 1)),
                Text(_displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('EXPIRES',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontFamily: 'Poppins',
                        letterSpacing: 1)),
                Text(_displayExpiry,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ]),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100)),
      child: Row(children: [
        _ToggleOption(
            label: 'VISA',
            selected: _isVisa,
            onTap: () => setState(() => _isVisa = true)),
        _ToggleOption(
            label: 'Mastercard',
            selected: !_isVisa,
            onTap: () => setState(() => _isVisa = false)),
      ]),
    );
  }

  Widget _buildAmountBreakdown() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Order Amount',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          Text('RS.${_baseAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text('MediFind Fee ',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontFamily: 'Poppins')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFF0796DE).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('3%',
                  style: TextStyle(
                      color: Color(0xFF11A2EB),
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          Text('RS.${_processingFee.toStringAsFixed(0)}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontFamily: 'Poppins')),
        ]),
        const Divider(color: Colors.white12, height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Amount',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
          Text('RS.${_totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Color(0xFF11A2EB),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  Widget _formLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(
          color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 14,
            fontFamily: 'Poppins'),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0796DE), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}

// ── Toggle option ──────────────────────────────────────────────────────────────
class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
              color: selected ? const Color(0xFF0796DE) : Colors.transparent,
              borderRadius: BorderRadius.circular(100)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ),
        ),
      ),
    );
  }
}

// ── Input formatters ───────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    final digits = val.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    final digits = val.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(limited[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}
