import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RajaEnterpriseApp());
}

// ============================================================
// APP THEME
// ============================================================

class AppColors {
  static const background = Color(0xFF080D1A);
  static const surface = Color(0xFF111827);
  static const surface2 = Color(0xFF172033);
  static const primary = Color(0xFF7C5CFF);
  static const primaryDark = Color(0xFF6245E8);
  static const green = Color(0xFF16C784);
  static const orange = Color(0xFFFF9F43);
  static const red = Color(0xFFFF4D6D);
  static const blue = Color(0xFF3B82F6);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFF253047);
}

class RajaEnterpriseApp extends StatelessWidget {
  const RajaEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RAJA ENTERPRISE',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.green,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
// ============================================================
// PREMIUM SPLASH SCREEN
// ============================================================

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(
      const Duration(milliseconds: 2600),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050509),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF0000)
                    .withOpacity(.12),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            right: -80,
            child: Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C5CFF)
                    .withOpacity(.10),
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 190,
                    width: 190,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(48),
                      border: Border.all(
                        color: const Color(0xFFFF2020)
                            .withOpacity(.65),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF0000)
                              .withOpacity(.25),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(43),
                      child: Image.asset(
                        'assets/images/raja_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'RAJA ENTERPRISE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'PREMIUM BUSINESS MANAGER',
                    style: TextStyle(
                      color: Color(0xFFFFC857),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),

                  const SizedBox(height: 35),

                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF3B3B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Text(
              'POWERED BY RAJA ENTERPRISE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
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
    return products.orderBy('name').snapshots();
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
    required int minStock,
  }) async {
    await products.add({
      'name': name,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'minStock': minStock,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateProduct(
    String id, {
    required String name,
    required String category,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int minStock,
  }) async {
    await products.doc(id).update({
      'name': name,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'minStock': minStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  static Future<void> changeStock(String id, int amount) async {
    await db.runTransaction((transaction) async {
      final ref = products.doc(id);
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception('Product not found');
      }

      final data = snapshot.data()!;
      final currentStock = (data['stock'] ?? 0) as num;
      final newStock = currentStock.toInt() + amount;

      if (newStock < 0) {
        throw Exception('Stock cannot be negative');
      }

      transaction.update(ref, {
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> createSale({
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    required double purchasePrice,
  }) async {
    await db.runTransaction((transaction) async {
      final productRef = products.doc(productId);
      final productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      final data = productSnapshot.data()!;
      final currentStock = (data['stock'] ?? 0 as num).toInt();

      if (currentStock < quantity) {
        throw Exception('Not enough stock');
      }

      final total = price * quantity;
      final profit = (price - purchasePrice) * quantity;

      transaction.update(productRef, {
        'stock': currentStock - quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final saleRef = sales.doc();

      transaction.set(saleRef, {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'purchasePrice': purchasePrice,
        'total': total,
        'profit': profit,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(.20),
        height: 72,
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
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.productsStream(),
        builder: (context, productSnapshot) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService.salesStream(),
            builder: (context, salesSnapshot) {
              final products =
                  productSnapshot.data?.docs ?? [];

              final sales =
                  salesSnapshot.data?.docs ?? [];

              double stockValue = 0;
              int totalStock = 0;
              int lowStock = 0;
              double todaySales = 0;
              double totalProfit = 0;

              final now = DateTime.now();

              for (final doc in products) {
                final d = doc.data();

                final stock = (d['stock'] as num?)?.toInt() ?? 0;

                final purchase = (d['purchasePrice'] as num?)?.toDouble() ?? 0;
                final minStock = (d['minStock'] as num?)?.toInt() ?? 0;

                totalStock += stock;
                stockValue += stock * purchase;

                if (stock <= minStock) {
                  lowStock++;
                }
              }

              for (final doc in sales) {
                final d = doc.data();

                final total = (d['total'] as num?)?.toDouble() ?? 0;
                final profit = (d['profit'] as num?)?.toDouble() ?? 0;

                totalProfit += profit;

                final timestamp = d['createdAt'];

                if (timestamp is Timestamp) {
                  final date = timestamp.toDate();

                  if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day) {
                    todaySales += total;
                  }
                }
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _dashboardHeader(context),
                  ),

                  SliverToBoxAdapter(
                    child: _heroCard(),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      0,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildListDelegate([
                        MetricCard(
                          title: 'Today Sales',
                          value: '₹${_money(todaySales)}',
                          icon: Icons.trending_up,
                          color: AppColors.green,
                        ),
                        MetricCard(
                          title: 'Total Profit',
                          value: '₹${_money(totalProfit)}',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.primary,
                        ),
                        MetricCard(
                          title: 'Stock Value',
                          value: '₹${_money(stockValue)}',
                          icon: Icons.inventory_2,
                          color: AppColors.blue,
                        ),
                        MetricCard(
                          title: 'Low Stock',
                          value: '$lowStock',
                          icon: Icons.warning_amber,
                          color: AppColors.orange,
                        ),
                      ]),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _sectionTitle(
                      'Quick Actions',
                      'Manage your business',
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _quickActions(context),
                  ),

                  SliverToBoxAdapter(
                    child: _sectionTitle(
                      'Business Overview',
                      'Your inventory at a glance',
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _overviewCard(
                      products.length,
                      totalStock,
                      lowStock,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _sectionTitle(
                      'Recent Sales',
                      'Latest transactions',
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _recentSales(sales),
                  ),

                  SliverToBoxAdapter(
                    child: _sectionTitle(
                      'Low Stock Alert',
                      'Products needing attention',
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _lowStockList(products),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _dashboardHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF4D35C8),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.30),
                  blurRadius: 15,
                ),
              ],
            ),
            child: ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: Image.asset(
    'assets/images/raja_logo.png',
    width: 48,
    height: 48,
    fit: BoxFit.cover,
  ),
),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAJA ENTERPRISE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Business Dashboard',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF32206D),
            Color(0xFF171B38),
            Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withOpacity(.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.14),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PREMIUM ERP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFFD7CEFF),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Grow your business\nwith confidence.',
                style: TextStyle(
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage products, sales and inventory\nfrom one powerful dashboard.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        children: [
          QuickAction(
            title: 'Add Product',
            icon: Icons.add_box_outlined,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddProductPage(),
                ),
              );
            },
          ),
          QuickAction(
            title: 'New Sale',
            icon: Icons.point_of_sale,
            color: AppColors.green,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const SaleDialog(),
              );
            },
          ),
          QuickAction(
            title: 'Stock In',
            icon: Icons.south_west,
            color: AppColors.blue,
            onTap: () {
              _showStockSelector(context, true);
            },
          ),
          QuickAction(
            title: 'Stock Out',
            icon: Icons.north_east,
            color: AppColors.orange,
            onTap: () {
              _showStockSelector(context, false);
            },
          ),
        ],
      ),
    );
  }

  void _showStockSelector(
    BuildContext context,
    bool stockIn,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (_) {
        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirestoreService.productsStream(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                20,
              ),
              children: [
                Text(
                  stockIn
                      ? 'Select Product — Stock In'
                      : 'Select Product — Stock Out',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...docs.map(
                  (doc) {
                    final d = doc.data();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            (stockIn
                                    ? AppColors.blue
                                    : AppColors.orange)
                                .withOpacity(.15),
                        child: Icon(
                          Icons.inventory_2,
                          color: stockIn
                              ? AppColors.blue
                              : AppColors.orange,
                        ),
                      ),
                      title: Text(
                        d['name'] ?? 'Product',
                      ),
                      subtitle: Text(
                        'Current stock: ${d['stock'] ?? 0}',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _stockQuantityDialog(
                          context,
                          doc.id,
                          d['name'] ?? 'Product',
                          stockIn,
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

  void _stockQuantityDialog(
    BuildContext context,
    String id,
    String name,
    bool stockIn,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            stockIn ? 'Stock In' : 'Stock Out',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon:
                      Icon(Icons.numbers),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final qty =
                    int.tryParse(controller.text);

                if (qty == null || qty <= 0) return;

                try {
                  await FirestoreService.changeStock(
                    id,
                    stockIn ? qty : -qty,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          stockIn
                              ? 'Stock added successfully'
                              : 'Stock removed successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                        ),
                      ),
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

  Widget _overviewCard(
    int products,
    int stock,
    int lowStock,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _overviewRow(
            Icons.inventory_2_outlined,
            'Total Products',
            '$products',
            AppColors.primary,
          ),
          const Divider(
            color: AppColors.border,
            height: 24,
          ),
          _overviewRow(
            Icons.warehouse_outlined,
            'Total Stock',
            '$stock units',
            AppColors.blue,
          ),
          const Divider(
            color: AppColors.border,
            height: 24,
          ),
          _overviewRow(
            Icons.warning_amber_rounded,
            'Low Stock Items',
            '$lowStock',
            AppColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _overviewRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _recentSales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> sales,
  ) {
    if (sales.isEmpty) {
      return _emptyCard(
        Icons.receipt_long_outlined,
        'No sales yet',
        'Your recent sales will appear here.',
      );
    }

    return Column(
      children: sales.take(5).map((doc) {
        final d = doc.data();

        final total =
            (d['total'] ?? 0 as num).toDouble();

        return Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            9,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['productName'] ??
                          'Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Qty: ${d['quantity'] ?? 0}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${_money(total)}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _lowStockList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
  ) {
    final low = products.where((doc) {
      final d = doc.data();

      final stock =
          (d['stock'] ?? 0 as num).toInt();

      final minStock =
          (d['minStock'] ?? 0 as num).toInt();

      return stock <= minStock;
    }).toList();

    if (low.isEmpty) {
      return _emptyCard(
        Icons.check_circle_outline,
        'Everything looks good',
        'No products are below the stock alert level.',
      );
    }

    return Column(
      children: low.take(5).map((doc) {
        final d = doc.data();

        final stock =
            (d['stock'] ?? 0 as num).toInt();

        return Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            9,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(.06),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.red.withOpacity(.20),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0x22FF4D6D),
                child: Icon(
                  Icons.warning_amber,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  d['name'] ?? 'Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$stock left',
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.muted,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _money(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

// ============================================================
// METRIC CARD
// ============================================================

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: AppColors.muted,
                size: 18,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACTION
// ============================================================

class QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 112,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// PRODUCTS PAGE
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
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.productsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          final filtered = docs.where((doc) {
            final d = doc.data();
            final name = (d['name'] ?? '').toString().toLowerCase();
            final category =
                (d['category'] ?? '').toString().toLowerCase();

            return name.contains(search.toLowerCase()) ||
                category.contains(search.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _pageHeader(
                  context,
                  'Products',
                  'Manage your inventory',
                  Icons.inventory_2,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 15),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => search = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.tune),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF21194A),
                        AppColors.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      _miniStat(
                        'Products',
                        '${docs.length}',
                        AppColors.primary,
                      ),
                      _miniDivider(),
                      _miniStat(
                        'In Stock',
                        '${_totalStock(docs)}',
                        AppColors.green,
                      ),
                      _miniDivider(),
                      _miniStat(
                        'Low',
                        '${_lowStock(docs)}',
                        AppColors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyProducts(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = filtered[index];
                        return ProductCard(
                          doc: doc,
                          onMenu: () {
                            _showProductMenu(
                              context,
                              doc,
                            );
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pageHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddProductPage(),
                ),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(.14),
            ),
            icon: const Icon(
              Icons.add,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductMenu(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d['name'] ?? 'Product',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),

                _bottomAction(
                  Icons.south_west,
                  'Stock In',
                  AppColors.green,
                  () {
                    Navigator.pop(context);
                    _stockDialog(
                      context,
                      doc.id,
                      d['name'] ?? '',
                      true,
                    );
                  },
                ),

                _bottomAction(
                  Icons.north_east,
                  'Stock Out',
                  AppColors.orange,
                  () {
                    Navigator.pop(context);
                    _stockDialog(
                      context,
                      doc.id,
                      d['name'] ?? '',
                      false,
                    );
                  },
                ),

                _bottomAction(
                  Icons.edit_outlined,
                  'Edit Product',
                  AppColors.primary,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductPage(
                          productId: doc.id,
                          existing: d,
                        ),
                      ),
                    );
                  },
                ),

                _bottomAction(
                  Icons.delete_outline,
                  'Delete Product',
                  AppColors.red,
                  () {
                    Navigator.pop(context);
                    _deleteProduct(
                      context,
                      doc.id,
                      d['name'] ?? '',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomAction(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.muted,
      ),
      onTap: onTap,
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    String id,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirestoreService.deleteProduct(id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted'),
          ),
        );
      }
    }
  }

  void _stockDialog(
    BuildContext context,
    String id,
    String name,
    bool stockIn,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            stockIn ? 'Stock In' : 'Stock Out',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final qty =
                    int.tryParse(controller.text);

                if (qty == null || qty <= 0) return;

                try {
                  await FirestoreService.changeStock(
                    id,
                    stockIn ? qty : -qty,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                        ),
                      ),
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

  int _totalStock(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.fold(
      0,
      (sum, doc) =>
          sum +
          ((doc.data()['stock'] ?? 0) as num).toInt(),
    );
  }

  int _lowStock(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.where((doc) {
      final d = doc.data();
      final stock =
          ((d['stock'] ?? 0) as num).toInt();
      final min =
          ((d['minStock'] ?? 0) as num).toInt();

      return stock <= min;
    }).length;
  }

  Widget _miniStat(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDivider() {
    return Container(
      width: 1,
      height: 35,
      color: AppColors.border,
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final VoidCallback onMenu;

  const ProductCard({
    super.key,
    required this.doc,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final d = doc.data();

    final name = d['name'] ?? 'Product';
    final category = d['category'] ?? 'General';

    final stock =
        ((d['stock'] ?? 0) as num).toInt();

    final minStock =
        ((d['minStock'] ?? 0) as num).toInt();

    final purchase =
        ((d['purchasePrice'] ?? 0) as num).toDouble();

    final selling =
        ((d['sellingPrice'] ?? 0) as num).toDouble();

    final isLow = stock <= minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLow
              ? AppColors.red.withOpacity(.25)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(.25),
                      AppColors.blue.withOpacity(.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.toString(),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenu,
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _price(
                'Purchase',
                '₹${_money(purchase)}',
              ),
              _price(
                'Selling',
                '₹${_money(selling)}',
              ),
              _price(
                'Stock',
                '$stock',
                color: isLow
                    ? AppColors.red
                    : AppColors.green,
              ),
            ],
          ),

          if (isLow) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.red,
                    size: 15,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Low stock — restock required',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _price(
    String title,
    String value, {
    Color color = AppColors.text,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _money(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

// ============================================================
// ADD / EDIT PRODUCT
// ============================================================

class AddProductPage extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existing;

  const AddProductPage({
    super.key,
    this.productId,
    this.existing,
  });

  @override
  State<AddProductPage> createState() =>
      _AddProductPageState();
}

class _AddProductPageState
    extends State<AddProductPage> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController categoryController;
  late final TextEditingController purchaseController;
  late final TextEditingController sellingController;
  late final TextEditingController stockController;
  late final TextEditingController minStockController;

  bool saving = false;

  bool get editing => widget.productId != null;

  @override
  void initState() {
    super.initState();

    final d = widget.existing ?? {};

    nameController = TextEditingController(
      text: d['name']?.toString() ?? '',
    );

    categoryController = TextEditingController(
      text: d['category']?.toString() ?? '',
    );

    purchaseController = TextEditingController(
      text: d['purchasePrice']?.toString() ?? '',
    );

    sellingController = TextEditingController(
      text: d['sellingPrice']?.toString() ?? '',
    );

    stockController = TextEditingController(
      text: d['stock']?.toString() ?? '',
    );

    minStockController = TextEditingController(
      text: d['minStock']?.toString() ?? '5',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    purchaseController.dispose();
    sellingController.dispose();
    stockController.dispose();
    minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          editing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF21194A),
                    AppColors.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.25),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    editing
                        ? 'Update product information'
                        : 'Create a new product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Keep your inventory data accurate.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _field(
              controller: nameController,
              label: 'Product Name',
              icon: Icons.inventory_2_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Enter product name'
                      : null,
            ),

            _field(
              controller: categoryController,
              label: 'Category',
              icon: Icons.category_outlined,
            ),

            _field(
              controller: purchaseController,
              label: 'Purchase Price',
              icon: Icons.shopping_cart_outlined,
              keyboard: TextInputType.number,
              validator: (v) =>
                  double.tryParse(v ?? '') == null
                      ? 'Enter valid price'
                      : null,
            ),

            _field(
              controller: sellingController,
              label: 'Selling Price',
              icon: Icons.sell_outlined,
              keyboard: TextInputType.number,
              validator: (v) =>
                  double.tryParse(v ?? '') == null
                      ? 'Enter valid price'
                      : null,
            ),

            _field(
              controller: stockController,
              label: 'Current Stock',
              icon: Icons.warehouse_outlined,
              keyboard: TextInputType.number,
              validator: (v) =>
                  int.tryParse(v ?? '') == null
                      ? 'Enter valid stock'
                      : null,
            ),

            _field(
              controller: minStockController,
              label: 'Low Stock Alert',
              icon: Icons.warning_amber_outlined,
              keyboard: TextInputType.number,
              validator: (v) =>
                  int.tryParse(v ?? '') == null
                      ? 'Enter valid number'
                      : null,
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        editing
                            ? Icons.save_outlined
                            : Icons.add,
                      ),
                label: Text(
                  saving
                      ? 'Saving...'
                      : editing
                          ? 'Update Product'
                          : 'Save Product',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final name = nameController.text.trim();
      final category = categoryController.text.trim();

      final purchase =
          double.parse(purchaseController.text);

      final selling =
          double.parse(sellingController.text);

      final stock =
          int.parse(stockController.text);

      final minStock =
          int.parse(minStockController.text);

      if (editing) {
        await FirestoreService.updateProduct(
          widget.productId!,
          name: name,
          category: category,
          purchasePrice: purchase,
          sellingPrice: selling,
          stock: stock,
          minStock: minStock,
        );
      } else {
        await FirestoreService.addProduct(
          name: name,
          category: category,
          purchasePrice: purchase,
          sellingPrice: selling,
          stock: stock,
          minStock: minStock,
        );
      }

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editing
                  ? 'Product updated successfully'
                  : 'Product added successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

// ============================================================
// SALES PAGE
// ============================================================

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.salesStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          double totalSales = 0;
          double totalProfit = 0;
          int quantity = 0;

          for (final doc in docs) {
            final d = doc.data();

            totalSales +=
                ((d['total'] ?? 0) as num).toDouble();

            totalProfit +=
                ((d['profit'] ?? 0) as num).toDouble();

            quantity +=
                ((d['quantity'] ?? 0) as num).toInt();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Sales',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track your business sales',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FloatingActionButton.small(
                        heroTag: 'salesAdd',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                const SaleDialog(),
                          );
                        },
                        backgroundColor:
                            AppColors.green,
                        child: const Icon(
                          Icons.add,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _saleStat(
                          'Revenue',
                          '₹${_money(totalSales)}',
                          AppColors.green,
                        ),
                      ),
                      Expanded(
                        child: _saleStat(
                          'Profit',
                          '₹${_money(totalProfit)}',
                          AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: _saleStat(
                          'Units',
                          '$quantity',
                          AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (docs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: _EmptyProducts(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    30,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final d = docs[index].data();

                        final total =
                            ((d['total'] ?? 0) as num)
                                .toDouble();

                        final profit =
                            ((d['profit'] ?? 0) as num)
                                .toDouble();

                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: 10),
                          padding:
                              const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.green
                                      .withOpacity(.12),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['productName'] ??
                                          'Product',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${d['quantity'] ?? 0}  •  ₹${d['price'] ?? 0}/unit',
                                      style:
                                          const TextStyle(
                                        color:
                                            AppColors.muted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${_money(total)}',
                                    style:
                                        const TextStyle(
                                      color:
                                          AppColors.green,
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Profit ₹${_money(profit)}',
                                    style:
                                        const TextStyle(
                                      color:
                                          AppColors.primary,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _saleStat(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static String _money(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

// ============================================================
// SALE DIALOG
// ============================================================

class SaleDialog extends StatefulWidget {
  const SaleDialog({super.key});

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  String? productId;
  Map<String, dynamic>? selectedProduct;

  final quantityController =
      TextEditingController(text: '1');

  bool saving = false;

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Row(
        children: [
          Icon(
            Icons.point_of_sale,
            color: AppColors.green,
          ),
          SizedBox(width: 10),
          Text(
            'New Sale',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      content: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.productsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: productId,
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                    prefixIcon:
                        Icon(Icons.inventory_2_outlined),
                  ),
                  items: docs.map((doc) {
                    final d = doc.data();

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        '${d['name']}  (${d['stock'] ?? 0})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    setState(() {
                      productId = id;

                      if (id != null) {
                        final doc = docs.firstWhere(
                          (x) => x.id == id,
                        );
                        selectedProduct = doc.data();
                      }
                    });
                  },
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon:
                        Icon(Icons.numbers),
                  ),
                ),

                if (selectedProduct != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(.07),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selling Price: ₹${selectedProduct!['sellingPrice'] ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available Stock: ${selectedProduct!['stock'] ?? 0}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
          ),
          onPressed: saving ? null : _saveSale,
          child: saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Complete Sale'),
        ),
      ],
    );
  }

  Future<void> _saveSale() async {
    if (productId == null ||
        selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
        ),
      );
      return;
    }

    final quantity =
        int.tryParse(quantityController.text);

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid quantity'),
        ),
      );
      return;
    }

    final stock =
        ((selectedProduct!['stock'] ?? 0) as num)
            .toInt();

    if (quantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough stock'),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final selling =
          ((selectedProduct!['sellingPrice'] ?? 0)
                  as num)
              .toDouble();

      final purchase =
          ((selectedProduct!['purchasePrice'] ?? 0)
                  as num)
              .toDouble();

      await FirestoreService.createSale(
        productId: productId!,
        productName:
            selectedProduct!['name'] ?? 'Product',
        quantity: quantity,
        price: selling,
        purchasePrice: purchase,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sale completed successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

// ============================================================
// STOCK PAGE
// ============================================================

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.productsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          int total = 0;
          int low = 0;

          for (final doc in docs) {
            final d = doc.data();

            final stock =
                ((d['stock'] ?? 0) as num).toInt();

            final min =
                ((d['minStock'] ?? 0) as num).toInt();

            total += stock;

            if (stock <= min) {
              low++;
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    15,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Inventory overview',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.green.withOpacity(.10),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$total Units',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _stockSummary(
                        'Total Stock',
                        '$total',
                        Icons.warehouse,
                        AppColors.blue,
                      ),
                    ),
                    Expanded(
                      child: _stockSummary(
                        'Low Stock',
                        '$low',
                        Icons.warning_amber,
                        AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final d = docs[index].data();

                      final stock =
                          ((d['stock'] ?? 0) as num)
                              .toInt();

                      final min =
                          ((d['minStock'] ?? 0) as num)
                              .toInt();

                      final ratio = min <= 0
                          ? 1.0
                          : (stock / (min * 3))
                              .clamp(0.0, 1.0);

                      final low = stock <= min;

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        padding:
                            const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: low
                                ? AppColors.red
                                    .withOpacity(.20)
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: (low
                                            ? AppColors.red
                                            : AppColors.blue)
                                        .withOpacity(.12),
                                    borderRadius:
                                        BorderRadius.circular(
                                            13),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: low
                                        ? AppColors.red
                                        : AppColors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    d['name'] ??
                                        'Product',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$stock',
                                  style: TextStyle(
                                    color: low
                                        ? AppColors.red
                                        : AppColors.green,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 7,
                                backgroundColor:
                                    AppColors.surface2,
                                valueColor:
                                    AlwaysStoppedAnimation(
                                  low
                                      ? AppColors.red
                                      : AppColors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Text(
                                  'Minimum: $min',
                                  style:
                                      const TextStyle(
                                    color:
                                        AppColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  low
                                      ? 'RESTOCK'
                                      : 'HEALTHY',
                                  style:
                                      TextStyle(
                                    color: low
                                        ? AppColors.red
                                        : AppColors.green,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stockSummary(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MORE PAGE
// ============================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        children: [
          const Text(
            'More',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Business settings & tools',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF31206B),
                  Color(0xFF111827),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(.30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RAJA ENTERPRISE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Premium Business Manager',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _menu(
            context,
            Icons.add_box_outlined,
            'Add Product',
            'Create a new inventory item',
            AppColors.primary,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AddProductPage(),
                ),
              );
            },
          ),

          _menu(
            context,
            Icons.point_of_sale,
            'New Sale',
            'Create a new sales transaction',
            AppColors.green,
            () {
              showDialog(
                context: context,
                builder: (_) =>
                    const SaleDialog(),
              );
            },
          ),

          _menu(
            context,
            Icons.cloud_done_outlined,
            'Firebase Database',
            'Connected & synchronised',
            AppColors.blue,
            () {},
          ),

          _menu(
            context,
            Icons.security_outlined,
            'Data & Security',
            'Your business data is stored in Firebase',
            AppColors.orange,
            () {},
          ),

          _menu(
            context,
            Icons.info_outline,
            'About',
            'RAJA ENTERPRISE Stock Manager',
            AppColors.primary,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'RAJA ENTERPRISE',
                applicationVersion: '1.1.0',
                applicationIcon: const Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                  size: 35,
                ),
                children: const [
                  Text(
                    'Premium inventory and sales management app.',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'RAJA ENTERPRISE • Version 1.1.0',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.muted,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// EMPTY PRODUCT
// ============================================================

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 45,
            color: AppColors.muted,
          ),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add your first product to start managing inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
