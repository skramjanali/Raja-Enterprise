import 'package:flutter/material.dart';

void main() => runApp(const RajaEnterpriseApp());

class Product {
  String name, category, size;
  double purchase, selling;
  int stock, minStock;
  Product({required this.name, required this.category, required this.size, required this.purchase, required this.selling, required this.stock, required this.minStock});
}

final products = <Product>[
  Product(name: 'WeatherCoat Long Life 10', category: 'Exterior', size: '20 L', purchase: 5200, selling: 5850, stock: 11, minStock: 5),
  Product(name: 'Easy Clean', category: 'Interior', size: '20 L', purchase: 4100, selling: 4650, stock: 7, minStock: 5),
  Product(name: 'Wall Primer', category: 'Primer', size: '20 L', purchase: 2500, selling: 2850, stock: 3, minStock: 5),
  Product(name: 'Wall Putty', category: 'Putty', size: '40 Kg', purchase: 1450, selling: 1650, stock: 18, minStock: 6),
];

class RajaEnterpriseApp extends StatelessWidget {
  const RajaEnterpriseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RAJA ENTERPRISE',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF07080C), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB56CFF), brightness: Brightness.dark)),
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget { const MainShell({super.key}); @override State<MainShell> createState() => _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [DashboardPage(onChanged: () => setState(() {})), ProductsPage(onChanged: () => setState(() {})), StockPage(onChanged: () => setState(() {}))];
    return LayoutBuilder(builder: (context, c) {
      final mobile = c.maxWidth < 700;
      return Scaffold(
        body: SafeArea(child: mobile ? pages[index] : Row(children: [SideBar(index: index, onSelect: (i) => setState(() => index = i)), Expanded(child: pages[index])])),
        bottomNavigationBar: mobile ? NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), backgroundColor: const Color(0xFF11131A), indicatorColor: const Color(0xFF5A347A), destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.swap_vert_outlined), selectedIcon: Icon(Icons.swap_vert), label: 'Stock'),
        ]) : null,
      );
    });
  }
}

class SideBar extends StatelessWidget {
  final int index; final ValueChanged<int> onSelect;
  const SideBar({super.key, required this.index, required this.onSelect});
  @override Widget build(BuildContext context) => Container(width: 112, color: const Color(0xFF101117), child: Column(children: [
    const SizedBox(height: 18), Container(width: 54, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const LinearGradient(colors: [Color(0xFFB66CFF), Color(0xFF6844D8)])), child: const Icon(Icons.inventory_2_rounded)),
    const SizedBox(height: 8), const Text('RAJA', style: TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 24),
    _item(Icons.dashboard_rounded, 'Home', 0), _item(Icons.inventory_2_rounded, 'Products', 1), _item(Icons.swap_vert_rounded, 'Stock', 2), const Spacer(), const Padding(padding: EdgeInsets.only(bottom: 20), child: Icon(Icons.settings_outlined, color: Colors.white54))
  ]));
  Widget _item(IconData icon, String label, int i) { final selected = index == i; return GestureDetector(onTap: () => onSelect(i), child: Container(margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: selected ? const Color(0xFF4C2B61) : Colors.transparent, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(icon, color: selected ? const Color(0xFFD39AFF) : Colors.white70), const SizedBox(height: 5), Text(label, style: TextStyle(fontSize: 12, color: selected ? const Color(0xFFD39AFF) : Colors.white70))]))); }
}

