import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RajaEnterpriseApp());
}

// ============================================================
// COLORS
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

// ============================================================
// APP
// ============================================================

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
        useMaterial3: true,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

// ============================================================
// SPLASH
// ============================================================

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    scale = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();

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
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050509),
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 180,
                width: 180,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(
                    color: Colors.red.withOpacity(.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.25),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/raja_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.storefront,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'RAJA ENTERPRISE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PREMIUM BUSINESS MANAGER',
                style: TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FIRESTORE SERVICE
// ============================================================

class FirestoreService {
  static final FirebaseFirestore db =
      FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>>
      get products => db.collection('products');

  static CollectionReference<Map<String, dynamic>>
      get sales => db.collection('sales');

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      productsStream() {
    return products.orderBy('name').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      salesStream() {
    return sales
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
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

  static Future<void> deleteProduct(
    String id,
  ) async {
    await products.doc(id).delete();
  }

  static Future<void> changeStock(
    String id,
    int amount,
  ) async {
    await db.runTransaction(
      (transaction) async {
        final ref = products.doc(id);

        final snapshot =
            await transaction.get(ref);

        if (!snapshot.exists) {
          throw Exception(
            'Product not found',
          );
        }

        final data =
            snapshot.data()!;

        final currentStock =
            (data['stock'] as num?)
                    ?.toInt() ??
                0;

        final newStock =
            currentStock + amount;

        if (newStock < 0) {
          throw Exception(
            'Stock cannot be negative',
          );
        }

        transaction.update(
          ref,
          {
            'stock': newStock,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ==========================================================
  // CREATE SALE + INVOICE
  // ==========================================================

  static Future<String> createSale({
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    required double purchasePrice,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  }) async {
    final invoiceNo =
        'INV-${DateTime.now().millisecondsSinceEpoch}';

    await db.runTransaction(
      (transaction) async {
        final productRef =
            products.doc(productId);

        final productSnapshot =
            await transaction.get(
          productRef,
        );

        if (!productSnapshot.exists) {
          throw Exception(
            'Product not found',
          );
        }

        final data =
            productSnapshot.data()!;

        final currentStock =
            (data['stock'] as num?)
                    ?.toInt() ??
                0;

        if (currentStock < quantity) {
          throw Exception(
            'Not enough stock',
          );
        }

        final total =
            price * quantity;

        final profit =
            (price - purchasePrice) *
                quantity;

        transaction.update(
          productRef,
          {
            'stock':
                currentStock - quantity,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        final saleRef =
            sales.doc();

        transaction.set(
          saleRef,
          {
            'invoiceNo': invoiceNo,
            'productId': productId,
            'productName': productName,
            'quantity': quantity,
            'price': price,
            'purchasePrice':
                purchasePrice,
            'total': total,
            'profit': profit,
            'customerName':
                customerName,
            'customerPhone':
                customerPhone,
            'customerAddress':
                customerAddress,
            'createdAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );

    return invoiceNo;
  }
}

// ============================================================
// MAIN PAGE
// ============================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState
    extends State<MainPage> {
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
      bottomNavigationBar:
          NavigationBar(
        selectedIndex: index,
        backgroundColor:
            AppColors.surface,
        indicatorColor:
            AppColors.primary.withOpacity(.20),
        height: 72,
        onDestinationSelected:
            (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
            ),
            selectedIcon: Icon(
              Icons.inventory_2,
            ),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.warehouse_outlined,
            ),
            selectedIcon: Icon(
              Icons.warehouse,
            ),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.more_horiz,
            ),
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

class DashboardPage
    extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirestoreService.productsStream(),
        builder:
            (context, productSnapshot) {
          return StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream:
                FirestoreService.salesStream(),
            builder:
                (context, salesSnapshot) {
              final products =
                  productSnapshot.data?.docs ??
                      [];

              final sales =
                  salesSnapshot.data?.docs ??
                      [];

              int totalStock = 0;
              int lowStock = 0;
              double stockValue = 0;
              double todaySales = 0;
              double totalProfit = 0;

              final now =
                  DateTime.now();

              for (final doc
                  in products) {
                final d =
                    doc.data();

                final stock =
                    ((d['stock'] ?? 0)
                            as num)
                        .toInt();

                final purchase =
                    ((d['purchasePrice'] ??
                                0)
                            as num)
                        .toDouble();

                final min =
                    ((d['minStock'] ?? 0)
                            as num)
                        .toInt();

                totalStock += stock;

                stockValue +=
                    stock * purchase;

                if (stock <= min) {
                  lowStock++;
                }
              }

              for (final doc
                  in sales) {
                final d =
                    doc.data();

                final total =
                    ((d['total'] ?? 0)
                            as num)
                        .toDouble();

                final profit =
                    ((d['profit'] ?? 0)
                            as num)
                        .toDouble();

                totalProfit +=
                    profit;

                final timestamp =
                    d['createdAt'];

                if (timestamp
                    is Timestamp) {
                  final date =
                      timestamp
                          .toDate();

                  if (date.year ==
                          now.year &&
                      date.month ==
                          now.month &&
                      date.day ==
                          now.day) {
                    todaySales +=
                        total;
                  }
                }
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child:
                        dashboardHeader(),
                  ),
                  SliverToBoxAdapter(
                    child:
                        heroCard(),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      0,
                    ),
                    sliver: SliverGrid(
                      delegate:
                          SliverChildListDelegate(
                        [
                          MetricCard(
                            title:
                                'Today Sales',
                            value:
                                '₹${money(todaySales)}',
                            icon:
                                Icons.trending_up,
                            color:
                                AppColors.green,
                          ),
                          MetricCard(
                            title:
                                'Total Profit',
                            value:
                                '₹${money(totalProfit)}',
                            icon:
                                Icons.account_balance_wallet,
                            color:
                                AppColors.primary,
                          ),
                          MetricCard(
                            title:
                                'Stock Value',
                            value:
                                '₹${money(stockValue)}',
                            icon:
                                Icons.inventory_2,
                            color:
                                AppColors.blue,
                          ),
                          MetricCard(
                            title:
                                'Low Stock',
                            value:
                                '$lowStock',
                            icon:
                                Icons.warning_amber,
                            color:
                                AppColors.orange,
                          ),
                        ],
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            1.45,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: sectionTitle(
                      'Quick Actions',
                      'Manage your business',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        quickActions(
                      context,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: sectionTitle(
                      'Business Overview',
                      'Your inventory at a glance',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        overviewCard(
                      products.length,
                      totalStock,
                      lowStock,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: sectionTitle(
                      'Recent Sales',
                      'Latest transactions',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        recentSales(
                      sales,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child:
                        SizedBox(height: 30),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// DASHBOARD WIDGETS
// ============================================================

Widget dashboardHeader() {
  return Padding(
    padding:
        const EdgeInsets.fromLTRB(
      18,
      18,
      18,
      12,
    ),
    child: Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF4D35C8),
              ],
            ),
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/raja_logo.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return const Icon(
                  Icons.storefront,
                  color:
                      Colors.white,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'RAJA ENTERPRISE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Business Dashboard',
                style: TextStyle(
                  color:
                      AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
          ),
        ),
      ],
    ),
  );
}

Widget heroCard() {
  return Container(
    margin:
        const EdgeInsets.fromLTRB(
      16,
      6,
      16,
      0,
    ),
    padding:
        const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient:
          const LinearGradient(
        begin:
            Alignment.topLeft,
        end:
            Alignment.bottomRight,
        colors: [
          Color(0xFF32206D),
          Color(0xFF171B38),
          Color(0xFF111827),
        ],
      ),
      borderRadius:
          BorderRadius.circular(26),
      border: Border.all(
        color:
            AppColors.primary
                .withOpacity(.35),
      ),
    ),
    child: const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'PREMIUM ERP',
          style: TextStyle(
            color:
                Color(0xFFD7CEFF),
            fontSize: 10,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Grow your business\nwith confidence.',
          style: TextStyle(
            fontSize: 25,
            height: 1.15,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage products, sales and inventory\nfrom one powerful dashboard.',
          style: TextStyle(
            color:
                AppColors.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget sectionTitle(
  String title,
  String subtitle,
) {
  return Padding(
    padding:
        const EdgeInsets.fromLTRB(
      18,
      24,
      18,
      12,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style:
              const TextStyle(
            color:
                AppColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

Widget quickActions(
  BuildContext context,
) {
  return SizedBox(
    height: 105,
    child: ListView(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      scrollDirection:
          Axis.horizontal,
      children: [
        QuickAction(
          title: 'Add Product',
          icon:
              Icons.add_box_outlined,
          color:
              AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddProductPage(),
              ),
            );
          },
        ),
        QuickAction(
          title: 'New Sale',
          icon:
              Icons.point_of_sale,
          color:
              AppColors.green,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) =>
                  const SaleDialog(),
            );
          },
        ),
        QuickAction(
          title: 'Stock In',
          icon:
              Icons.south_west,
          color:
              AppColors.blue,
          onTap: () {
            stockSelector(
              context,
              true,
            );
          },
        ),
        QuickAction(
          title: 'Stock Out',
          icon:
              Icons.north_east,
          color:
              AppColors.orange,
          onTap: () {
            stockSelector(
              context,
              false,
            );
          },
        ),
      ],
    ),
  );
}

Widget overviewCard(
  int products,
  int stock,
  int low,
) {
  return Container(
    margin:
        const EdgeInsets.symmetric(
      horizontal: 16,
    ),
    padding:
        const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(22),
      border: Border.all(
        color:
            AppColors.border,
      ),
    ),
    child: Column(
      children: [
        overviewRow(
          Icons.inventory_2,
          'Total Products',
          '$products',
          AppColors.primary,
        ),
        const Divider(
          color:
              AppColors.border,
        ),
        overviewRow(
          Icons.warehouse,
          'Total Stock',
          '$stock units',
          AppColors.blue,
        ),
        const Divider(
          color:
              AppColors.border,
        ),
        overviewRow(
          Icons.warning_amber,
          'Low Stock',
          '$low',
          AppColors.orange,
        ),
      ],
    ),
  );
}

Widget overviewRow(
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
        decoration:
            BoxDecoration(
          color:
              color.withOpacity(.12),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.muted,
          ),
        ),
      ),
      Text(
        value,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w800,
        ),
      ),
    ],
  );
}

Widget recentSales(
  List<
      QueryDocumentSnapshot<
          Map<String, dynamic>>> sales,
) {
  if (sales.isEmpty) {
    return emptyCard(
      Icons.receipt_long,
      'No sales yet',
      'Your recent sales will appear here.',
    );
  }

  return Column(
    children:
        sales.take(5).map(
      (doc) {
        final d =
            doc.data();

        final total =
            ((d['total'] ?? 0)
                    as num)
                .toDouble();

        return Container(
          margin:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            9,
          ),
          padding:
              const EdgeInsets.all(
            14,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              17,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color:
                    AppColors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  d['productName']
                          ?.toString() ??
                      'Product',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹${money(total)}',
                style:
                    const TextStyle(
                  color:
                      AppColors.green,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    ).toList(),
  );
}

// ============================================================
// METRIC CARD
// ============================================================

class MetricCard
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  AppColors.muted,
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

class QuickAction
    extends StatelessWidget {
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
        margin:
            const EdgeInsets.only(
          right: 10,
        ),
        padding:
            const EdgeInsets.all(
          13,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
                AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
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

class ProductsPage
    extends StatefulWidget {
  const ProductsPage({
    super.key,
  });

  @override
  State<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState
    extends State<ProductsPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream:
            FirestoreService.productsStream(),
        builder:
            (context, snapshot) {
          final docs =
              snapshot.data?.docs ??
                  [];

          final filtered =
              docs.where(
            (doc) {
              final d =
                  doc.data();

              final name =
                  (d['name'] ??
                          '')
                      .toString()
                      .toLowerCase();

              return name.contains(
                search.toLowerCase(),
              );
            },
          ).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Products',
                          style:
                              TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddProductPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    15,
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Search products...',
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child:
                      _EmptyProducts(),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    30,
                  ),
                  sliver:
                      SliverList(
                    delegate:
                        SliverChildBuilderDelegate(
                      (context, index) {
                        final doc =
                            filtered[index];

                        return ProductCard(
                          doc: doc,
                        );
                      },
                      childCount:
                          filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard
    extends StatelessWidget {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> doc;

  const ProductCard({
    super.key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    final d =
        doc.data();

    final name =
        d['name']?.toString() ??
            'Product';

    final category =
        d['category']?.toString() ??
            'General';

    final stock =
        ((d['stock'] ?? 0)
                as num)
            .toInt();

    final min =
        ((d['minStock'] ?? 0)
                as num)
            .toInt();

    final purchase =
        ((d['purchasePrice'] ?? 0)
                as num)
            .toDouble();

    final selling =
        ((d['sellingPrice'] ?? 0)
                as num)
            .toDouble();

    final low =
        stock <= min;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: low
              ? AppColors.red
                  .withOpacity(.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2,
                color:
                    AppColors.primary,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    Text(
                      category,
                      style:
                          const TextStyle(
                        color:
                            AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<
                  String>(
                onSelected:
                    (value) {
                  if (value ==
                      'in') {
                    stockDialog(
                      context,
                      doc.id,
                      name,
                      true,
                    );
                  }

                  if (value ==
                      'out') {
                    stockDialog(
                      context,
                      doc.id,
                      name,
                      false,
                    );
                  }

                  if (value ==
                      'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddProductPage(
                          productId:
                              doc.id,
                          existing: d,
                        ),
                      ),
                    );
                  }

                  if (value ==
                      'delete') {
                    deleteProduct(
                      context,
                      doc.id,
                      name,
                    );
                  }
                },
                itemBuilder:
                    (_) => const [
                  PopupMenuItem(
                    value: 'in',
                    child:
                        Text(
                      'Stock In',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'out',
                    child:
                        Text(
                      'Stock Out',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child:
                        Text(
                      'Edit',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child:
                        Text(
                      'Delete',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              info(
                'Purchase',
                '₹${money(purchase)}',
              ),
              info(
                'Selling',
                '₹${money(selling)}',
              ),
              info(
                'Stock',
                '$stock',
                color: low
                    ? AppColors.red
                    : AppColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD PRODUCT
// ============================================================

class AddProductPage
    extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>?
      existing;

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
  final formKey =
      GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController category;
  late TextEditingController purchase;
  late TextEditingController selling;
  late TextEditingController stock;
  late TextEditingController minStock;

  bool saving = false;

  bool get editing =>
      widget.productId != null;

  @override
  void initState() {
    super.initState();

    final d =
        widget.existing ?? {};

    name =
        TextEditingController(
      text:
          d['name']?.toString() ??
              '',
    );

    category =
        TextEditingController(
      text:
          d['category']?.toString() ??
              '',
    );

    purchase =
        TextEditingController(
      text:
          d['purchasePrice']
                  ?.toString() ??
              '',
    );

    selling =
        TextEditingController(
      text:
          d['sellingPrice']
                  ?.toString() ??
              '',
    );

    stock =
        TextEditingController(
      text:
          d['stock']?.toString() ??
              '',
    );

    minStock =
        TextEditingController(
      text:
          d['minStock']?.toString() ??
              '5',
    );
  }

  @override
  void dispose() {
    name.dispose();
    category.dispose();
    purchase.dispose();
    selling.dispose();
    stock.dispose();
    minStock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing
              ? 'Edit Product'
              : 'Add Product',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(
            18,
          ),
          children: [
            field(
              name,
              'Product Name',
              Icons.inventory_2,
              required: true,
            ),
            field(
              category,
              'Category',
              Icons.category,
            ),
            field(
              purchase,
              'Purchase Price',
              Icons.shopping_cart,
              number: true,
              required: true,
            ),
            field(
              selling,
              'Selling Price',
              Icons.sell,
              number: true,
              required: true,
            ),
            field(
              stock,
              'Current Stock',
              Icons.warehouse,
              number: true,
              required: true,
            ),
            field(
              minStock,
              'Low Stock Alert',
              Icons.warning,
              number: true,
              required: true,
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed:
                    saving
                        ? null
                        : save,
                icon:
                    const Icon(
                  Icons.save,
                ),
                label:
                    Text(
                  saving
                      ? 'Saving...'
                      : 'Save Product',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
    bool required = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: TextFormField(
        controller:
            controller,
        keyboardType: number
            ? TextInputType.number
            : TextInputType.text,
        validator: (v) {
          if (required &&
              (v == null ||
                  v.trim().isEmpty)) {
            return 'Required';
          }

          if (number &&
              double.tryParse(
                    v ?? '',
                  ) ==
                  null) {
            return 'Enter valid number';
          }

          return null;
        },
        decoration:
            InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon),
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final p =
          double.parse(
        purchase.text,
      );

      final s =
          double.parse(
        selling.text,
      );

      final st =
          int.parse(
        stock.text,
      );

      final m =
          int.parse(
        minStock.text,
      );

      if (editing) {
        await FirestoreService
            .updateProduct(
          widget.productId!,
          name:
              name.text.trim(),
          category:
              category.text.trim(),
          purchasePrice: p,
          sellingPrice: s,
          stock: st,
          minStock: m,
        );
      } else {
        await FirestoreService
            .addProduct(
          name:
              name.text.trim(),
          category:
              category.text.trim(),
          purchasePrice: p,
          sellingPrice: s,
          stock: st,
          minStock: m,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            editing
                ? 'Product updated'
                : 'Product added',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content:
                Text(
              'Error: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }
}

// ============================================================
// SALES PAGE
// ============================================================

class SalesPage
    extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream:
            FirestoreService.salesStream(),
        builder:
            (context, snapshot) {
          final docs =
              snapshot.data?.docs ??
                  [];

          double revenue = 0;
          double profit = 0;

          for (final doc
              in docs) {
            final d =
                doc.data();

            revenue +=
                ((d['total'] ?? 0)
                        as num)
                    .toDouble();

            profit +=
                ((d['profit'] ?? 0)
                        as num)
                    .toDouble();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sales',
                          style:
                              TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      FloatingActionButton.small(
                        onPressed: () {
                          showDialog(
                            context:
                                context,
                            builder:
                                (_) =>
                                    const SaleDialog(),
                          );
                        },
                        child:
                            const Icon(
                          Icons.add,
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
                      child: saleBox(
                        'Revenue',
                        '₹${money(revenue)}',
                        AppColors.green,
                      ),
                    ),
                    Expanded(
                      child: saleBox(
                        'Profit',
                        '₹${money(profit)}',
                        AppColors.primary,
                      ),
                  ],
                ),
              ),
              if (docs.isEmpty)
                const SliverToBoxAdapter(
                  child:
                      _EmptyProducts(),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  sliver:
                      SliverList(
                    delegate:
                        SliverChildBuilderDelegate(
                      (context, index) {
                        final d =
                            docs[index]
                                .data();

                        final total =
                            ((d['total'] ??
                                        0)
                                    as num)
                                .toDouble();

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding:
                              const EdgeInsets.all(
                            15,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            border:
                                Border.all(
                              color:
                                  AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color:
                                    AppColors.green,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['productName']
                                              ?.toString() ??
                                          'Product',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    if (d['invoiceNo'] !=
                                        null)
                                      Text(
                                        d['invoiceNo']
                                            .toString(),
                                        style:
                                            const TextStyle(
                                          color:
                                              AppColors.muted,
                                          fontSize:
                                              10,
                                        ),
                                      ),
                                    Text(
                                      'Qty: ${d['quantity'] ?? 0}',
                                      style:
                                          const TextStyle(
                                        color:
                                            AppColors.muted,
                                        fontSize:
                                            10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${money(total)}',
                                style:
                                    const TextStyle(
                                  color:
                                      AppColors.green,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount:
                          docs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// SALE DIALOG
// ============================================================

class SaleDialog
    extends StatefulWidget {
  const SaleDialog({super.key});

  @override
  State<SaleDialog> createState() =>
      _SaleDialogState();
}

class _SaleDialogState
    extends State<SaleDialog> {
  String? productId;

  Map<String, dynamic>?
      selectedProduct;

  final customerName =
      TextEditingController();

  final customerPhone =
      TextEditingController();

  final customerAddress =
      TextEditingController();

  final quantity =
      TextEditingController(
    text: '1',
  );

  bool saving = false;

  @override
  void dispose() {
    customerName.dispose();
    customerPhone.dispose();
    customerAddress.dispose();
    quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          AppColors.surface,
      title: const Text(
        'New Sale',
        style:
            TextStyle(
          fontWeight:
              FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 430,
        child: StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream:
              FirestoreService
                  .productsStream(),
          builder:
              (context, snapshot) {
            final docs =
                snapshot.data?.docs ??
                    [];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        customerName,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Customer Name',
                      prefixIcon:
                          Icon(
                        Icons.person,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller:
                        customerPhone,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Customer Mobile',
                      prefixIcon:
                          Icon(
                        Icons.phone,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller:
                        customerAddress,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Customer Address',
                      prefixIcon:
                          Icon(
                        Icons.location_on,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  DropdownButtonFormField<
                      String>(
                    value:
                        productId,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Select Product',
                      prefixIcon:
                          Icon(
                        Icons.inventory_2,
                      ),
                    ),
                    items:
                        docs.map(
                      (doc) {
                        final d =
                            doc.data();

                        return DropdownMenuItem<
                            String>(
                          value:
                              doc.id,
                          child:
                              Text(
                            '${d['name']} (${d['stock'] ?? 0})',
                          ),
                        );
                      },
                    ).toList(),
                    onChanged:
                        (id) {
                      setState(() {
                        productId =
                            id;

                        if (id !=
                            null) {
                          selectedProduct =
                              docs
                                  .firstWhere(
                            (x) =>
                                x.id ==
                                id,
                          )
                                  .data();
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller:
                        quantity,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Quantity',
                      prefixIcon:
                          Icon(
                        Icons.numbers,
                      ),
                    ),
                  ),
                  if (selectedProduct !=
                      null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .green
                              .withOpacity(
                            .08,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                        child:
                            Text(
                          'Selling Price: ₹${money(((selectedProduct!['sellingPrice'] ?? 0) as num).toDouble())}\nAvailable Stock: ${selectedProduct!['stock'] ?? 0}',
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () =>
                  Navigator.pop(
                    context,
                  ),
          child:
              const Text(
            'Cancel',
          ),
        ),
        FilledButton.icon(
          onPressed:
              saving
                  ? null
                  : saveSale,
          icon:
              const Icon(
            Icons.receipt_long,
          ),
          label:
              Text(
            saving
                ? 'Saving...'
                : 'Generate Bill',
          ),
        ),
      ],
    );
  }

  Future<void> saveSale() async {
    if (customerName.text
        .trim()
        .isEmpty) {
      error(
        'Enter customer name',
      );
      return;
    }

    if (customerPhone.text
        .trim()
        .isEmpty) {
      error(
        'Enter customer mobile',
      );
      return;
    }

    if (productId == null ||
        selectedProduct ==
            null) {
      error(
        'Select a product',
      );
      return;
    }

    final qty =
        int.tryParse(
      quantity.text,
    );

    if (qty == null ||
        qty <= 0) {
      error(
        'Enter valid quantity',
      );
      return;
    }

    final available =
        ((selectedProduct![
                    'stock'] ??
                0)
            as num)
            .toInt();

    if (qty > available) {
      error(
        'Not enough stock',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final selling =
          ((selectedProduct![
                      'sellingPrice'] ??
                  0)
              as num)
              .toDouble();

      final purchase =
          ((selectedProduct![
                      'purchasePrice'] ??
                  0)
              as num)
              .toDouble();

      final invoice =
          await FirestoreService
              .createSale(
        productId:
            productId!,
        productName:
            selectedProduct![
                    'name']
                .toString(),
        quantity: qty,
        price: selling,
        purchasePrice:
            purchase,
        customerName:
            customerName.text
                .trim(),
        customerPhone:
            customerPhone.text
                .trim(),
        customerAddress:
            customerAddress.text
                .trim(),
      );

      final total =
          selling * qty;

      final profit =
          (selling - purchase) *
              qty;

      if (!mounted) return;

      Navigator.pop(context);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BillPage(
            invoiceNo:
                invoice,
            customerName:
                customerName
                    .text
                    .trim(),
            customerPhone:
                customerPhone
                    .text
                    .trim(),
            customerAddress:
                customerAddress
                    .text
                    .trim(),
            productName:
                selectedProduct![
                        'name']
                    .toString(),
            quantity: qty,
            price: selling,
            total: total,
            profit: profit,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        error(
          e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void error(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }
}

// ============================================================
// BILL PAGE
// ============================================================

class BillPage
    extends StatelessWidget {
  final String invoiceNo;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final double profit;

  const BillPage({
    super.key,
    required this.invoiceNo,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Invoice',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                printBill,
            icon:
                const Icon(
              Icons.print,
            ),
          ),
          IconButton(
            onPressed:
                shareBill,
            icon:
                const Icon(
              Icons.share,
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(
          16,
        ),
        children: [
          Container(
            padding:
                const EdgeInsets.all(
              22,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
              border:
                  Border.all(
                color:
                    AppColors.border,
              ),
            ),
            child:
                Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color:
                      AppColors.green,
                  size: 60,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'SALE COMPLETED',
                  style:
                      TextStyle(
                    color:
                        AppColors.green,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  invoiceNo,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                billRow(
                  'Customer',
                  customerName,
                ),
                billRow(
                  'Mobile',
                  customerPhone,
                ),
                if (customerAddress
                    .isNotEmpty)
                  billRow(
                    'Address',
                    customerAddress,
                  ),
                const Divider(
                  color:
                      AppColors.border,
                ),
                billRow(
                  'Product',
                  productName,
                ),
                billRow(
                  'Quantity',
                  '$quantity',
                ),
                billRow(
                  'Rate',
                  '₹${money(price)}',
                ),
                const Divider(
                  color:
                      AppColors.border,
                ),
                billRow(
                  'TOTAL',
                  '₹${money(total)}',
                  bold: true,
                  color:
                      AppColors.green,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Row(
            children: [
              Expanded(
                child:
                    FilledButton.icon(
                  onPressed:
                      printBill,
                  icon:
                      const Icon(
                    Icons.print,
                  ),
                  label:
                      const Text(
                    'Print Bill',
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child:
                    FilledButton.icon(
                  onPressed:
                      shareBill,
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        AppColors.green,
                  ),
                  icon:
                      const Icon(
                    Icons.share,
                  ),
                  label:
                      const Text(
                    'Share',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget billRow(
    String title,
    String value, {
    bool bold = false,
    Color color =
        AppColors.text,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    AppColors.muted,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color: color,
                fontWeight:
                    bold
                        ? FontWeight
                            .w900
                        : FontWeight
                            .w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List>
      pdfBytes() async {
    final pdf =
        pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.all(
          30,
        ),
        build: (_) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment
                    .start,
            children: [
              pw.Center(
                child:
                    pw.Text(
                  'RAJA ENTERPRISE',
                  style:
                      pw.TextStyle(
                    fontSize: 25,
                    fontWeight:
                        pw.FontWeight
                            .bold,
                  ),
                ),
              ),
              pw.SizedBox(
                height: 5,
              ),
              pw.Center(
                child:
                    pw.Text(
                  'SALES INVOICE',
                  style:
                      const pw.TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
              pw.SizedBox(
                height: 25,
              ),
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'Invoice: $invoiceNo',
                    style:
                        pw.TextStyle(
                      fontWeight:
                          pw.FontWeight
                              .bold,
                    ),
                  ),
                  pw.Text(
                    DateTime.now()
                        .toString()
                        .substring(
                          0,
                          16,
                        ),
                  ),
                ],
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                width:
                    double.infinity,
                padding:
                    const pw.EdgeInsets.all(
                  12,
                ),
                decoration:
                    pw.BoxDecoration(
                  border:
                      pw.Border.all(),
                ),
                child:
                    pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment
                          .start,
                  children: [
                    pw.Text(
                      'CUSTOMER',
                      style:
                          pw.TextStyle(
                        fontWeight:
                            pw.FontWeight
                                .bold,
                      ),
                    ),
                    pw.SizedBox(
                      height: 6,
                    ),
                    pw.Text(
                      customerName,
                    ),
                    pw.Text(
                      customerPhone,
                    ),
                    if (customerAddress
                        .isNotEmpty)
                      pw.Text(
                        customerAddress,
                      ),
                  ],
                ),
              ),
              pw.SizedBox(
                height: 25,
              ),
              pw.Table.fromTextArray(
                headers: const [
                  'Product',
                  'Qty',
                  'Rate',
                  'Amount',
                ],
                data: [
                  [
                    productName,
                    '$quantity',
                    'INR ${money(price)}',
                    'INR ${money(total)}',
                  ],
                ],
              ),
              pw.SizedBox(
                height: 25,
              ),
              pw.Align(
                alignment:
                    pw.Alignment
                        .centerRight,
                child:
                    pw.Container(
                  width: 230,
                  padding:
                      const pw.EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      pw.BoxDecoration(
                    border:
                        pw.Border.all(),
                  ),
                  child:
                      pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment
                                .spaceBetween,
                        children: [
                          pw.Text(
                            'Subtotal',
                          ),
                          pw.Text(
                            'INR ${money(total)}',
                          ),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment
                                .spaceBetween,
                        children: [
                          pw.Text(
                            'GRAND TOTAL',
                            style:
                                pw.TextStyle(
                              fontWeight:
                                  pw.FontWeight
                                      .bold,
                            ),
                          ),
                          pw.Text(
                            'INR ${money(total)}',
                            style:
                                pw.TextStyle(
                              fontWeight:
                                  pw.FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child:
                    pw.Text(
                  'Thank you for your business!',
                ),
              ),
              pw.SizedBox(
                height: 5,
              ),
              pw.Center(
                child:
                    pw.Text(
                  'RAJA ENTERPRISE',
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void>
      printBill() async {
    final bytes =
        await pdfBytes();

    await Printing
        .layoutPdf(
      onLayout:
          (_) async => bytes,
    );
  }

  Future<void>
      shareBill() async {
    final bytes =
        await pdfBytes();

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          '$invoiceNo.pdf',
    );
  }
}

// ============================================================
// STOCK PAGE
// ============================================================

class StockPage
    extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream:
            FirestoreService.productsStream(),
        builder:
            (context, snapshot) {
          final docs =
              snapshot.data?.docs ??
                  [];

          int total = 0;
          int low = 0;

          for (final doc
              in docs) {
            final d =
                doc.data();

            final stock =
                ((d['stock'] ?? 0)
                        as num)
                    .toInt();

            final min =
                ((d['minStock'] ??
                            0)
                        as num)
                    .toInt();

            total += stock;

            if (stock <= min) {
              low++;
            }
          }

          return ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              const Text(
                'Stock',
                style:
                    TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '$total Units • $low Low Stock',
                style:
                    const TextStyle(
                  color:
                      AppColors.muted,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ...docs.map(
                (doc) {
                  final d =
                      doc.data();

                  final stock =
                      ((d['stock'] ??
                                  0)
                              as num)
                          .toInt();

                  final min =
                      ((d['minStock'] ??
                                  0)
                              as num)
                          .toInt();

                  final isLow =
                      stock <= min;

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding:
                        const EdgeInsets.all(
                      15,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      border:
                          Border.all(
                        color: isLow
                            ? AppColors.red
                            : AppColors.border,
                      ),
                    ),
                    child:
                        Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: isLow
                              ? AppColors.red
                              : AppColors.green,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child:
                              Text(
                            d['name']
                                    ?.toString() ??
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
                          style:
                              TextStyle(
                            color: isLow
                                ? AppColors.red
                                : AppColors.green,
                            fontWeight:
                                FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// MORE PAGE
// ============================================================

class MorePage
    extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.all(
          16,
        ),
        children: [
          const Text(
            'More',
            style:
                TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          moreTile(
            context,
            Icons.add_box,
            'Add Product',
            'Create inventory item',
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
          moreTile(
            context,
            Icons.point_of_sale,
            'New Sale',
            'Create new sale',
            AppColors.green,
            () {
              showDialog(
                context: context,
                builder: (_) =>
                    const SaleDialog(),
              );
            },
          ),
          moreTile(
            context,
            Icons.cloud_done,
            'Firebase Database',
            'Connected & synchronised',
            AppColors.blue,
            () {},
          ),
          moreTile(
            context,
            Icons.info_outline,
            'About',
            'RAJA ENTERPRISE',
            AppColors.orange,
            () {
              showAboutDialog(
                context: context,
                applicationName:
                    'RAJA ENTERPRISE',
                applicationVersion:
                    '1.1.0',
                children: const [
                  Text(
                    'Premium business and inventory management app.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON HELPERS
// ============================================================

String money(double value) {
  if (value % 1 == 0) {
    return value
        .toInt()
        .toString();
  }

  return value
      .toStringAsFixed(2);
}

Widget info(
  String title,
  String value, {
  Color color =
      AppColors.text,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.muted,
            fontSize: 9,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          style:
              TextStyle(
            color: color,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

Widget saleBox(
  String title,
  String value,
  Color color,
) {
  return Container(
    margin:
        const EdgeInsets.all(
      6,
    ),
    padding:
        const EdgeInsets.all(
      16,
    ),
    decoration:
        BoxDecoration(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      border:
          Border.all(
        color:
            AppColors.border,
      ),
    ),
    child:
        Column(
      children: [
        Text(
          value,
          style:
              TextStyle(
            color: color,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

Widget emptyCard(
  IconData icon,
  String title,
  String subtitle,
) {
  return Container(
    margin:
        const EdgeInsets.all(
      16,
    ),
    padding:
        const EdgeInsets.all(
      30,
    ),
    decoration:
        BoxDecoration(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      border:
          Border.all(
        color:
            AppColors.border,
      ),
    ),
    child:
        Column(
      children: [
        Icon(
          icon,
          size: 45,
          color:
              AppColors.muted,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          subtitle,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                AppColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

Widget moreTile(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
  Color color,
  VoidCallback onTap,
) {
  return Container(
    margin:
        const EdgeInsets.only(
      bottom: 10,
    ),
    decoration:
        BoxDecoration(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      border:
          Border.all(
        color:
            AppColors.border,
      ),
    ),
    child:
        ListTile(
      onTap: onTap,
      leading:
          Icon(
        icon,
        color: color,
      ),
      title:
          Text(
        title,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w800,
        ),
      ),
      subtitle:
          Text(
        subtitle,
        style:
            const TextStyle(
          color:
              AppColors.muted,
          fontSize: 10,
        ),
      ),
      trailing:
          const Icon(
        Icons.chevron_right,
      ),
    ),
  );
}

// ============================================================
// STOCK HELPERS
// ============================================================

void stockSelector(
  BuildContext context,
  bool stockIn,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor:
        AppColors.surface,
    showDragHandle: true,
    builder: (_) {
      return StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream:
            FirestoreService.productsStream(),
        builder:
            (context, snapshot) {
          final docs =
              snapshot.data?.docs ??
                  [];

          return ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              Text(
                stockIn
                    ? 'Stock In'
                    : 'Stock Out',
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ...docs.map(
                (doc) {
                  final d =
                      doc.data();

                  return ListTile(
                    title:
                        Text(
                      d['name']
                              ?.toString() ??
                          'Product',
                    ),
                    subtitle:
                        Text(
                      'Stock: ${d['stock'] ?? 0}',
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      stockDialog(
                        context,
                        doc.id,
                        d['name']
                                ?.toString() ??
                            'Product',
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

void stockDialog(
  BuildContext context,
  String id,
  String name,
  bool stockIn,
) {
  final controller =
      TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor:
            AppColors.surface,
        title:
            Text(
          stockIn
              ? 'Stock In'
              : 'Stock Out',
        ),
        content:
            TextField(
          controller:
              controller,
          keyboardType:
              TextInputType.number,
          decoration:
              InputDecoration(
            labelText:
                'Quantity',
            hintText:
                name,
            prefixIcon:
                const Icon(
              Icons.numbers,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
                  context,
                ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed:
                () async {
              final qty =
                  int.tryParse(
                controller.text,
              );

              if (qty == null ||
                  qty <= 0) {
                return;
              }

              try {
                await FirestoreService
                    .changeStock(
                  id,
                  stockIn
                      ? qty
                      : -qty,
                );

                if (context
                    .mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              } catch (e) {
                if (context
                    .mounted) {
                  ScaffoldMessenger
                      .of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content:
                          Text(
                        e.toString(),
                      ),
                    ),
                  );
                }
              }
            },
            child:
                const Text(
              'Save',
            ),
          ),
        ],
      );
    },
  );
}

Future<void> deleteProduct(
  BuildContext context,
  String id,
  String name,
) async {
  final ok =
      await showDialog<bool>(
    context: context,
    builder: (_) =>
        AlertDialog(
      title:
          const Text(
        'Delete Product?',
      ),
      content:
          Text(
        'Delete "$name"?',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(
            context,
            false,
          ),
          child:
              const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(
            context,
            true,
          ),
          child:
              const Text(
            'Delete',
          ),
        ),
      ],
    ),
  );

  if (ok == true) {
    await FirestoreService
        .deleteProduct(id);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Product deleted',
          ),
        ),
      );
    }
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyProducts
    extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return emptyCard(
      Icons.inventory_2_outlined,
      'No products found',
      'Add your first product to start managing inventory.',
    );
  }
}
