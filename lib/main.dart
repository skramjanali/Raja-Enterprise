
import 'package:flutter/material.dart';

void main() => runApp(const RajaEnterpriseApp());

class Product {
  String name, category, size;
  double purchase, selling;
  int stock, minStock;
  Product({
    required this.name, required this.category, required this.size,
    required this.purchase, required this.selling,
    required this.stock, required this.minStock,
  });
}

final products = <Product>[
  Product(name: 'WeatherCoat Long Life 10', category: 'Exterior', size: '20 L', purchase: 5200, selling: 5850, stock: 12, minStock: 5),
  Product(name: 'Easy Clean', category: 'Interior', size: '20 L', purchase: 4100, selling: 4650, stock: 7, minStock: 5),
  Product(name: 'Wall Primer', category: 'Primer', size: '20 L', purchase: 2500, selling: 2850, stock: 3, minStock: 5),
  Product(name: 'Wall Putty', category: 'Putty', size: '40 Kg', purchase: 1450, selling: 1650, stock: 18, minStock: 6),
];

class RajaEnterpriseApp extends StatelessWidget {
  const RajaEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RAJA ENTERPRISE',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB98BFF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selected = 0;
  final pages = const [
    DashboardView(),
    ProductsView(),
    StockView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF101117),
            selectedIndex: selected,
            onDestinationSelected: (i) => setState(() => selected = i),
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Color(0xFFC99BFF)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFFC99BFF), fontWeight: FontWeight.bold),
            leading: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 20),
              child: Column(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFFC99BFF), Color(0xFF6D5DFB)]),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text('RAJA', style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2_rounded), label: Text('Products')),
              NavigationRailDestination(icon: Icon(Icons.swap_vert_rounded), label: Text('Stock')),
            ],
          ),
          Expanded(child: pages[selected]),
        ],
      ),
      floatingActionButton: selected == 1
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(context: context, builder: (_) => const AddProductDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.stock <= p.minStock).length;
    final stockValue = products.fold<double>(0, (s, p) => s + p.purchase * p.stock);

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Header(title: 'Good morning 👋', subtitle: 'RAJA ENTERPRISE • Stock Management'),
        const SizedBox(height: 26),
        Wrap(
          spacing: 16, runSpacing: 16,
          children: [
            MetricCard(title: 'Total Products', value: '${products.length}', icon: Icons.inventory_2_rounded),
            MetricCard(title: 'Stock Value', value: '₹${stockValue.toStringAsFixed(0)}', icon: Icons.account_balance_wallet_rounded),
            MetricCard(title: 'Low Stock', value: '$low', icon: Icons.warning_amber_rounded),
            const MetricCard(title: "Today's Sales", value: '₹0', icon: Icons.shopping_cart_rounded),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF211A36), Color(0xFF11131D)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF8D72FF).withOpacity(.25)),
          ),
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Inventory Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Monitor stock levels and keep your paint inventory healthy.',
                    style: TextStyle(color: Colors.white.withOpacity(.65))),
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.analytics_rounded), label: const Text('View Reports')),
              ])),
              const Icon(Icons.auto_graph_rounded, size: 90, color: Color(0xFFC99BFF)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Low Stock Alert'),
        const SizedBox(height: 12),
        ...products.where((p) => p.stock <= p.minStock).map((p) => ProductTile(product: p, warning: true)),
      ],
    );
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});
  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final list = products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Header(title: 'Products & Stock', subtitle: 'Manage your Berger Paints inventory'),
        const SizedBox(height: 20),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF13151C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        ...list.map((p) => ProductTile(product: p)),
      ],
    );
  }
}

class StockView extends StatefulWidget {
  const StockView({super.key});
  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  void adjust(Product p, int amount) {
    setState(() => p.stock = (p.stock + amount).clamp(0, 999999));
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Header(title: 'Stock Control', subtitle: 'Quickly add or remove inventory'),
        const SizedBox(height: 20),
        ...products.map((p) => Card(
          color: const Color(0xFF12141B),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF252033),
                child: const Icon(Icons.format_paint_rounded, color: Color(0xFFC99BFF)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('${p.category} • ${p.size}', style: TextStyle(color: Colors.white.withOpacity(.55))),
              ])),
              IconButton(onPressed: () => adjust(p, -1), icon: const Icon(Icons.remove_circle_outline)),
              Text('${p.stock}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => adjust(p, 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ),
        )),
      ],
    );
  }
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}
class _AddProductDialogState extends State<AddProductDialog> {
  final name = TextEditingController();
  final category = TextEditingController();
  final size = TextEditingController();
  final purchase = TextEditingController();
  final selling = TextEditingController();
  final stock = TextEditingController();
  final minStock = TextEditingController(text: '5');

  @override
  void dispose() {
    for (final c in [name, category, size, purchase, selling, stock, minStock]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Product'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(children: [
            Field(controller: name, label: 'Product name'),
            Field(controller: category, label: 'Category'),
            Field(controller: size, label: 'Size'),
            Field(controller: purchase, label: 'Purchase price', number: true),
            Field(controller: selling, label: 'Selling price', number: true),
            Field(controller: stock, label: 'Opening stock', number: true),
            Field(controller: minStock, label: 'Minimum stock', number: true),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            products.add(Product(
              name: name.text.trim().isEmpty ? 'New Product' : name.text.trim(),
              category: category.text.trim().isEmpty ? 'General' : category.text.trim(),
              size: size.text.trim().isEmpty ? '-' : size.text.trim(),
              purchase: double.tryParse(purchase.text) ?? 0,
              selling: double.tryParse(selling.text) ?? 0,
              stock: int.tryParse(stock.text) ?? 0,
              minStock: int.tryParse(minStock.text) ?? 5,
            ));
            Navigator.pop(context);
            (context as Element).markNeedsBuild();
          },
          child: const Text('Save Product'),
        ),
      ],
    );
  }
}

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;
  const Field({super.key, required this.controller, required this.label, this.number = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFF15171E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    ),
  );
}

class Header extends StatelessWidget {
  final String title, subtitle;
  const Header({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5),
    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.55))),
  ]);
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800));
}

class MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const MetricCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 220, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF12141B), borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(.06))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFFC99BFF)),
      const SizedBox(height: 16),
      Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      Text(title, style: TextStyle(color: Colors.white.withOpacity(.55))),
    ]),
  );
}

class ProductTile extends StatelessWidget {
  final Product product;
  final bool warning;
  const ProductTile({super.key, required this.product, this.warning = false});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF12141B),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFF252033)),
        child: const Icon(Icons.format_paint_rounded, color: Color(0xFFC99BFF)),
      ),
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${product.category} • ${product.size} • Sell ₹${product.selling.toStringAsFixed(0)}'),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${product.stock} pcs', style: TextStyle(fontWeight: FontWeight.w900, color: warning ? Colors.orangeAccent : Colors.white)),
        Text(warning ? 'LOW STOCK' : 'In Stock', style: TextStyle(fontSize: 11, color: warning ? Colors.orangeAccent : Colors.greenAccent)),
      ]),
    ),
  );
}