class DashboardPage extends StatelessWidget {
  final VoidCallback onChanged; const DashboardPage({super.key, required this.onChanged});
  @override Widget build(BuildContext context) {
    final low = products.where((p) => p.stock <= p.minStock).length; final value = products.fold<double>(0, (s, p) => s + p.purchase * p.stock);
    return CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(18,18,18,10), sliver: SliverToBoxAdapter(child: Row(children: [const Expanded(child: Header(title: 'Good morning 👋', subtitle: 'RAJA ENTERPRISE • Stock Management')), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))]))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal:18), sliver: SliverGrid(delegate: SliverChildListDelegate([
        MetricCard(icon: Icons.inventory_2_rounded, value: '${products.length}', label: 'Total Products'), MetricCard(icon: Icons.account_balance_wallet_rounded, value: '₹${value.toStringAsFixed(0)}', label: 'Stock Value'), MetricCard(icon: Icons.warning_amber_rounded, value: '$low', label: 'Low Stock'), const MetricCard(icon: Icons.shopping_cart_rounded, value: '₹0', label: "Today's Sales")
      ]), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 360, mainAxisExtent: 138, crossAxisSpacing: 12, mainAxisSpacing: 12))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(18,20,18,30), sliver: SliverToBoxAdapter(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF28153D), Color(0xFF12141B)]), border: Border.all(color: const Color(0xFF9D63FF).withOpacity(.25))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Inventory Overview', style: TextStyle(fontSize:22,fontWeight:FontWeight.w900)), const SizedBox(height:7), Text('Quick view of your paint stock and low-stock items.', style: TextStyle(color: Colors.white.withOpacity(.62))), const SizedBox(height:18), Wrap(spacing:10,runSpacing:10,children:[ActionButton(icon:Icons.inventory_2,label:'Products'),ActionButton(icon:Icons.add_box,label:'Stock In'),ActionButton(icon:Icons.remove_circle,label:'Stock Out')]), const SizedBox(height:22), const Text('Low Stock Alert', style: TextStyle(fontSize:18,fontWeight:FontWeight.w800)), ...products.where((p)=>p.stock<=p.minStock).map((p)=>CompactProduct(product:p))
      ]))))
    ]);
  }
}

class ProductsPage extends StatefulWidget { final VoidCallback onChanged; const ProductsPage({super.key,required this.onChanged}); @override State<ProductsPage> createState()=>_ProductsPageState(); }
class _ProductsPageState extends State<ProductsPage> {
  String query='';
  Future<void> addProduct() async { final p=await showModalBottomSheet<Product>(context:context,isScrollControlled:true,backgroundColor:const Color(0xFF12141B),builder:(_)=>const AddProductSheet()); if(p!=null){products.add(p);setState((){});widget.onChanged();} }
  @override Widget build(BuildContext context){ final list=products.where((p)=>p.name.toLowerCase().contains(query.toLowerCase())).toList(); return Stack(children:[CustomScrollView(slivers:[SliverPadding(padding:const EdgeInsets.fromLTRB(18,18,18,10),sliver:SliverToBoxAdapter(child:const Header(title:'Products & Stock',subtitle:'Manage your Berger Paints inventory'))),SliverPadding(padding:const EdgeInsets.symmetric(horizontal:18,vertical:6),sliver:SliverToBoxAdapter(child:TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(hintText:'Search products...',prefixIcon:const Icon(Icons.search),filled:true,fillColor:const Color(0xFF11141B),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(18)),borderSide:BorderSide.none))))),SliverPadding(padding:const EdgeInsets.fromLTRB(18,8,18,100),sliver:SliverList(delegate:SliverChildBuilderDelegate((_,i)=>ProductCard(product:list[i]),childCount:list.length))) ]),Positioned(right:18,bottom:18,child:FloatingActionButton.extended(onPressed:addProduct,icon:const Icon(Icons.add),label:const Text('Add Product'))]); }
}

class StockPage extends StatefulWidget { final VoidCallback onChanged; const StockPage({super.key,required this.onChanged}); @override State<StockPage> createState()=>_StockPageState(); }
class _StockPageState extends State<StockPage>{ void change(Product p,int d){setState(()=>p.stock=(p.stock+d).clamp(0,999999));widget.onChanged();} @override Widget build(BuildContext context)=>CustomScrollView(slivers:[SliverPadding(padding:const EdgeInsets.fromLTRB(18,18,18,12),sliver:SliverToBoxAdapter(child:const Header(title:'Stock Control',subtitle:'Quickly add or remove inventory'))),SliverPadding(padding:const EdgeInsets.fromLTRB(18,0,18,30),sliver:SliverList(delegate:SliverChildBuilderDelegate((_,i){final p=products[i];return StockCard(product:p,onMinus:()=>change(p,-1),onPlus:()=>change(p,1));},childCount:products.length))) ]); }

