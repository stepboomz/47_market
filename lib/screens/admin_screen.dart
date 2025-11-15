import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BrandCategory> _categories = [];
  List<ShirtModel> _products = [];
  List<Map<String, dynamic>> _orders = [];
  bool _loadingCategories = true;
  bool _loadingProducts = true;
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchCategories(),
      _fetchProducts(),
      _fetchOrders(),
    ]);
  }

  Future<void> _fetchCategories() async {
    setState(() => _loadingCategories = true);
    final cats = await SupabaseService.getCategories();
    setState(() {
      _categories = cats;
      _loadingCategories = false;
    });
  }

  Future<void> _fetchProducts() async {
    setState(() => _loadingProducts = true);
    final items = await SupabaseService.getProducts();
    setState(() {
      _products = items;
      _loadingProducts = false;
    });
  }

  Future<void> _fetchOrders() async {
    setState(() => _loadingOrders = true);
    final items = await SupabaseService.getOrders();
    setState(() {
      _orders = items;
      _loadingOrders = false;
    });
  }

  Future<void> _saveCategoryOrder() async {
    final payload = <Map<String, dynamic>>[];
    for (int i = 0; i < _categories.length; i++) {
      payload.add({'id': _categories[i].type.name, 'order_index': i});
    }
    await SupabaseService.updateCategoryOrder(payload);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกลำดับหมวดหมู่แล้ว')));
  }

  Future<void> _createOrEditProduct({ShirtModel? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '0');
    String? imageUrl = product?.image;
    String categoryId = product?.category ?? 'readyMeals';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(product == null ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  items: _categories.map((c) => DropdownMenuItem(value: c.type.name, child: Text(c.displayName))).toList(),
                  onChanged: (v) => categoryId = v ?? 'readyMeals',
                  decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text(imageUrl ?? 'ยังไม่มีรูป')),
                    TextButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        if (picked != null) {
                          final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
                          final url = await SupabaseService.uploadImage(picked.path, fileName);
                          setState(() => imageUrl = url);
                        }
                      },
                      child: const Text('อัปโหลดรูป'),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0,
                  'image': imageUrl,
                  'category_id': categoryId,
                };
                if (product == null) {
                  await SupabaseService.createProduct(data);
                } else {
                  await SupabaseService.updateProduct(product.id, data);
                }
                if (mounted) Navigator.pop(ctx);
                await _fetchProducts();
              },
              child: const Text('บันทึก'),
            )
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteProduct(ShirtModel product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: Text('ต้องการลบ "${product.name}" หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok == true) {
      await SupabaseService.deleteProduct(product.id);
      await _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const _AdminAuthGate();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchAll,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories reorder tab
          _loadingCategories
              ? Center(
                  child: SpinKitDancingSquare(
                    color: Colors.red,
                    size: 50.0,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        itemBuilder: (ctx, i) {
                          final c = _categories[i];
                          return ListTile(
                            key: ValueKey(c.type.name),
                            title: Text(c.displayName),
                            subtitle: Text(c.type.name),
                            leading: const Icon(Icons.drag_handle),
                          );
                        },
                        itemCount: _categories.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _categories.removeAt(oldIndex);
                            _categories.insert(newIndex, item);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: _saveCategoryOrder,
                        icon: const Icon(Icons.save),
                        label: const Text('บันทึกการจัดลำดับ'),
                      ),
                    )
                  ],
                ),

          // Products CRUD tab
          _loadingProducts
              ? Center(
                  child: SpinKitDancingSquare(
                    color: Colors.red,
                    size: 50.0,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _createOrEditProduct(),
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มสินค้า'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (ctx, i) {
                          final p = _products[i];
                          return ListTile(
                            leading: p.image.isNotEmpty ? Image.network(p.image, width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.image_not_supported),
                            title: Text(p.name),
                            subtitle: Text('${p.category}  •  ${p.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _createOrEditProduct(product: p),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDeleteProduct(p),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: _products.length,
                      ),
                    ),
                  ],
                ),
          // Orders tab
          _loadingOrders
              ? Center(
                  child: SpinKitDancingSquare(
                    color: Colors.red,
                    size: 50.0,
                  ),
                )
              : ListView.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final o = _orders[i];
                    final List items = o['order_items'] ?? [];
                    return ListTile(
                      title: Text('Order ${o['order_number']}  •  ฿${(o['total_amount'] as num).toStringAsFixed(2)}'),
                      subtitle: Text('${o['customer_name'] ?? ''}  •  ${o['status']}  •  ${items.length} items'),
                      onTap: () async {
                        String status = o['status'] ?? 'pending';
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Order ${o['order_number']}'),
                            content: SizedBox(
                              width: 420,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ลูกค้า: ${o['customer_name']}'),
                                  Text('โทร: ${o['customer_phone']}'),
                                  Text('ที่อยู่: ${o['customer_address']}'),
                                  const SizedBox(height: 8),
                                  const Text('รายการสินค้า:'),
                                  const SizedBox(height: 4),
                                  ...items.map<Widget>((it) => Text('- ${it['name']} x${it['quantity']}  ฿${(it['price'] as num).toStringAsFixed(2)}')).toList(),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: status,
                                    items: const [
                                      DropdownMenuItem(value: 'pending', child: Text('pending')),
                                      DropdownMenuItem(value: 'processing', child: Text('processing')),
                                      DropdownMenuItem(value: 'completed', child: Text('completed')),
                                    ],
                                    onChanged: (v) => status = v ?? 'pending',
                                    decoration: const InputDecoration(labelText: 'สถานะ'),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ปิด')),
                              ElevatedButton(
                                onPressed: () async {
                                  await SupabaseService.updateOrderStatus(o['id'], status);
                                  if (mounted) Navigator.pop(ctx);
                                  await _fetchOrders();
                                },
                                child: const Text('บันทึก'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _AdminAuthGate extends StatefulWidget {
  const _AdminAuthGate();

  @override
  State<_AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<_AdminAuthGate> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/admin');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: SpinKitDancingSquare(
                              color: Colors.white,
                              size: 20.0,
                            ),
                          )
                        : const Text('Sign in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


