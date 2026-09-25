
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

const Color bg = Color(0xFF07080C);
const Color card = Color(0xFF11141B);
const Color purple = Color(0xFFD18CFF);
const Color purpleDark = Color(0xFF3B244B);

class Product {
  String name, category, size;
  double purchase, selling;
  int stock, minStock;

  Product({
    required this.name,
    required this.category,
    required this.size,
    required this.purchase,
    required this.selling,
    required this.stock,
    required this.minStock,
  });
}

class Sale {
  String customer, product;
  int quantity;
  double amount;
  DateTime date;

  Sale({
    required this.customer,
    required this.product,
    required this.quantity,
    required this.amount,
    required this.date,
  });
}

final List<Product> products = [
  Product(name: 'WeatherCoat Long Life 10', category: 'Exterior', size: '20 L',
      purchase: 5200, selling: 5850, stock: 11, minStock: 5),
  Product(name: 'Easy Clean', category: 'Interior', size: '20 L',
      purchase: 4100, selling: 4650, stock: 7, minStock: 5),
  Product(name: 'Wall Primer', category: 'Primer', size: '20 L',
      purchase: 2500, selling: 2850, stock: 3, minStock: 5),
  Product(name: 'Wall Putty', category: 'Putty', size: '40 Kg',
      purchase: 1450, selling: 1650, stock: 18, minStock: 6),
];