class AddProductSheet extends StatefulWidget { const AddProductSheet({super.key}); @override State<AddProductSheet> createState()=>_AddProductSheetState(); }
class _AddProductSheetState extends State<AddProductSheet>{ final name=TextEditingController(),category=TextEditingController(),size=TextEditingController(),purchase=TextEditingController(),selling=TextEditingController(),stock=TextEditingController(),minimum=TextEditingController(text:'5'); @override void dispose(){for(final c in[name,category,size,purchase,selling,stock,minimum])c.dispose();super.dispose();} @override Widget build(BuildContext context){final bottom=MediaQuery.viewInsetsOf(context).bottom;return Padding(padding:EdgeInsets.fromLTRB(18,18,18,bottom+18),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Center(child:Container(width:42,height:5,decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(10)))),const SizedBox(height:18),const Text('Add New Product',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:18),Field(controller:name,label:'Product name'),Field(controller:category,label:'Category'),Field(controller:size,label:'Size'),Row(children:[Expanded(child:Field(controller:purchase,label:'Purchase price',number:true)),const SizedBox(width:10),Expanded(child:Field(controller:selling,label:'Selling price',number:true))]),Row(children:[Expanded(child:Field(controller:stock,label:'Opening stock',number:true)),const SizedBox(width:10),Expanded(child:Field(controller:minimum,label:'Minimum stock',number:true))]),const SizedBox(height:8),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:(){Navigator.pop(context,Product(name:name.text.trim().isEmpty?'New Product':name.text.trim(),category:category.text.trim().isEmpty?'General':category.text.trim(),size:size.text.trim().isEmpty?'-':size.text.trim(),purchase:double.tryParse(purchase.text)??0,selling:double.tryParse(selling.text)??0,stock:int.tryParse(stock.text)??0,minStock:int.tryParse(minimum.text)??5));},icon:const Icon(Icons.save_rounded),label:const Text('Save Product')))])));}}

class Field extends StatelessWidget{final TextEditingController controller;final String label;final bool number;const Field({super.key,required this.controller,required this.label,this.number=false});@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:controller,keyboardType:number?TextInputType.number:TextInputType.text,decoration:InputDecoration(labelText:label,filled:true,fillColor:const Color(0xFF0D0F15),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none))));}
class Header extends StatelessWidget{final String title,subtitle;const Header({super.key,required this.title,required this.subtitle});@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900,height:1.05)),const SizedBox(height:7),Text(subtitle,style:TextStyle(color:Colors.white.withOpacity(.55),fontSize:15))]);}
class MetricCard extends StatelessWidget{final IconData icon;final String value,label;const MetricCard({super.key,required this.icon,required this.value,required this.label});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFF11141B),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white.withOpacity(.07))),child:Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:const Color(0xFF3B244B),borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:const Color(0xFFD18CFF))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,child:Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))),const SizedBox(height:4),Text(label,style:TextStyle(color:Colors.white.withOpacity(.55)))]))]));}
class ProductCard extends StatelessWidget{final Product product;const ProductCard({super.key,required this.product});@override Widget build(BuildContext context){final low=product.stock<=product.minStock;return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFF11141B),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white.withOpacity(.06))),child:Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:const Color(0xFF2B1D38),borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.format_paint_rounded,color:Color(0xFFD18CFF))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(product.name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text('${product.category} • ${product.size}',style:TextStyle(color:Colors.white.withOpacity(.55))),const SizedBox(height:4),Text('Sell ₹${product.selling.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.w700))])),const SizedBox(width:8),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text('${product.stock} pcs',style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(low?'Low Stock':'In Stock',style:TextStyle(color:low?Colors.orangeAccent:Colors.greenAccent,fontSize:12,fontWeight:FontWeight.w700))]) ]);}}
class StockCard extends StatelessWidget{final Product product;final VoidCallback onMinus,onPlus;const StockCard({super.key,required this.product,required this.onMinus,required this.onPlus});@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFF11141B),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white.withOpacity(.06))),child:Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:const Color(0xFF2B1D38),borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.format_paint_rounded,color:Color(0xFFD18CFF))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(product.name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text('${product.category} • ${product.size}',style:TextStyle(color:Colors.white.withOpacity(.55)))])),IconButton(onPressed:onMinus,icon:const Icon(Icons.remove_circle_outline,size:29)),SizedBox(width:34,child:Center(child:Text('${product.stock}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)))),IconButton(onPressed:onPlus,icon:const Icon(Icons.add_circle_outline,size:29))]));}
class CompactProduct extends StatelessWidget{final Product product;const CompactProduct({super.key,required this.product});@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(top:8),child:Row(children:[const Icon(Icons.warning_amber_rounded,color:Colors.orangeAccent,size:20),const SizedBox(width:8),Expanded(child:Text(product.name,maxLines:1,overflow:TextOverflow.ellipsis)),Text('${product.stock} left',style:const TextStyle(color:Colors.orangeAccent,fontWeight:FontWeight.bold))]));}
class ActionButton extends StatelessWidget{final IconData icon;final String label;const ActionButton({super.key,required this.icon,required this.label});@override Widget build(BuildContext context)=>OutlinedButton.icon(onPressed:(){},icon:Icon(icon,size:18),label:Text(label));}
