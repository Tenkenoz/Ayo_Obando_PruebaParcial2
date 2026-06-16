import 'package:flutter/material.dart';

class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.security, size: 48, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'SeguroApp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Administracion de Polizas de Seguro',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              Text(
                'CRUD completo consumiendo API REST con arquitectura MVVM + Provider',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildItem(context, Icons.assignment, 'Polizas', 'Ver, editar y eliminar polizas registradas'),
                      const Divider(),
                      _buildItem(context, Icons.add_circle_outline, 'Registrar', 'Crear una nueva poliza de seguro'),
                      const Divider(),
                      _buildItem(context, Icons.api, 'API REST', 'FastAPI + PostgreSQL en Docker'),
                      const Divider(),
                      _buildItem(context, Icons.architecture, 'Arquitectura', 'MVVM + Provider'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
    );
  }
}
