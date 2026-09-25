import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const RajaEnterpriseApp());
}

// ============================================================
// APP
// ============================================================

class RajaEnterpriseApp extends StatelessWidget {
  const RajaEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAJA ENTERPRISE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C4DFF),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

// ============================================================
// MAIN PAGE
// ============================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    ProductsPage(),
    SalesPage(),
    StockPage(),
    MorePage(),
  ];

  final titles = const [
    'Dashboard',
    'Products',
    'Sales',
    'Stock',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            selectedIcon: Icon(Icons.warehouse),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FIRESTORE SERVICE
// ============================================================

class FirestoreService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get products =>
      db.collection('products');

  static CollectionReference<Map<String, dynamic>> get sales =>
      db.collection('sales');

  static Stream<QuerySnapshot<Map<String, dynamic>>> productsStream() {
    return products.orderBy('createdAt', descending: true).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> salesStream() {
    return sales.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> addProduct({
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int lowStock,
  }) async {
    await products.add({
      'name': name,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'lowStock': lowStock,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    await products.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  static Future<void> changeStock(
    String id,
    int currentStock,
    int amount,
  ) async {
    final newStock = currentStock + amount;

    if (newStock < 0) {
      throw Exception('Stock cannot be negative');
    }

    await products.doc(id).update({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> createSale({
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    required double total,
  }) async {
    await db.runTransaction((transaction) async {
      final productRef = products.doc(productId);
      final productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      final data = productSnapshot.data()!;
      final currentStock = (data['stock'] ?? 0) as num;

      if (currentStock < quantity) {
        throw Exception('Not enough stock');
      }

      transaction.update(productRef, {
        'stock': currentStock.toInt() - quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final saleRef = sales.doc();

      transaction.set(saleRef, {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.productsStream(),
      builder: (context, productSnapshot) {
        if (productSnapshot.hasError) {
          return _ErrorBox(message: productSnapshot.error.toString());
        }

        if (!productSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productSnapshot.data!.docs;

        int totalProducts = products.length;
        int totalStock = 0;
        double stockValue = 0;
        int lowStock = 0;

        for (final doc in products) {
          final data = doc.data();

          final stock = (data['stock'] ?? 0) as num;
          final purchasePrice =
              (data['purchasePrice'] ?? 0).toDouble();
          final low = (data['lowStock'] ?? 5) as num;

          totalStock += stock.toInt();
          stockValue += stock * purchasePrice;

          if (stock <= low) {
            lowStock++;
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            children: [
              _WelcomeCard(
                totalProducts: totalProducts,
                totalStock: totalStock,
              ),

              const SizedBox(height: 18),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    title: 'Products',
                    value: '$totalProducts',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF6C4DFF),
                  ),
                  _StatCard(
                    title: 'Total Stock',
                    value: '$totalStock',
                    icon: Icons.warehouse,
                    color: const Color(0xFF009688),
                  ),
                  _StatCard(
                    title: 'Stock Value',
                    value: '₹${stockValue.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                    color: const Color(0xFFE67E22),
                  ),
                  _StatCard(
                    title: 'Low Stock',
                    value: '$lowStock',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFE53935),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickButton(
                      icon: Icons.add_box,
                      title: 'Add Product',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickButton(
                      icon: Icons.point_of_sale,
                      title: 'New Sale',
                      onTap: () {
                        _showSaleSelector(context);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Low Stock Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              ...products.where((doc) {
                final data = doc.data();
                final stock = (data['stock'] ?? 0) as num;
                final low = (data['lowStock'] ?? 5) as num;
                return stock <= low;
              }).take(5).map(
                (doc) => _ProductTile(
                  doc: doc,
                  warning: true,
                ),
              ),

              if (lowStock == 0)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('All products have sufficient stock.'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSaleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirestoreService.productsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final products = snapshot.data!.docs;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Select Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...products.map(
                  (doc) {
                    final data = doc.data();
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.inventory_2),
                      ),
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(
                        'Stock: ${data['stock'] ?? 0} • ₹${data['sellingPrice'] ?? 0}',
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (_) => SaleDialog(
                            productId: doc.id,
                            productName: data['name'] ?? '',
                            stock: (data['stock'] ?? 0) as num,
                            price:
                                (data['sellingPrice'] ?? 0).toDouble(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================
// PRODUCTS
// ============================================================

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.productsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorBox(message: snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snapshot.data!.docs;

        final filtered = all.where((doc) {
          final name =
              (doc.data()['name'] ?? '').toString().toLowerCase();
          return name.contains(search.toLowerCase());
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                onChanged: (value) {
                  setState(() => search = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() => search = '');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No products found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        100,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        return _ProductTile(
                          doc: filtered[i],
                          onTap: () {
                            _showProductOptions(
                              context,
                              filtered[i],
                            );
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

  void _showProductOptions(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Stock: ${data['stock'] ?? 0}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Stock In'),
                onTap: () {
                  Navigator.pop(context);
                  _stockDialog(
                    context,
                    doc.id,
                    (data['stock'] ?? 0) as num,
                    true,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle),
                title: const Text('Stock Out'),
                onTap: () {
                  Navigator.pop(context);
                  _stockDialog(
                    context,
                    doc.id,
                    (data['stock'] ?? 0) as num,
                    false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductPage(
                        existingId: doc.id,
                        existingData: data,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Delete Product'),
                onTap: () async {
                  Navigator.pop(context);

                  await FirestoreService.deleteProduct(doc.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product deleted'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _stockDialog(
    BuildContext context,
    String id,
    num current,
    bool isIn,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isIn ? 'Stock In' : 'Stock Out'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(controller.text);

                if (amount == null || amount <= 0) return;

                try {
                  await FirestoreService.changeStock(
                    id,
                    current.toInt(),
                    isIn ? amount : -amount,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// ADD / EDIT PRODUCT
// ============================================================

class AddProductPage extends StatefulWidget {
  final String? existingId;
  final Map<String, dynamic>? existingData;

  const AddProductPage({
    super.key,
    this.existingId,
    this.existingData,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final purchaseController = TextEditingController();
  final sellingController = TextEditingController();
  final stockController = TextEditingController();
  final lowStockController = TextEditingController();

  bool loading = false;

  bool get editing => widget.existingId != null;

  @override
  void initState() {
    super.initState();

    final data = widget.existingData;

    if (data != null) {
      nameController.text = data['name'] ?? '';
      categoryController.text = data['category'] ?? '';
      purchaseController.text =
          '${data['purchasePrice'] ?? 0}';
      sellingController.text =
          '${data['sellingPrice'] ?? 0}';
      stockController.text = '${data['stock'] ?? 0}';
      lowStockController.text =
          '${data['lowStock'] ?? 5}';
    } else {
      lowStockController.text = '5';
      stockController.text = '0';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    purchaseController.dispose();
    sellingController.dispose();
    stockController.dispose();
    lowStockController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      _error('Product name is required');
      return;
    }

    final purchase =
        double.tryParse(purchaseController.text) ?? 0;

    final selling =
        double.tryParse(sellingController.text) ?? 0;

    final stock =
        int.tryParse(stockController.text) ?? 0;

    final lowStock =
        int.tryParse(lowStockController.text) ?? 5;

    setState(() => loading = true);

    try {
      if (editing) {
        await FirestoreService.updateProduct(
          widget.existingId!,
          {
            'name': name,
            'category': categoryController.text.trim(),
            'purchasePrice': purchase,
            'sellingPrice': selling,
            'stock': stock,
            'lowStock': lowStock,
          },
        );
      } else {
        await FirestoreService.addProduct(
          name: name,
          category: categoryController.text.trim(),
          purchasePrice: purchase,
          sellingPrice: selling,
          stock: stock,
          lowStock: lowStock,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'Edit Product' : 'Add Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _field(
              nameController,
              'Product Name',
              Icons.inventory_2,
            ),
            _field(
              categoryController,
              'Category',
              Icons.category,
            ),
            _field(
              purchaseController,
              'Purchase Price',
              Icons.shopping_cart,
              number: true,
            ),
            _field(
              sellingController,
              'Selling Price',
              Icons.sell,
              number: true,
            ),
            _field(
              stockController,
              'Current Stock',
              Icons.warehouse,
              number: true,
            ),
            _field(
              lowStockController,
              'Low Stock Alert',
              Icons.warning_amber,
              number: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: loading ? null : save,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  editing ? 'UPDATE PRODUCT' : 'SAVE PRODUCT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType:
            number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

// ============================================================
// SALES
// ============================================================

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.salesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorBox(message: snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final sales = snapshot.data!.docs;

        if (sales.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 60,
                ),
                SizedBox(height: 12),
                Text('No sales yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          itemBuilder: (_, i) {
            final data = sales[i].data();

            final total =
                (data['total'] ?? 0).toDouble();

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt),
                ),
                title: Text(
                  data['productName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Qty: ${data['quantity'] ?? 0}',
                ),
                trailing: Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// STOCK
// ============================================================

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.productsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final products = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...products.map(
              (doc) {
                final data = doc.data();

                final stock =
                    (data['stock'] ?? 0) as num;

                final low =
                    (data['lowStock'] ?? 5) as num;

                final isLow = stock <= low;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow
                          ? Colors.red.withOpacity(.1)
                          : Colors.green.withOpacity(.1),
                      child: Icon(
                        isLow
                            ? Icons.warning
                            : Icons.check_circle,
                        color: isLow
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    title: Text(
                      data['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      isLow ? 'LOW STOCK' : 'Stock available',
                    ),
                    trailing: Text(
                      '${stock.toInt()}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// MORE
// ============================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6C4DFF),
                Color(0xFF4325C7),
              ],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.business,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(height: 15),
              Text(
                'RAJA ENTERPRISE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Stock Management System',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ListTile(
          leading: const Icon(Icons.add_box),
          title: const Text('Add Product'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddProductPage(),
              ),
            );
          },
        ),

        const Divider(),

        const ListTile(
          leading: Icon(Icons.cloud),
          title: Text('Firebase Database'),
          subtitle: Text('Cloud Firestore enabled'),
        ),

        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('RAJA ENTERPRISE V1.1'),
        ),
      ],
    );
  }
}

// ============================================================
// SALE DIALOG
// ============================================================

class SaleDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final num stock;
  final double price;

  const SaleDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.stock,
    required this.price,
  });

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  final quantityController = TextEditingController(text: '1');
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final quantity =
        int.tryParse(quantityController.text) ?? 0;

    final total = quantity * widget.price;

    return AlertDialog(
      title: const Text('New Sale'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.productName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text('Available stock: ${widget.stock}'),

          const SizedBox(height: 16),

          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Quantity',
              prefixIcon: Icon(Icons.numbers),
            ),
          ),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ||
                  quantity <= 0 ||
                  quantity > widget.stock
              ? null
              : () async {
                  setState(() => saving = true);

                  try {
                    await FirestoreService.createSale(
                      productId: widget.productId,
                      productName: widget.productName,
                      quantity: quantity,
                      price: widget.price,
                      total: total,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sale completed successfully',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => saving = false);
                    }
                  }
                },
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Complete Sale'),
        ),
      ],
    );
  }
}

// ============================================================
// UI COMPONENTS
// ============================================================

class _WelcomeCard extends StatelessWidget {
  final int totalProducts;
  final int totalStock;

  const _WelcomeCard({
    required this.totalProducts,
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C4DFF),
            Color(0xFF4223C7),
          ],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAJA ENTERPRISE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Manage your business easily',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final VoidCallback? onTap;
  final bool warning;

  const _ProductTile({
    required this.doc,
    this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();

    final stock = (data['stock'] ?? 0) as num;
    final price =
        (data['sellingPrice'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: warning
              ? Colors.red.withOpacity(.1)
              : const Color(0xFF6C4DFF).withOpacity(.1),
          child: Icon(
            warning
                ? Icons.warning_amber
                : Icons.inventory_2,
            color: warning
                ? Colors.red
                : const Color(0xFF6C4DFF),
          ),
        ),
        title: Text(
          data['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${data['category'] ?? 'General'} • Stock: ${stock.toInt()}',
        ),
        trailing: Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
