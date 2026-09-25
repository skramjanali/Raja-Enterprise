import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// PRODUCT MODEL
// ============================================================

class Product {
  String name;
  String category;
  String size;
  double purchase;
  double selling;
  int stock;
  int minStock;

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

// ============================================================
// DEMO PRODUCTS
// ============================================================

final List<Product> products = [
  Product(
    name: 'WeatherCoat Long Life 10',
    category: 'Exterior',
    size: '20 L',
    purchase: 5200,
    selling: 5850,
    stock: 11,
    minStock: 5,
  ),
  Product(
    name: 'Easy Clean',
    category: 'Interior',
    size: '20 L',
    purchase: 4100,
    selling: 4650,
    stock: 7,
    minStock: 5,
  ),
  Product(
    name: 'Wall Primer',
    category: 'Primer',
    size: '20 L',
    purchase: 2500,
    selling: 2850,
    stock: 3,
    minStock: 5,
  ),
  Product(
    name: 'Wall Putty',
    category: 'Putty',
    size: '40 Kg',
    purchase: 1450,
    selling: 1650,
    stock: 18,
    minStock: 6,
  ),
];

// ============================================================
// APP
// ============================================================

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
        scaffoldBackgroundColor: const Color(0xFF07080C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB56CFF),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF11141B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

// Compatibility name
class RajaEnterpriseApp extends MyApp {
  const RajaEnterpriseApp({super.key});
}

// ============================================================
// MAIN SHELL
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(onChanged: refresh),
      ProductsPage(onChanged: refresh),
      StockPage(onChanged: refresh),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool mobile = constraints.maxWidth < 700;