final List<Sale> sales = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RAJA ENTERPRISE',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB56CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(onChanged: refresh),
      ProductsPage(onChanged: refresh),
      SalesPage(onChanged: refresh),
      StockPage(onChanged: refresh),
      MorePage(onChanged: refresh),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        backgroundColor: const Color(0xFF11131A),
        indicatorColor: const Color(0xFF5A347A),
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
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_outlined),
            selectedIcon: Icon(Icons.swap_vert),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final VoidCallback onChanged;
  const DashboardPage({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final stockValue = products.fold<double>(
      0, (s, p) => s + p.purchase * p.stock,
    );
    final salesToday = sales.fold<double>(0, (s, x) => s + x.amount);
    final low = products.where((p) => p.stock <= p.minStock).length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning 👋',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'RAJA ENTERPRISE • Business Management',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              MetricCard(icon: Icons.inventory_2_rounded,
                  value: '${products.length}', label: 'Products'),
              MetricCard(icon: Icons.account_balance_wallet_rounded,
                  value: '₹${stockValue.toStringAsFixed(0)}', label: 'Stock Value'),
              MetricCard(icon: Icons.warning_amber_rounded,
                  value: '$low', label: 'Low Stock'),
              MetricCard(icon: Icons.point_of_sale_rounded,
                  value: '₹${salesToday.toStringAsFixed(0)}', label: "Today's Sales"),
            ]),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 138,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF28153D), Color(0xFF12141B)],
                ),
                border: Border.all(color: purple.withValues(alpha: .25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Manage your business from one place.',
                      style: TextStyle(color: Colors.white60)),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ActionButton(
                        icon: Icons.add_shopping_cart,
                        label: 'New Sale',
                        onPressed: () => showSaleDialog(context, onChanged),
                      ),
                      ActionButton(
                        icon: Icons.add_box,
                        label: 'Stock In',
                        onPressed: () => showStockDialog(context, onChanged, true),
                      ),
                      ActionButton(
                        icon: Icons.remove_circle,
                        label: 'Stock Out',
                        onPressed: () => showStockDialog(context, onChanged, false),
                      ),
                      ActionButton(
                        icon: Icons.receipt_long,
                        label: 'Invoice',
                        onPressed: () => showInvoiceDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Low Stock Alert',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...products.where((p) => p.stock <= p.minStock).map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orangeAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(p.name)),
                          Text('${p.stock} left',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductsPage extends StatefulWidget {
  final VoidCallback onChanged;
  const ProductsPage({super.key, required this.onChanged});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String query = '';

  Future<void> addProduct() async {
    final p = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      builder: (_) => const ProductForm(),
    );
    if (p != null) {
      products.add(p);
      setState(() {});
      widget.onChanged();
    }
  }

  void deleteProduct(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(p.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              products.remove(p);
              Navigator.pop(context);
              setState(() {});
              widget.onChanged();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = products.where((p) =>
      p.name.toLowerCase().contains(query.toLowerCase())).toList();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
              sliver: SliverToBoxAdapter(
                child: PageHeader(
                  title: 'Products',
                  subtitle: 'Manage products, prices and stock',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(
                    product: list[i],
                    onDelete: () => deleteProduct(list[i]),
                  ),
                  childCount: list.length,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ),
      ],
    );
  }
}

class StockPage extends StatefulWidget {
  final VoidCallback onChanged;
  const StockPage({super.key, required this.onChanged});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  void change(Product p, int amount) {
    setState(() {
      p.stock = (p.stock + amount).clamp(0, 999999).toInt();
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 14),
          sliver: SliverToBoxAdapter(
            child: PageHeader(
              title: 'Stock Control',
              subtitle: 'Quickly add or remove inventory',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => StockCard(
                product: products[i],
                onMinus: () => change(products[i], -1),
                onPlus: () => change(products[i], 1),
              ),
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}

class SalesPage extends StatelessWidget {
  final VoidCallback onChanged;
  const SalesPage({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final total = sales.fold<double>(0, (s, x) => s + x.amount);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(
                  child: PageHeader(
                    title: 'Sales',
                    subtitle: 'Track sales and customer invoices',
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => showSaleDialog(context, onChanged),
                  icon: const Icon(Icons.add),
                  label: const Text('Sale'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF28153D),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_rupee, color: purple, size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Sales',
                          style: TextStyle(color: Colors.white.withValues(alpha: .65))),
                      Text('₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 30),
          sliver: sales.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No sales recorded yet')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final s = sales[sales.length - 1 - i];
                      return SaleCard(sale: s);
                    },
                    childCount: sales.length,
                  ),
                ),
        ),
      ],
    );
  }
}

class MorePage extends StatelessWidget {
  final VoidCallback onChanged;
  const MorePage({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const PageHeader(
          title: 'More',
          subtitle: 'Business tools and settings',
        ),
        const SizedBox(height: 20),
        MoreTile(
          icon: Icons.people_alt_outlined,
          title: 'Customers',
          subtitle: 'Manage customer information',
          onTap: () => showSimpleMessage(context, 'Customer module ready'),
        ),
        MoreTile(
          icon: Icons.receipt_long_outlined,
          title: 'Invoices',
          subtitle: 'Create and view invoices',
          onTap: () => showInvoiceDialog(context),
        ),
        MoreTile(
          icon: Icons.shopping_bag_outlined,
          title: 'Purchases',
          subtitle: 'Track supplier purchases',
          onTap: () => showSimpleMessage(context, 'Purchase module ready'),
        ),
        MoreTile(
          icon: Icons.bar_chart_outlined,
          title: 'Reports',
          subtitle: 'Sales and stock reports',
          onTap: () => showSimpleMessage(context, 'Reports module ready'),
        ),
        MoreTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Business settings',
          onTap: () => showSettingsDialog(context),
        ),
        MoreTile(
          icon: Icons.info_outline,
          title: 'About RAJA ENTERPRISE',
          subtitle: 'Stock Management App',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'RAJA ENTERPRISE',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Business Management',
          ),
        ),
      ],
    );
  }
}

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final name = TextEditingController();
  final category = TextEditingController();
  final size = TextEditingController();
  final purchase = TextEditingController();
  final selling = TextEditingController();
  final stock = TextEditingController();
  final minimum = TextEditingController(text: '5');

  @override
  void dispose() {
    name.dispose();
    category.dispose();
    size.dispose();
    purchase.dispose();
    selling.dispose();
    stock.dispose();
    minimum.dispose();
    super.dispose();
  }

  void save() {
    Navigator.pop(
      context,
      Product(
        name: name.text.trim().isEmpty ? 'New Product' : name.text.trim(),
        category: category.text.trim().isEmpty ? 'General' : category.text.trim(),
        size: size.text.trim().isEmpty ? '-' : size.text.trim(),
        purchase: double.tryParse(purchase.text) ?? 0,
        selling: double.tryParse(selling.text) ?? 0,
        stock: int.tryParse(stock.text) ?? 0,
        minStock: int.tryParse(minimum.text) ?? 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 18),
            const Text('Add New Product',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            AppField(controller: name, label: 'Product name'),
            AppField(controller: category, label: 'Category'),
            AppField(controller: size, label: 'Size'),
            Row(children: [
              Expanded(child: AppField(controller: purchase, label: 'Purchase price', number: true)),
              const SizedBox(width: 10),
              Expanded(child: AppField(controller: selling, label: 'Selling price', number: true)),
            ]),
            Row(children: [
              Expanded(child: AppField(controller: stock, label: 'Opening stock', number: true)),
              const SizedBox(width: 10),
              Expanded(child: AppField(controller: minimum, label: 'Minimum stock', number: true)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showStockDialog(
  BuildContext context,
  VoidCallback refresh,
  bool stockIn,
) {
  Product? selected = products.isNotEmpty ? products.first : null;
  final qty = TextEditingController(text: '1');

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(stockIn ? 'Stock In' : 'Stock Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Product>(
              value: selected,
              isExpanded: true,
              items: products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                );
              }).toList(),
              onChanged: (p) => setDialogState(() => selected = p),
              decoration: const InputDecoration(labelText: 'Product'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(qty.text) ?? 0;
              if (selected != null && amount > 0) {
                if (stockIn) {
                  selected!.stock += amount;
                } else {
                  selected!.stock =
                      (selected!.stock - amount).clamp(0, 999999).toInt();
                }
                refresh();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  ).whenComplete(qty.dispose);
}

void showSaleDialog(BuildContext context, VoidCallback refresh) {
  Product? selected = products.isNotEmpty ? products.first : null;
  final customer = TextEditingController();
  final qty = TextEditingController(text: '1');

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        final quantity = int.tryParse(qty.text) ?? 1;
        final amount = (selected?.selling ?? 0) * quantity;

        return AlertDialog(
          title: const Text('New Sale'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customer,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Product>(
                  value: selected,
                  isExpanded: true,
                  items: products.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (p) => setDialogState(() => selected = p),
                  decoration: const InputDecoration(labelText: 'Product'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total: ₹${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final q = int.tryParse(qty.text) ?? 0;
                if (selected == null || q <= 0) return;

                if (q > selected!.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not enough stock')),
                  );
                  return;
                }

                selected!.stock -= q;

                sales.add(
                  Sale(
                    customer: customer.text.trim().isEmpty
                        ? 'Walk-in Customer'
                        : customer.text.trim(),
                    product: selected!.name,
                    quantity: q,
                    amount: selected!.selling * q,
                    date: DateTime.now(),
                  ),
                );

                refresh();
                Navigator.pop(context);
              },
              child: const Text('Complete Sale'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(() {
    customer.dispose();
    qty.dispose();
  });
}

void showInvoiceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Invoice'),
      content: const Text(
        'Invoice generator is ready. Select a sale from Sales to create the final invoice.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Business Settings'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.store),
            title: Text('RAJA ENTERPRISE'),
            subtitle: Text('Stock Management'),
          ),
          ListTile(
            leading: Icon(Icons.currency_rupee),
            title: Text('Currency'),
            subtitle: Text('Indian Rupee (₹)'),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void showSimpleMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            )),
        const SizedBox(height: 7),
        Text(subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
            )),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: purpleDark,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: purple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      )),
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final low = product.stock <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.format_paint_rounded, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 5),
                Text('${product.category} • ${product.size}',
                    style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 4),
                Text('Sell ₹${product.selling.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${product.stock} pcs',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(low ? 'Low Stock' : 'In Stock',
                  style: TextStyle(
                    color: low ? Colors.orangeAccent : Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 21),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StockCard extends StatelessWidget {
  final Product product;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const StockCard({
    super.key,
    required this.product,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final low = product.stock <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.format_paint_rounded, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 4),
                Text('${product.category} • ${product.size}',
                    style: const TextStyle(color: Colors.white60)),
                if (low)
                  const Text('LOW STOCK',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      )),
              ],
            ),
          ),
          IconButton(
            onPressed: product.stock > 0 ? onMinus : null,
            icon: const Icon(Icons.remove_circle_outline, size: 29),
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text('${product.stock}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  )),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline, size: 29),
          ),
        ],
      ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final Sale sale;

  const SaleCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: purpleDark,
            child: Icon(Icons.receipt_long, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.customer,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${sale.product} × ${sale.quantity}',
                    style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          Text('₹${sale.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
              )),
        ],
      ),
    );
  }
}

class MoreTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MoreTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: card,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: purpleDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: purple),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF0D0F15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
