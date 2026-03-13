class OrderItem {
  final String pharmacyName;
  final String amount;
  final String orderId;
  final String deliveredAt;
  final String status;

  const OrderItem({
    required this.pharmacyName,
    required this.amount,
    required this.orderId,
    required this.deliveredAt,
    required this.status,
  });
}

class OrderStore {
  static final OrderStore instance = OrderStore._();
  OrderStore._();

  final List<OrderItem> orders = [];

  void addOrder(OrderItem order) {
    orders.insert(0, order); // newest first
  }
}
