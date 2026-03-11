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

class _PaymentGatewayPageState extends State<PaymentGatewayPage>
    with TickerProviderStateMixin {
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _isVisa = true; // toggles between Visa / Mastercard
  bool _obscureCvv = true;
  bool _isProcessing = false;
  int _selectedCardType = 0; // 0 = Visa, 1 = Mastercard

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    _shimmerCtrl = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _slideCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  String get _formattedCardNumber {
    final raw = _cardNumberCtrl.text.replaceAll(' ', '');
    if (raw.isEmpty) return '**** **** **** ****';
    final padded = raw.padRight(16, '*');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} '
        '${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }

  void _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PaymentSuccessPage(
          amount: widget.amount,
          pharmacyName: widget.pharmacyName,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
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
                  const SizedBox(width: 48),
                ]),
              ),

              // ── Card Preview ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _buildCardPreview(),
              ),

              // ── Card Type Toggle ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildCardTypeToggle(),
              ),

              // ── Form ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _lbl('Card Number'),
                      _fld(
                        ctrl: _cardNumberCtrl,
                        hint: '0000 0000 0000 0000',
                        inputType: TextInputType.number,
                        maxLen: 19,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _lbl('Cardholder Name'),
                      _fld(
                        ctrl: _cardHolderCtrl,
                        hint: 'Name on card',
                        inputType: TextInputType.name,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('Expiry Date'),
                            _fld(
                              ctrl: _expiryCtrl,
                              hint: 'MM / YY',
                              inputType: TextInputType.number,
                              maxLen: 7,
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _ExpiryFormatter(),
                              ],
                            ),
                          ],
                        )),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('CVV'),
                            _fld(
                              ctrl: _cvvCtrl,
                              hint: '•••',
                              obscure: _obscureCvv,
                              inputType: TextInputType.number,
                              maxLen: 4,
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              suffix: GestureDetector(
                                onTap: () =>
                                    setState(() => _obscureCvv = !_obscureCvv),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(
                                      _obscureCvv
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white54,
                                      size: 18),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ]),
                      const SizedBox(height: 28),

                      // Amount row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontFamily: 'Poppins')),
                            Text(widget.amount,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Pay button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _pay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            disabledBackgroundColor:
                                const Color(0xFF0796DE).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            elevation: 6,
                            shadowColor:
                                const Color(0xFF0796DE).withOpacity(0.4),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Icon(Icons.lock_rounded,
                                          size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Pay ${widget.amount}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700)),
                                    ]),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.security_rounded,
                                size: 13, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 6),
                            Text('256-bit SSL encrypted & secure',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11,
                                    fontFamily: 'Poppins')),
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Credit card preview widget ──────────────────────────────────────────
  Widget _buildCardPreview() {
    final isVisa = _selectedCardType == 0;
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (ctx, _) => Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: const Alignment(-1, -1),
            end: const Alignment(1, 1),
            colors: isVisa
                ? [
                    const Color(0xFF0567A8),
                    const Color(0xFF0796DE),
                    const Color(0xFF11B4F5)
                  ]
                : [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460)
                  ],
          ),
          boxShadow: [
            BoxShadow(
                color:
                    (isVisa ? const Color(0xFF0796DE) : const Color(0xFF0F3460))
                        .withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(children: [
          // Shimmer overlay
          Positioned.fill(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(_shimmerAnim.value - 1, 0),
                  end: Alignment(_shimmerAnim.value, 0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.06),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          )),
          // Circle decoration
          Positioned(
              right: -30,
              top: -30,
              child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08), width: 30)))),
          Positioned(
              right: 40,
              bottom: -50,
              child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06), width: 25)))),
          // Card content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.wifi_rounded,
                          color: Colors.white54, size: 22),
                      _buildCardLogo(isVisa),
                    ]),
                const SizedBox(height: 20),
                Text(_formattedCardNumber,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2)),
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CARD HOLDER',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 9,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text(
                                _cardHolderCtrl.text.isEmpty
                                    ? 'FULL NAME'
                                    : _cardHolderCtrl.text.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500)),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('EXPIRES',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 9,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text(
                                _expiryCtrl.text.isEmpty
                                    ? 'MM/YY'
                                    : _expiryCtrl.text,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500)),
                          ]),
                    ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCardLogo(bool isVisa) {
    if (isVisa) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6)),
        child: const Text('VISA',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                fontStyle: FontStyle.italic)),
      );
    }
    // Mastercard circles
    return SizedBox(
      width: 46,
      height: 28,
      child: Stack(children: [
        Positioned(
            left: 0,
            child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEB001B).withOpacity(0.9)))),
        Positioned(
            right: 0,
            child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF79E1B).withOpacity(0.9)))),
      ]),
    );
  }

  Widget _buildCardTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(children: [
        _cardTypeBtn(0, 'VISA'),
        _cardTypeBtn(1, 'Mastercard'),
      ]),
    );
  }

  Widget _cardTypeBtn(int index, String label) {
    final active = _selectedCardType == index;
    return Expanded(
        child: GestureDetector(
      onTap: () => setState(() => _selectedCardType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0796DE) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
      ),
    ));
  }

  Widget _lbl(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500)));

  Widget _fld({
    required TextEditingController ctrl,
    required String hint,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
    int? maxLen,
    List<TextInputFormatter>? formatters,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: inputType,
        maxLength: maxLen,
        inputFormatters: formatters,
        onChanged: onChanged,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
              fontFamily: 'Poppins'),
          counterText: '',
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF0796DE), width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          suffixIcon: suffix,
        ),
      );
}

// ── Input formatters ─────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nv) {
    var text = nv.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return nv.copyWith(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nv) {
    var text = nv.text.replaceAll('/', '').replaceAll(' ', '');
    if (text.length > 4) text = text.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return nv.copyWith(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}
