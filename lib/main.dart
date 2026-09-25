import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color bg = Color(0xFF07080C);
const Color card = Color(0xFF11141B);
const Color purple = Color(0xFFD18CFF);
const Color purpleDark = Color(0xFF3B244B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

/* ============================================================
   MODELS
============================================================ */

class Product {
  final String id;
  final String name;
  final String category;
  final String size;
  final double purchase;
  final double selling;
  final int stock;
  final int minStock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.purchase,
    required this.selling,
    required this.stock,
    required this.minStock,
  });

  factory Product.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Product(
      id: doc.id,
      name: data['name']?.toString() ?? 'Product',
      category: data['category']?.toString() ?? 'General',
      size: data['size']?.toString() ?? '-',
      purchase: toDouble(data['purchase']),
      selling: toDouble(data['selling']),
      stock: toInt(data['stock']),
      minStock: toInt(data['minStock'], fallback: 5),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'size': size,
      'purchase': purchase,
      'selling': selling,
      'stock': stock,
      'minStock': minStock,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Sale {
  final String id;
  final String customer;
  final String product;
  final String productId;
  final int quantity;
  final double amount;
  final DateTime date;

  const Sale({
    required this.id,
    required this.customer,
    required this.product,
    required this.productId,
    required this.quantity,
    required this.amount,
    required this.date,
  });

  factory Sale.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime date = DateTime.now();

    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    }

    return Sale(
      id: doc.id,
      customer: data['customer']?.toString() ?? 'Walk-in Customer',
      product: data['product']?.toString() ?? '',
      productId: data['productId']?.toString() ?? '',
      quantity: toInt(data['quantity']),
      amount: toDouble(data['amount']),
      date: date,
    );
  }
}

double toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int toInt(dynamic value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

/* ============================================================
   FIRESTORE DATABASE
============================================================ */

class DatabaseService {
  static final FirebaseFirestore db =
      FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>>
      get productCollection => db.collection('products');

  static CollectionReference<Map<String, dynamic>>
      get saleCollection => db.collection('sales');

  static Stream<List<Product>> productsStream() {
    return productCollection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Product.fromDoc).toList(),
        );
  }

  static Stream<List<Sale>> salesStream() {
    return saleCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Sale.fromDoc).toList(),
        );
  }

  static Future<void> addProduct(Product product) async {
    await productCollection.add(product.toMap());
  }

  static Future<void> deleteProduct(String id) async {
    await productCollection.doc(id).delete();
  }

  static Future<void> changeStock(
    String id,
    int amount,
  ) async {
    await productCollection.doc(id).update({
      'stock': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> createSale({
    required Product product,
    required String customer,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception('Invalid quantity');
    }

    final productRef =
        productCollection.doc(product.id);

    final saleRef = saleCollection.doc();

    await db.runTransaction((transaction) async {
      final snapshot =
          await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('Product not found');
      }

      final data = snapshot.data() ?? {};

      final currentStock =
          toInt(data['stock']);

      if (quantity > currentStock) {
        throw Exception('Not enough stock');
      }

      final selling =
          toDouble(data['selling']);

      final total =
          selling * quantity;

      transaction.update(productRef, {
        'stock': currentStock - quantity,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      transaction.set(saleRef, {
        'customer': customer.trim().isEmpty
            ? 'Walk-in Customer'
            : customer.trim(),
        'product':
            data['name']?.toString() ?? product.name,
        'productId': product.id,
        'quantity': quantity,
        'amount': total,
        'date':
            FieldValue.serverTimestamp(),
      });
    });
  }
}

/* ============================================================
   APP
============================================================ */

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

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(0xFFB56CFF),
          brightness:
              Brightness.dark,
        ),
      ),

      home: const MainShell(),
    );
  }
}

