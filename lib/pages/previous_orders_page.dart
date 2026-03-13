import 'package:flutter/material.dart';
import 'order_store.dart';

class PreviousOrdersPage extends StatefulWidget {
  const PreviousOrdersPage({super.key});

  @override
  State<PreviousOrdersPage> createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderStore.instance.orders;

    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0796DE),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                      right: -30,
                      top: -40,
                      child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 22,
                                  color: Colors.white.withOpacity(0.12))))),
                  Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.white, size: 24)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                        '${orders.length} order${orders.length != 1 ? 's' : ''}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ]),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Past Orders',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700)),
                                    Text('Your delivery history',
                                        style: TextStyle(
                                            color: Color(0xFFD0EEFF),
                                            fontSize: 13,
                                            fontFamily: 'Poppins')),
                                  ]),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28))),
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _OrderCard(order: orders[index], index: index);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0796DE).withOpacity(0.08)),
            child: Icon(Icons.receipt_long_rounded,
                color: const Color(0xFF0796DE).withOpacity(0.4), size: 48),
          ),
          const SizedBox(height: 20),
          const Text('No orders yet',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Your completed orders will appear here',
              style: TextStyle(
                  color: const Color(0xFF64748B).withOpacity(0.8),
                  fontSize: 13,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderItem order;
  final int index;
  const _OrderCard({required this.order, required this.index});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(_animController);

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0796DE).withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            children: [
              // Top row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(children: [
                  // Pharmacy icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: const Color(0xFF0796DE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.local_pharmacy_rounded,
                        color: Color(0xFF0796DE), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.pharmacyName,
                              style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(order.deliveredAt,
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontFamily: 'Poppins')),
                        ]),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text('Delivered',
                          style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ),

              // Divider
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Bottom row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.tag_rounded,
                            color: Color(0xFF94A3B8), size: 14),
                        const SizedBox(width: 4),
                        Text(order.orderId,
                            style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontFamily: 'Poppins')),
                      ]),
                      Text(order.amount,
                          style: const TextStyle(
                              color: Color(0xFF0796DE),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
