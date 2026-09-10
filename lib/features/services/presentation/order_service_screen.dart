import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/service_categories.dart';
import '../../../models/service_order_model.dart';
import '../../../models/service_provider_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'services_providers.dart';

class OrderServiceScreen extends ConsumerStatefulWidget {
  final ServiceProviderModel provider;
  const OrderServiceScreen({super.key, required this.provider});

  @override
  ConsumerState<OrderServiceScreen> createState() => _OrderServiceScreenState();
}

class _OrderServiceScreenState extends ConsumerState<OrderServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final order = ServiceOrderModel(
      id: '',
      customerId: me.uid,
      customerName: me.name,
      customerPhone: _phoneCtrl.text.trim(),
      providerId: widget.provider.uid,
      providerName: widget.provider.name,
      serviceCategory: widget.provider.serviceCategory,
      notes: _notesCtrl.text.trim(),
      city: widget.provider.city,
    );

    final ok = await ref.read(servicesActionControllerProvider.notifier).createOrder(order);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Дархости шумо фиристода шуд!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Фармоиш додан')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${widget.provider.name} — '
              '${ServiceCategories.labelOf(widget.provider.serviceCategory)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Телефони шумо *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Тавсифи кор',
                hintText: 'Чӣ лозим аст? Кай мувофиқ аст?',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSaving ? null : _submit,
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Фиристодани дархост'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
