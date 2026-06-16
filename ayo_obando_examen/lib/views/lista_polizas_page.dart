import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/poliza_viewmodel.dart';
import '../models/poliza.dart';
import 'formulario_poliza_page.dart';

class ListaPolizasPage extends StatefulWidget {
  const ListaPolizasPage({super.key});

  @override
  State<ListaPolizasPage> createState() => _ListaPolizasPageState();
}

class _ListaPolizasPageState extends State<ListaPolizasPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<PolizaViewModel>(context, listen: false).cargarPolizas();
      }
    });
  }

  Future<void> _confirmarEliminar(Poliza poliza) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Poliza'),
        content: Text('Seguro que deseas eliminar la poliza ${poliza.codigo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final vm = Provider.of<PolizaViewModel>(context, listen: false);
      final ok = await vm.eliminarPoliza(poliza.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Poliza eliminada' : (vm.ultimoError ?? 'Error al eliminar')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? null : Colors.red,
        ),
      );
    }
  }

  IconData _iconoTipo(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('vida')) return Icons.favorite;
    if (t.contains('vehiculo') || t.contains('auto')) return Icons.directions_car;
    if (t.contains('hogar') || t.contains('casa')) return Icons.home;
    if (t.contains('salud')) return Icons.local_hospital;
    return Icons.shield;
  }

  Color _colorTipo(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('vida')) return Colors.red;
    if (t.contains('vehiculo') || t.contains('auto')) return Colors.orange;
    if (t.contains('hogar') || t.contains('casa')) return Colors.green;
    if (t.contains('salud')) return Colors.teal;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PolizaViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (vm.loading && vm.polizas.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (vm.errorMessage != null && vm.polizas.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(vm.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => vm.cargarPolizas(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (vm.polizas.isEmpty && !vm.loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment, size: 64, color: colorScheme.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text('No hay polizas registradas',
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () => vm.cargarPolizas(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: vm.polizas.length,
          itemBuilder: (_, index) {
            final poliza = vm.polizas[index];
            final colorTipo = _colorTipo(poliza.tipoSeguro);
            final eliminando = poliza.id != null && vm.isEliminando(poliza.id!);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                elevation: 1.5,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: eliminando
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormularioPolizaPage(poliza: poliza),
                            ),
                          );
                          if (mounted) vm.cargarPolizas();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(color: colorTipo, width: 5),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorTipo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_iconoTipo(poliza.tipoSeguro), color: colorTipo, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poliza.cliente,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                poliza.tipoSeguro,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                poliza.codigo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${poliza.valorAsegurado.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: eliminando ? null : () => _confirmarEliminar(poliza),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: eliminando
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                                      )
                                    : const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
