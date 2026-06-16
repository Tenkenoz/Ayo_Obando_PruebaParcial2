import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/poliza_viewmodel.dart';
import 'views/inicio_page.dart';
import 'views/lista_polizas_page.dart';
import 'views/registrar_poliza_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PolizaViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poliza360',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 1;

  final _screens = const [
    ListaPolizasPage(),
    InicioPage(),
    RegistrarPolizaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (i) {
            setState(() => _index = i);
            if (i == 0) {
              Provider.of<PolizaViewModel>(context, listen: false).cargarPolizas();
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment, size: 24),
              label: 'Polizas',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _index == 1 ? Colors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home,
                  size: 26,
                  color: _index == 1 ? Colors.white : Colors.grey,
                ),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle, size: 24),
              label: 'Registrar',
            ),
          ],
        ),
      ),
    );
  }
}
