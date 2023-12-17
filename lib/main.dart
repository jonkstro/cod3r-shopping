import 'package:flutter/material.dart';
import 'package:minha_loja/pages/product_detail_page.dart';
import 'package:minha_loja/pages/products_overview_page.dart';
import 'package:minha_loja/utils/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.purple,
          secondary: Colors.deepOrange,
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontFamily: 'LaTo', color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: ProductsOverviewPage(),
      // remover aquela lista de debug
      debugShowCheckedModeBanner: false,
      routes: {AppRoutes.PRODUCT_DETAIL: (context) => ProductDetailPage()},
    );
  }
}
