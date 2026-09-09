import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/order_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import 'order_confirmation_screen.dart';
import 'order_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;

  String? _selectedCity;
  DeliveryType _deliveryType = DeliveryType.pickup;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController();
    _selectedCity = user?.city;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лутфан шаҳрро интихоб кунед.')),
      );
      return;
    }
    if (_deliveryType == DeliveryType.delivery && _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Барои доставка суроға лозим аст.')),
      );
      return;
    }

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final cartItems = ref.read(cartControllerProvider);
    if (cartItems.isEmpty) return;

    final subtotal = ref.read(cartSubtotalProvider);
    final deliveryFee = _deliveryType == DeliveryType.delivery ? kFlatDeliveryFee : 0.0;

    final order = OrderModel(
      id: '',
      customerId: uid,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerCity: _selectedCity!,
      customerAddress:
          _deliveryType == DeliveryType.delivery ? _addressCtrl.text.trim() : null,
      items: cartItems
          .map((c) => OrderItem(
                productId: c.productId,
                productName: c.productName,
                productImage: c.productImage,
                price: c.price,
                quantity: c.quantity,
                sellerId: c.sellerId,
                businessId: c.businessId,
              ))
          .toList(),
      deliveryType: _deliveryType,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      sellerIds: cartItems.map((c) => c.sellerId).toSet().toList(),
    );

    final orderId = await ref.read(checkoutControllerProvider.notifier).submit(order);

    if (!mounted) return;

    if (orderId != null) {
      await ref.read(cartControllerProvider.notifier).clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order.copyWithId(orderId)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.somethingWentWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final deliveryFee = _deliveryType == DeliveryType.delivery ? kFlatDeliveryFee : 0.0;
    final total = subtotal + deliveryFee;
    final state = ref.watch(checkoutControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Ном *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Телефон *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'Шаҳр *'),
              items: TjCities.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 16),
            SegmentedButton<DeliveryType>(
              segments: const [
                ButtonSegment(
                  value: DeliveryType.pickup,
                  label: Text('Гирифтан аз ҷой'),
                  icon: Icon(Icons.store_outlined),
                ),
                ButtonSegment(
                  value: DeliveryType.delivery,
                  label: Text('Доставка'),
                  icon: Icon(Icons.local_shipping_outlined),
                ),
              ],
              selected: {_deliveryType},
              onSelectionChanged: (s) => setState(() => _deliveryType = s.first),
            ),
            if (_deliveryType == DeliveryType.delivery) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Суроғаи дақиқ *'),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Ҷамъ', value: subtotal),
            _SummaryRow(label: 'Доставка', value: deliveryFee),
            const Divider(),
            _SummaryRow(label: 'Ҳамагӣ', value: total, isBold: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : _submit,
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Фармоиш додан'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
      color: isBold ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.toStringAsFixed(0)} с.', style: style),
        ],
      ),
    );
  }
}