/* ============================================================
   MAIN NAVIGATION
============================================================ */

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {

  int index = 0;

  @override
  Widget build(BuildContext context) {

    final pages = const [
      DashboardPage(),
      ProductsPage(),
      SalesPage(),
      StockPage(),
      MorePage(),
    ];

    return Scaffold(

      body: SafeArea(
        child: pages[index],
      ),

      bottomNavigationBar:
          NavigationBar(

        selectedIndex: index,

        onDestinationSelected:
            (value) {
          setState(() {
            index = value;
          });
        },

        backgroundColor:
            const Color(0xFF11131A),

        indicatorColor:
            const Color(0xFF5A347A),

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
              Icons.point_of_sale_outlined,
            ),
            selectedIcon: Icon(
              Icons.point_of_sale,
            ),
            label: 'Sales',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.swap_vert_outlined,
            ),
            selectedIcon: Icon(
              Icons.swap_vert,
            ),
            label: 'Stock',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.more_horiz,
            ),
            selectedIcon: Icon(
              Icons.more_horiz,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   DASHBOARD
============================================================ */

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Product>>(
      stream:
          DatabaseService.productsStream(),

      builder:
          (context, productSnapshot) {

        if (productSnapshot.hasError) {
          return ErrorView(
            message:
                productSnapshot.error.toString(),
          );
        }

        if (!productSnapshot.hasData) {
          return const LoadingView();
        }

        final products =
            productSnapshot.data!;

        return StreamBuilder<List<Sale>>(
          stream:
              DatabaseService.salesStream(),

          builder:
              (context, saleSnapshot) {

            final sales =
                saleSnapshot.data ?? [];

            final stockValue =
                products.fold<double>(
              0,
              (sum, product) =>
                  sum +
                  product.purchase *
                      product.stock,
            );

            final now =
                DateTime.now();

            final todaySales =
                sales.where((sale) {
              return sale.date.year ==
                      now.year &&
                  sale.date.month ==
                      now.month &&
                  sale.date.day ==
                      now.day;
            }).fold<double>(
              0,
              (sum, sale) =>
                  sum + sale.amount,
            );

            final lowStock =
                products
                    .where(
                      (p) =>
                          p.stock <=
                          p.minStock,
                    )
                    .length;

            return CustomScrollView(

              slivers: [

                /* HEADER */

                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    12,
                  ),

                  sliver:
                      SliverToBoxAdapter(

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                'Good morning 👋',

                                style:
                                    TextStyle(
                                  fontSize: 31,
                                  fontWeight:
                                      FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),

                              SizedBox(
                                height: 8,
                              ),

                              Text(
                                'RAJA ENTERPRISE • Business Management',

                                style:
                                    TextStyle(
                                  color:
                                      Colors.white60,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            showSimpleMessage(
                              context,
                              'No new notifications',
                            );
                          },

                          icon: const Icon(
                            Icons
                                .notifications_none_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /* METRICS */

                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  sliver:
                      SliverGrid(

                    delegate:
                        SliverChildListDelegate([

                      MetricCard(
                        icon: Icons
                            .inventory_2_rounded,
                        value:
                            '${products.length}',
                        label: 'Products',
                      ),

                      MetricCard(
                        icon: Icons
                            .account_balance_wallet_rounded,
                        value:
                            '₹${stockValue.toStringAsFixed(0)}',
                        label:
                            'Stock Value',
                      ),

                      MetricCard(
                        icon: Icons
                            .warning_amber_rounded,
                        value:
                            '$lowStock',
                        label:
                            'Low Stock',
                      ),

                      MetricCard(
                        icon: Icons
                            .point_of_sale_rounded,
                        value:
                            '₹${todaySales.toStringAsFixed(0)}',
                        label:
                            "Today's Sales",
                      ),
                    ]),

                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(

                      maxCrossAxisExtent:
                          360,

                      mainAxisExtent:
                          138,

                      crossAxisSpacing:
                          12,

                      mainAxisSpacing:
                          12,
                    ),
                  ),
                ),

                /* QUICK ACTION */

                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    30,
                  ),

                  sliver:
                      SliverToBoxAdapter(

                    child: Container(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),

                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF28153D),
                            Color(0xFF12141B),
                          ],
                        ),

                        border:
                            Border.all(
                          color:
                              purple.withOpacity(
                            .25,
                          ),
                        ),
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Quick Actions',

                            style:
                                TextStyle(
                              fontSize: 23,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Manage your business from one place.',

                            style:
                                TextStyle(
                              color:
                                  Colors.white60,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,

                            children: [

                              ActionButton(
                                icon: Icons
                                    .add_shopping_cart,
                                label:
                                    'New Sale',

                                onPressed:
                                    () =>
                                        showSaleDialog(
                                          context,
                                        ),
                              ),

                              ActionButton(
                                icon:
                                    Icons.add_box,
                                label:
                                    'Stock In',

                                onPressed:
                                    () =>
                                        showStockDialog(
                                          context,
                                          true,
                                        ),
                              ),

                              ActionButton(
                                icon: Icons
                                    .remove_circle,
                                label:
                                    'Stock Out',

                                onPressed:
                                    () =>
                                        showStockDialog(
                                          context,
                                          false,
                                        ),
                              ),

                              ActionButton(
                                icon: Icons
                                    .receipt_long,
                                label:
                                    'Invoice',

                                onPressed:
                                    () =>
                                        showInvoiceDialog(
                                          context,
                                        ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          const Text(
                            'Low Stock Alert',

                            style:
                                TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          ...products
                              .where(
                                (p) =>
                                    p.stock <=
                                    p.minStock,
                              )
                              .map(
                                (p) =>
                                    Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 8,
                                  ),

                                  child: Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .warning_amber_rounded,
                                        color:
                                            Colors
                                                .orangeAccent,
                                        size: 20,
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          p.name,
                                        ),
                                      ),

                                      Text(
                                        '${p.stock} left',

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors
                                                  .orangeAccent,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
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
          },
        );
      },
    );
  }
}

/* ============================================================
   PRODUCTS PAGE
============================================================ */

class ProductsPage
    extends StatefulWidget {

  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState
    extends State<ProductsPage> {

  String query = '';

  Future<void> addProduct() async {

    final product =
        await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      builder: (_) =>
          const ProductForm(),
    );

    if (product == null) return;

    try {

      await DatabaseService
          .addProduct(product);

      if (mounted) {
        showSimpleMessage(
          context,
          'Product added successfully',
        );
      }

    } catch (e) {

      if (mounted) {
        showSimpleMessage(
          context,
          'Error: $e',
        );
      }
    }
  }

  Future<void> deleteProduct(
      Product product) async {

    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (_) => AlertDialog(

        title:
            const Text(
          'Delete product?',
        ),

        content:
            Text(product.name),

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child:
                const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            child:
                const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {

      await DatabaseService
          .deleteProduct(
        product.id,
      );

      if (mounted) {
        showSimpleMessage(
          context,
          'Product deleted',
        );
      }

    } catch (e) {

      if (mounted) {
        showSimpleMessage(
          context,
          'Error: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Product>>(
      stream:
          DatabaseService.productsStream(),

      builder:
          (context, snapshot) {

        if (snapshot.hasError) {
          return ErrorView(
            message:
                snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData) {
          return const LoadingView();
        }

        final list =
            snapshot.data!
                .where(
                  (product) =>
                      product.name
                          .toLowerCase()
                          .contains(
                            query
                                .toLowerCase(),
                          ),
                )
                .toList();

        return Stack(

          children: [

            CustomScrollView(

              slivers: [

                const SliverPadding(
                  padding:
                      EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    12,
                  ),

                  sliver:
                      SliverToBoxAdapter(
                    child: PageHeader(
                      title:
                          'Products',
                      subtitle:
                          'Manage products, prices and stock',
                    ),
                  ),
                ),

                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  sliver:
                      SliverToBoxAdapter(

                    child: TextField(

                      onChanged:
                          (value) {
                        setState(() {
                          query = value;
                        });
                      },

                      decoration:
                          InputDecoration(

                        hintText:
                            'Search products...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                            card,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    100,
                  ),

                  sliver:
                      list.isEmpty
                          ? const SliverFillRemaining(
                              hasScrollBody:
                                  false,

                              child:
                                  Center(
                                child:
                                    Text(
                                  'No products found',
                                ),
                              ),
                            )
                          : SliverList(
                              delegate:
                                  SliverChildBuilderDelegate(
                                (_, i) =>
                                    ProductCard(
                                  product:
                                      list[i],

                                  onDelete:
                                      () =>
                                          deleteProduct(
                                    list[i],
                                  ),
                                ),

                                childCount:
                                    list.length,
                              ),
                            ),
                ),
              ],
            ),

            Positioned(
              right: 18,
              bottom: 18,

              child:
                  FloatingActionButton.extended(

                onPressed:
                    addProduct,

                icon:
                    const Icon(
                  Icons.add,
                ),

                label:
                    const Text(
                  'Add Product',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* ============================================================
   STOCK PAGE
============================================================ */

class StockPage
    extends StatelessWidget {

  const StockPage({super.key});

  Future<void> changeStock(
    BuildContext context,
    Product product,
    int amount,
  ) async {

    if (amount < 0 &&
        product.stock <= 0) {
      return;
    }

    if (amount < 0 &&
        product.stock + amount < 0) {

      showSimpleMessage(
        context,
        'Stock cannot go below zero',
      );

      return;
    }

    try {

      await DatabaseService.changeStock(
        product.id,
        amount,
      );

    } catch (e) {

      if (context.mounted) {
        showSimpleMessage(
          context,
          'Error: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Product>>(
      stream:
          DatabaseService.productsStream(),

      builder:
          (context, snapshot) {

        if (snapshot.hasError) {
          return ErrorView(
            message:
                snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData) {
          return const LoadingView();
        }

        final products =
            snapshot.data!;

        return CustomScrollView(

          slivers: [

            const SliverPadding(
              padding:
                  EdgeInsets.fromLTRB(
                20,
                22,
                20,
                14,
              ),

              sliver:
                  SliverToBoxAdapter(
                child: PageHeader(
                  title:
                      'Stock Control',
                  subtitle:
                      'Quickly add or remove inventory',
                ),
              ),
            ),

            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                30,
              ),

              sliver:
                  products.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody:
                              false,

                          child:
                              Center(
                            child:
                                Text(
                              'No products',
                            ),
                          ),
                        )
                      : SliverList(
                          delegate:
                              SliverChildBuilderDelegate(
                            (_, i) =>
                                StockCard(
                              product:
                                  products[i],

                              onMinus:
                                  () =>
                                      changeStock(
                                context,
                                products[i],
                                -1,
                              ),

                              onPlus:
                                  () =>
                                      changeStock(
                                context,
                                products[i],
                                1,
                              ),
                            ),

                            childCount:
                                products.length,
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

/* ============================================================
   SALES PAGE
============================================================ */

class SalesPage
    extends StatelessWidget {

  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Sale>>(
      stream:
          DatabaseService.salesStream(),

      builder:
          (context, snapshot) {

        if (snapshot.hasError) {
          return ErrorView(
            message:
                snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData) {
          return const LoadingView();
        }

        final sales =
            snapshot.data!;

        final total =
            sales.fold<double>(
          0,
          (sum, sale) =>
              sum + sale.amount,
        );

        return CustomScrollView(

          slivers: [

            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                12,
              ),

              sliver:
                  SliverToBoxAdapter(

                child: Row(
                  children: [

                    const Expanded(
                      child:
                          PageHeader(
                        title:
                            'Sales',
                        subtitle:
                            'Track sales and customer invoices',
                      ),
                    ),

                    FilledButton.icon(
                      onPressed:
                          () =>
                              showSaleDialog(
                        context,
                      ),

                      icon:
                          const Icon(
                        Icons.add,
                      ),

                      label:
                          const Text(
                        'Sale',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),

              sliver:
                  SliverToBoxAdapter(

                child: Container(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        const Color(
                      0xFF28153D,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                  ),

                  child: Row(

                    children: [

                      const Icon(
                        Icons.currency_rupee,
                        color:
                            purple,
                        size: 30,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            'Total Sales',

                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                .65,
                              ),
                            ),
                          ),

                          Text(
                            '₹${total.toStringAsFixed(0)}',

                            style:
                                const TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                15,
                18,
                30,
              ),

              sliver:
                  sales.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody:
                              false,

                          child:
                              Center(
                            child:
                                Text(
                              'No sales recorded yet',
                            ),
                          ),
                        )
                      : SliverList(
                          delegate:
                              SliverChildBuilderDelegate(
                            (_, i) =>
                                SaleCard(
                              sale:
                                  sales[i],
                            ),

                            childCount:
                                sales.length,
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

/* ============================================================
   MORE PAGE
============================================================ */

class MorePage
    extends StatelessWidget {

  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(

      padding:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        30,
      ),

      children: [

        const PageHeader(
          title:
              'More',
          subtitle:
              'Business tools and settings',
        ),

        const SizedBox(
          height: 20,
        ),

        MoreTile(
          icon:
              Icons.people_alt_outlined,
          title:
              'Customers',
          subtitle:
              'Manage customer information',
          onTap:
              () => showSimpleMessage(
            context,
            'Customer module ready',
          ),
        ),

        MoreTile(
          icon:
              Icons.receipt_long_outlined,
          title:
              'Invoices',
          subtitle:
              'Create and view invoices',
          onTap:
              () => showInvoiceDialog(
            context,
          ),
        ),

        MoreTile(
          icon:
              Icons.shopping_bag_outlined,
          title:
              'Purchases',
          subtitle:
              'Track supplier purchases',
          onTap:
              () => showSimpleMessage(
            context,
            'Purchase module ready',
          ),
        ),

        MoreTile(
          icon:
              Icons.bar_chart_outlined,
          title:
              'Reports',
          subtitle:
              'Sales and stock reports',
          onTap:
              () => showSimpleMessage(
            context,
            'Reports module ready',
          ),
        ),

        MoreTile(
          icon:
              Icons.settings_outlined,
          title:
              'Settings',
          subtitle:
              'Business settings',
          onTap:
              () => showSettingsDialog(
            context,
          ),
        ),

        MoreTile(
          icon:
              Icons.info_outline,
          title:
              'About RAJA ENTERPRISE',
          subtitle:
              'Stock Management App',
          onTap:
              () => showAboutDialog(
            context: context,
            applicationName:
                'RAJA ENTERPRISE',
            applicationVersion:
                '1.0.0',
            applicationLegalese:
                'Business Management',
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   ADD PRODUCT FORM
============================================================ */

class ProductForm
    extends StatefulWidget {

  const ProductForm({super.key});

  @override
  State<ProductForm> createState() =>
      _ProductFormState();
}

class _ProductFormState
    extends State<ProductForm> {

  final name =
      TextEditingController();

  final category =
      TextEditingController();

  final size =
      TextEditingController();

  final purchase =
      TextEditingController();

  final selling =
      TextEditingController();

  final stock =
      TextEditingController();

  final minimum =
      TextEditingController(
    text: '5',
  );

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
        id: '',

        name:
            name.text.trim().isEmpty
                ? 'New Product'
                : name.text.trim(),

        category:
            category.text.trim().isEmpty
                ? 'General'
                : category.text.trim(),

        size:
            size.text.trim().isEmpty
                ? '-'
                : size.text.trim(),

        purchase:
            double.tryParse(
                  purchase.text,
                ) ??
                0,

        selling:
            double.tryParse(
                  selling.text,
                ) ??
                0,

        stock:
            int.tryParse(
                  stock.text,
                ) ??
                0,

        minStock:
            int.tryParse(
                  minimum.text,
                ) ??
                5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final bottom =
        MediaQuery.viewInsetsOf(
      context,
    ).bottom;

    return Padding(

      padding:
          EdgeInsets.fromLTRB(
        18,
        18,
        18,
        bottom + 18,
      ),

      child:
          SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SheetHandle(),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Add New Product',

              style:
                  TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            AppField(
              controller: name,
              label:
                  'Product name',
            ),

            AppField(
              controller: category,
              label:
                  'Category',
            ),

            AppField(
              controller: size,
              label:
                  'Size',
            ),

            Row(
              children: [

                Expanded(
                  child:
                      AppField(
                    controller:
                        purchase,
                    label:
                        'Purchase price',
                    number:
                        true,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      AppField(
                    controller:
                        selling,
                    label:
                        'Selling price',
                    number:
                        true,
                  ),
                ),
              ],
            ),

            Row(
              children: [

                Expanded(
                  child:
                      AppField(
                    controller:
                        stock,
                    label:
                        'Opening stock',
                    number:
                        true,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      AppField(
                    controller:
                        minimum,
                    label:
                        'Minimum stock',
                    number:
                        true,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  FilledButton.icon(

                onPressed:
                    save,

                icon:
                    const Icon(
                  Icons.save_rounded,
                ),

                label:
                    const Text(
                  'Save Product',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   STOCK DIALOG
============================================================ */

Future<void> showStockDialog(
  BuildContext context,
  bool stockIn,
) async {

  final snapshot =
      await DatabaseService
          .productCollection
          .get();

  if (!context.mounted) return;

  final products =
      snapshot.docs
          .map(Product.fromDoc)
          .toList();

  if (products.isEmpty) {

    showSimpleMessage(
      context,
      'Add a product first',
    );

    return;
  }

  Product selected =
      products.first;

  final quantity =
      TextEditingController(
    text: '1',
  );

  await showDialog(

    context: context,

    builder: (_) => StatefulBuilder(

      builder:
          (context, setState) {

        return AlertDialog(

          title:
              Text(
            stockIn
                ? 'Stock In'
                : 'Stock Out',
          ),

          content:
              Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              DropdownButtonFormField<Product>(

                value:
                    selected,

                isExpanded:
                    true,

                items:
                    products.map(
                  (product) {

                    return DropdownMenuItem(
                      value:
                          product,

                      child:
                          Text(
                        product.name,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),

                onChanged:
                    (product) {

                  if (product == null)
                    return;

                  setState(() {
                    selected =
                        product;
                  });
                },

                decoration:
                    const InputDecoration(
                  labelText:
                      'Product',
                ),
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
                ),
              ),
            ],
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

                final amount =
                    int.tryParse(
                          quantity.text,
                        ) ??
                        0;

                if (amount <= 0) {

                  showSimpleMessage(
                    context,
                    'Enter valid quantity',
                  );

                  return;
                }

                if (!stockIn &&
                    amount >
                        selected.stock) {

                  showSimpleMessage(
                    context,
                    'Not enough stock',
                  );

                  return;
                }

                try {

                  await DatabaseService
                      .changeStock(
                    selected.id,
                    stockIn
                        ? amount
                        : -amount,
                  );

                  if (context.mounted) {

                    Navigator.pop(
                      context,
                    );

                    showSimpleMessage(
                      context,
                      stockIn
                          ? 'Stock added successfully'
                          : 'Stock removed successfully',
                    );
                  }

                } catch (e) {

                  if (context.mounted) {

                    showSimpleMessage(
                      context,
                      'Error: $e',
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
    ),
  );

  quantity.dispose();
}

/* ============================================================
   SALE DIALOG
============================================================ */

Future<void> showSaleDialog(
  BuildContext context,
) async {

  final snapshot =
      await DatabaseService
          .productCollection
          .get();

  if (!context.mounted) return;

  final products =
      snapshot.docs
          .map(Product.fromDoc)
          .toList();

  if (products.isEmpty) {

    showSimpleMessage(
      context,
      'Add a product first',
    );

    return;
  }

  Product selected =
      products.first;

  final customer =
      TextEditingController();

  final quantity =
      TextEditingController(
    text: '1',
  );

  await showDialog(

    context: context,

    builder: (_) => StatefulBuilder(

      builder:
          (context, setState) {

        final qty =
            int.tryParse(
                  quantity.text,
                ) ??
                1;

        final total =
            selected.selling * qty;

        return AlertDialog(

          title:
              const Text(
            'New Sale',
          ),

          content:
              SingleChildScrollView(

            child:
                Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      customer,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Customer name',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                DropdownButtonFormField<Product>(

                  value:
                      selected,

                  isExpanded:
                      true,

                  items:
                      products.map(
                    (product) {

                      return DropdownMenuItem(
                        value:
                            product,

                        child:
                            Text(
                          product.name,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),

                  onChanged:
                      (product) {

                    if (product == null)
                      return;

                    setState(() {
                      selected =
                          product;
                    });
                  },

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Product',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextField(
                  controller:
                      quantity,

                  keyboardType:
                      TextInputType.number,

                  onChanged:
                      (_) => setState(
                    () {},
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Quantity',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Align(
                  alignment:
                      Alignment.centerLeft,

                  child:
                      Text(
                    'Total: ₹${total.toStringAsFixed(0)}',

                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ],
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
                          quantity.text,
                        ) ??
                        0;

                if (qty <= 0) {

                  showSimpleMessage(
                    context,
                    'Enter valid quantity',
                  );

                  return;
                }

                try {

                  await DatabaseService
                      .createSale(
                    product:
                        selected,
                    customer:
                        customer.text,
                    quantity:
                        qty,
                  );

                  if (context.mounted) {

                    Navigator.pop(
                      context,
                    );

                    showSimpleMessage(
                      context,
                      'Sale completed successfully',
                    );
                  }

                } catch (e) {

                  if (context.mounted) {

                    showSimpleMessage(
                      context,
                      e.toString()
                          .replaceFirst(
                        'Exception: ',
                        '',
                      ),
                    );
                  }
                }
              },

              child:
                  const Text(
                'Complete Sale',
              ),
            ),
          ],
        );
      },
    ),
  );

  customer.dispose();
  quantity.dispose();
}

/* ============================================================
   INVOICE
============================================================ */

void showInvoiceDialog(
  BuildContext context,
) {

  showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title:
          const Text(
        'Invoice',
      ),

      content:
          const Text(
        'Invoice module is ready. Sales are saved in Firebase and can be used to generate invoices.',
      ),

      actions: [

        FilledButton(
          onPressed:
              () =>
                  Navigator.pop(
            context,
          ),

          child:
              const Text(
            'OK',
          ),
        ),
      ],
    ),
  );
}

/* ============================================================
   SETTINGS
============================================================ */

void showSettingsDialog(
  BuildContext context,
) {

  showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title:
          const Text(
        'Business Settings',
      ),

      content:
          const Column(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          ListTile(
            leading:
                Icon(
              Icons.store,
            ),

            title:
                Text(
              'RAJA ENTERPRISE',
            ),

            subtitle:
                Text(
              'Stock Management',
            ),
          ),

          ListTile(
            leading:
                Icon(
              Icons.currency_rupee,
            ),

            title:
                Text(
              'Currency',
            ),

            subtitle:
                Text(
              'Indian Rupee (₹)',
            ),
          ),
        ],
      ),

      actions: [

        FilledButton(
          onPressed:
              () =>
                  Navigator.pop(
            context,
          ),

          child:
              const Text(
            'Close',
          ),
        ),
      ],
    ),
  );
}

/* ============================================================
   UI COMPONENTS
============================================================ */

class PageHeader
    extends StatelessWidget {

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

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style:
              const TextStyle(
            fontSize: 30,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          subtitle,

          style:
              const TextStyle(
            color:
                Colors.white60,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   METRIC CARD
============================================================ */

class MetricCard
    extends StatelessWidget {

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

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(

        color:
            card,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              Colors.white.withOpacity(
            .07,
          ),
        ),
      ),

      child: Row(

        children: [

          Container(

            width: 46,
            height: 46,

            decoration:
                BoxDecoration(

              color:
                  purpleDark,

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child:
                Icon(
              icon,
              color:
                  purple,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                FittedBox(

                  fit:
                      BoxFit.scaleDown,

                  alignment:
                      Alignment.centerLeft,

                  child:
                      Text(
                    value,

                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  label,

                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
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

/* ============================================================
   PRODUCT CARD
============================================================ */

class ProductCard
    extends StatelessWidget {

  final Product product;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final low =
        product.stock <=
            product.minStock;

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(
        14,
      ),

      decoration:
          BoxDecoration(

        color:
            card,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              Colors.white.withOpacity(
            .06,
          ),
        ),
      ),

      child: Row(

        children: [

          Container(

            width: 54,
            height: 54,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                0xFF2B1D38,
              ),

              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child:
                const Icon(
              Icons.format_paint_rounded,
              color:
                  purple,
            ),
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
                  product.name,

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '${product.category} • ${product.size}',

                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Sell ₹${product.selling.toStringAsFixed(0)}',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Column(

            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [

              Text(
                '${product.stock} pcs',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                low
                    ? 'Low Stock'
                    : 'In Stock',

                style:
                    TextStyle(
                  color: low
                      ? Colors.orangeAccent
                      : Colors.greenAccent,

                  fontSize: 12,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              IconButton(
                onPressed:
                    onDelete,

                icon:
                    const Icon(
                  Icons.delete_outline,
                  size: 21,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   STOCK CARD
============================================================ */

class StockCard
    extends StatelessWidget {

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

    final low =
        product.stock <=
            product.minStock;

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
            card,

        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),

      child: Row(

        children: [

          Container(

            width: 52,
            height: 52,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                0xFF2B1D38,
              ),

              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child:
                const Icon(
              Icons.format_paint_rounded,
              color:
                  purple,
            ),
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
                  product.name,

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${product.category} • ${product.size}',

                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
                  ),
                ),

                if (low)

                  const Text(
                    'LOW STOCK',

                    style:
                        TextStyle(
                      color:
                          Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                product.stock > 0
                    ? onMinus
                    : null,

            icon:
                const Icon(
              Icons.remove_circle_outline,
              size: 29,
            ),
          ),

          SizedBox(

            width: 34,

            child: Center(

              child:
                  Text(
                '${product.stock}',

                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          IconButton(

            onPressed:
                onPlus,

            icon:
                const Icon(
              Icons.add_circle_outline,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   SALE CARD
============================================================ */

class SaleCard
    extends StatelessWidget {

  final Sale sale;

  const SaleCard({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(

        color:
            card,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(

        children: [

          const CircleAvatar(

            backgroundColor:
                purpleDark,

            child:
                Icon(
              Icons.receipt_long,
              color:
                  purple,
            ),
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
                  sale.customer,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${sale.product} × ${sale.quantity}',

                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${sale.amount.toStringAsFixed(0)}',

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   MORE TILE
============================================================ */

class MoreTile
    extends StatelessWidget {

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

      color:
          card,

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child:
          ListTile(

        onTap:
            onTap,

        leading:
            Container(

          width: 46,
          height: 46,

          decoration:
              BoxDecoration(

            color:
                purpleDark,

            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          child:
              Icon(
            icon,
            color:
                purple,
          ),
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
        ),

        trailing:
            const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}

/* ============================================================
   ACTION BUTTON
============================================================ */

class ActionButton
    extends StatelessWidget {

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

      onPressed:
          onPressed,

      icon:
          Icon(
        icon,
        size: 18,
      ),

      label:
          Text(
        label,
      ),
    );
  }
}

/* ============================================================
   FIELD
============================================================ */

class AppField
    extends StatelessWidget {

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

      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: TextField(

        controller:
            controller,

        keyboardType:
            number
                ? const TextInputType
                    .numberWithOptions(
                    decimal: true,
                  )
                : TextInputType.text,

        decoration:
            InputDecoration(

          labelText:
              label,

          filled:
              true,

          fillColor:
              const Color(
            0xFF0D0F15,
          ),

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   SHEET HANDLE
============================================================ */

class SheetHandle
    extends StatelessWidget {

  const SheetHandle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Container(

        width: 42,
        height: 5,

        decoration:
            BoxDecoration(

          color:
              Colors.white24,

          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   LOADING
============================================================ */

class LoadingView
    extends StatelessWidget {

  const LoadingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return const Center(
      child:
          CircularProgressIndicator(),
    );
  }
}

/* ============================================================
   ERROR
============================================================ */

class ErrorView
    extends StatelessWidget {

  final String message;

  const ErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child:
          Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child:
            Text(
          'Firebase Error:\n\n$message',

          textAlign:
              TextAlign.center,
        ),
      ),
    );
  }
}

/* ============================================================
   SNACKBAR
============================================================ */

void showSimpleMessage(
  BuildContext context,
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