        if (mobile) {
          return Scaffold(
            body: SafeArea(
              child: pages[index],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) {
                setState(() {
                  index = value;
                });
              },
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
                  icon: Icon(Icons.swap_vert_outlined),
                  selectedIcon: Icon(Icons.swap_vert),
                  label: 'Stock',
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SideBar(
                  index: index,
                  onSelect: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                ),
                Expanded(
                  child: pages[index],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// SIDEBAR
// ============================================================

class SideBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const SideBar({
    super.key,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      color: const Color(0xFF101117),
      child: Column(
        children: [
          const SizedBox(height: 18),

          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB66CFF),
                  Color(0xFF6844D8),
                ],
              ),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'RAJA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 24),

          _item(
            Icons.dashboard_rounded,
            'Home',
            0,
          ),

          _item(
            Icons.inventory_2_rounded,
            'Products',
            1,
          ),

          _item(
            Icons.swap_vert_rounded,
            'Stock',
            2,
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Icon(
              Icons.settings_outlined,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label,
    int itemIndex,
  ) {
    final bool selected = index == itemIndex;

    return GestureDetector(
      onTap: () => onSelect(itemIndex),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4C2B61)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFD39AFF)
                  : Colors.white70,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? const Color(0xFFD39AFF)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatelessWidget {
  final VoidCallback onChanged;

  const DashboardPage({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int lowStock = products
        .where((p) => p.stock <= p.minStock)
        .length;

    final double stockValue = products.fold(
      0,
      (sum, product) =>
          sum + (product.purchase * product.stock),
    );

    final double sellingValue = products.fold(
      0,
      (sum, product) =>
          sum + (product.selling * product.stock),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Header(
                    title: 'Good morning 👋',
                    subtitle:
                        'RAJA ENTERPRISE • Stock Management',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No new notifications',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate(
              [
                MetricCard(
                  icon: Icons.inventory_2_rounded,
                  value: '${products.length}',
                  label: 'Total Products',
                ),
                MetricCard(
                  icon: Icons.account_balance_wallet_rounded,
                  value:
                      '₹${stockValue.toStringAsFixed(0)}',
                  label: 'Stock Value',
                ),
                MetricCard(
                  icon: Icons.warning_amber_rounded,
                  value: '$lowStock',
                  label: 'Low Stock',
                ),
                const MetricCard(
                  icon: Icons.shopping_cart_rounded,
                  value: '₹0',
                  label: "Today's Sales",
                ),
              ],
            ),
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 138,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            30,
          ),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF28153D),
                    Color(0xFF12141B),
                  ],
                ),
                border: Border.all(
                  color: const Color(
                    0xFF9D63FF,
                  ).withValues(alpha: .25),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Quick view of your paint stock and low-stock items.',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: .62,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ActionButton(
                        icon: Icons.inventory_2,
                        label: 'Products',
                        onPressed: () {},
                      ),
                      ActionButton(
                        icon: Icons.add_box,
                        label: 'Stock In',
                        onPressed: () {},
                      ),
                      ActionButton(
                        icon: Icons.remove_circle,
                        label: 'Stock Out',
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Low Stock Alert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  ...products
                      .where(
                        (p) => p.stock <= p.minStock,
                      )
                      .map(
                        (p) => CompactProduct(
                          product: p,
                        ),
                      ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFFD18CFF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current selling value: ₹${sellingValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

// ============================================================
// PRODUCTS PAGE
// ============================================================

class ProductsPage extends StatefulWidget {
  final VoidCallback onChanged;

  const ProductsPage({
    super.key,
    required this.onChanged,
  });

  @override
  State<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState
    extends State<ProductsPage> {
  String query = '';

  Future<void> addProduct() async {
    final Product? product =
        await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12141B),
      builder: (_) => const AddProductSheet(),
    );

    if (product != null) {
      products.add(product);

      setState(() {});

      widget.onChanged();
    }
  }

  Future<void> editProduct(Product product) async {
    final Product? updated =
        await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12141B),
      builder: (_) => EditProductSheet(
        product: product,
      ),
    );

    if (updated != null) {
      setState(() {});
      widget.onChanged();
    }
  }

  void deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete ${product.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                products.remove(product);
                Navigator.pop(context);
                setState(() {});
                widget.onChanged();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> list = products
        .where(
          (p) => p.name
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                10,
              ),
              sliver: const SliverToBoxAdapter(
                child: Header(
                  title: 'Products & Stock',
                  subtitle:
                      'Manage your Berger Paints inventory',
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon:
                        Icon(Icons.search),
                  ),
                ),
              ),
            ),

            if (list.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  100,
                ),
                sliver: SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, i) {
                      final product = list[i];

                      return ProductCard(
                        product: product,
                        onEdit: () =>
                            editProduct(product),
                        onDelete: () =>
                            deleteProduct(product),
                      );
                    },
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

// ============================================================
// STOCK PAGE
// ============================================================

class StockPage extends StatefulWidget {
  final VoidCallback onChanged;

  const StockPage({
    super.key,
    required this.onChanged,
  });

  @override
  State<StockPage> createState() =>
      _StockPageState();
}

class _StockPageState extends State<StockPage> {
  void change(Product product, int amount) {
    setState(() {
      product.stock =
          (product.stock + amount)
              .clamp(0, 999999)
              .toInt();
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            12,
          ),
          sliver: SliverToBoxAdapter(
            child: Header(
              title: 'Stock Control',
              subtitle:
                  'Quickly add or remove inventory',
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            30,
          ),
          sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate(
              (context, i) {
                final product = products[i];

                return StockCard(
                  product: product,
                  onMinus: () =>
                      change(product, -1),
                  onPlus: () =>
                      change(product, 1),
                );
              },
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ADD PRODUCT SHEET
// ============================================================

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() =>
      _AddProductSheetState();
}

class _AddProductSheetState
    extends State<AddProductSheet> {
  final TextEditingController name =
      TextEditingController();

  final TextEditingController category =
      TextEditingController();

  final TextEditingController size =
      TextEditingController();

  final TextEditingController purchase =
      TextEditingController();

  final TextEditingController selling =
      TextEditingController();

  final TextEditingController stock =
      TextEditingController();

  final TextEditingController minimum =
      TextEditingController(text: '5');

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
    final Product product = Product(
      name: name.text.trim().isEmpty
          ? 'New Product'
          : name.text.trim(),
      category: category.text.trim().isEmpty
          ? 'General'
          : category.text.trim(),
      size: size.text.trim().isEmpty
          ? '-'
          : size.text.trim(),
      purchase:
          double.tryParse(purchase.text) ?? 0,
      selling:
          double.tryParse(selling.text) ?? 0,
      stock:
          int.tryParse(stock.text) ?? 0,
      minStock:
          int.tryParse(minimum.text) ?? 5,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final double bottom =
        MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Add New Product',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 18),

            Field(
              controller: name,
              label: 'Product name',
            ),

            Field(
              controller: category,
              label: 'Category',
            ),

            Field(
              controller: size,
              label: 'Size',
            ),

            Row(
              children: [
                Expanded(
                  child: Field(
                    controller: purchase,
                    label: 'Purchase price',
                    number: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Field(
                    controller: selling,
                    label: 'Selling price',
                    number: true,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Field(
                    controller: stock,
                    label: 'Opening stock',
                    number: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Field(
                    controller: minimum,
                    label: 'Minimum stock',
                    number: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: save,
                icon:
                    const Icon(Icons.save_rounded),
                label:
                    const Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EDIT PRODUCT SHEET
// ============================================================

class EditProductSheet extends StatefulWidget {
  final Product product;

  const EditProductSheet({
    super.key,
    required this.product,
  });

  @override
  State<EditProductSheet> createState() =>
      _EditProductSheetState();
}

class _EditProductSheetState
    extends State<EditProductSheet> {
  late final TextEditingController name;
  late final TextEditingController category;
  late final TextEditingController size;
  late final TextEditingController purchase;
  late final TextEditingController selling;
  late final TextEditingController stock;
  late final TextEditingController minimum;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(
      text: widget.product.name,
    );

    category = TextEditingController(
      text: widget.product.category,
    );

    size = TextEditingController(
      text: widget.product.size,
    );

    purchase = TextEditingController(
      text: widget.product.purchase.toString(),
    );

    selling = TextEditingController(
      text: widget.product.selling.toString(),
    );

    stock = TextEditingController(
      text: widget.product.stock.toString(),
    );

    minimum = TextEditingController(
      text: widget.product.minStock.toString(),
    );
  }

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
    widget.product.name = name.text.trim();
    widget.product.category =
        category.text.trim();
    widget.product.size = size.text.trim();
    widget.product.purchase =
        double.tryParse(purchase.text) ?? 0;
    widget.product.selling =
        double.tryParse(selling.text) ?? 0;
    widget.product.stock =
        int.tryParse(stock.text) ?? 0;
    widget.product.minStock =
        int.tryParse(minimum.text) ?? 5;

    Navigator.pop(context, widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final double bottom =
        MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Edit Product',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 18),

            Field(
              controller: name,
              label: 'Product name',
            ),

            Field(
              controller: category,
              label: 'Category',
            ),

            Field(
              controller: size,
              label: 'Size',
            ),

            Row(
              children: [
                Expanded(
                  child: Field(
                    controller: purchase,
                    label: 'Purchase price',
                    number: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Field(
                    controller: selling,
                    label: 'Selling price',
                    number: true,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Field(
                    controller: stock,
                    label: 'Stock',
                    number: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Field(
                    controller: minimum,
                    label: 'Minimum stock',
                    number: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: save,
                icon:
                    const Icon(Icons.save_rounded),
                label:
                    const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FIELD
// ============================================================

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;

  const Field({
    super.key,
    required this.controller,
    required this.label,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(
                decimal: true,
              )
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF0D0F15),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const Header({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: .55,
            ),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// METRIC CARD
// ============================================================

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
        color: const Color(0xFF11141B),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .07,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF3B244B),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD18CFF),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  label,
                  style: TextStyle(
                    color:
                        Colors.white.withValues(
                      alpha: .55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool low =
        product.stock <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .06,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D38),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.format_paint_rounded,
              color: Color(0xFFD18CFF),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${product.category} • ${product.size}',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(
                      alpha: .55,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Sell ₹${product.selling.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stock} pcs',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                low ? 'Low Stock' : 'In Stock',
                style: TextStyle(
                  color: low
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert,
                  size: 21,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value ==
                      'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STOCK CARD
// ============================================================

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
    final bool low =
        product.stock <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .06,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D38),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.format_paint_rounded,
              color: Color(0xFFD18CFF),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${product.category} • ${product.size}',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(
                      alpha: .55,
                    ),
                  ),
                ),

                if (low) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'LOW STOCK',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed:
                product.stock > 0
                    ? onMinus
                    : null,
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 29,
            ),
          ),

          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '${product.stock}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: onPlus,
            icon: const Icon(
              Icons.add_circle_outline,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMPACT LOW STOCK PRODUCT
// ============================================================

class CompactProduct extends StatelessWidget {
  final Product product;

  const CompactProduct({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orangeAccent,
            size: 20,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              product.name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),

          Text(
            '${product.stock} left',
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

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
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
    );
  }
}
