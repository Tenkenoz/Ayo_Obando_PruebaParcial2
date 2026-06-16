import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poliza.dart';
import '../viewmodels/poliza_viewmodel.dart';

class FormularioPolizaPage extends StatefulWidget {
  final Poliza? poliza;

  const FormularioPolizaPage({super.key, this.poliza});

  @override
  State<FormularioPolizaPage> createState() => _FormularioPolizaPageState();
}

class _FormularioPolizaPageState extends State<FormularioPolizaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _clienteCtrl;
  late final TextEditingController _fechaInicioCtrl;
  late final TextEditingController _fechaVencimientoCtrl;
  late final TextEditingController _valorCtrl;

  final _tiposSeguro = [
    'Seguro de Vida',
    'Seguro de Vehiculo',
    'Seguro de Hogar',
    'Seguro de Salud',
  ];
  String? _tipoSeguroSeleccionado;

  bool _guardando = false;

  bool get _esEditar => widget.poliza != null;

  @override
  void initState() {
    super.initState();
    final p = widget.poliza;
    _codigoCtrl = TextEditingController(text: p?.codigo ?? '');
    _clienteCtrl = TextEditingController(text: p?.cliente ?? '');
    _tipoSeguroSeleccionado = p?.tipoSeguro;
    _fechaInicioCtrl = TextEditingController(text: _formatearFecha(p?.fechaInicio));
    _fechaVencimientoCtrl = TextEditingController(text: _formatearFecha(p?.fechaVencimiento));
    _valorCtrl = TextEditingController(text: p?.valorAsegurado.toString() ?? '');
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _clienteCtrl.dispose();
    _fechaInicioCtrl.dispose();
    _fechaVencimientoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  String _formatearFecha(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _aISO(String fechaFormateada) {
    final parts = fechaFormateada.split('/');
    if (parts.length != 3) return fechaFormateada;
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}T00:00:00';
  }

  DateTime? _parseFechaVisual(String visual) {
    try {
      final iso = _aISO(visual);
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  Future<void> _seleccionarFecha(TextEditingController ctrl) async {
    DateTime? initial;
    try {
      final existing = DateTime.parse(_aISO(ctrl.text));
      initial = existing;
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ctrl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _limpiarFormulario() {
    _codigoCtrl.clear();
    _clienteCtrl.clear();
    _tipoSeguroSeleccionado = null;
    _fechaInicioCtrl.clear();
    _fechaVencimientoCtrl.clear();
    _valorCtrl.clear();
    _formKey.currentState?.reset();
    setState(() {});
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoSeguroSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de seguro'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final fechaInicioDT = _parseFechaVisual(_fechaInicioCtrl.text.trim());
    final fechaVencimientoDT = _parseFechaVisual(_fechaVencimientoCtrl.text.trim());

    if (fechaInicioDT != null && fechaVencimientoDT != null) {
      if (fechaVencimientoDT.isBefore(fechaInicioDT) || fechaVencimientoDT.isAtSameMomentAs(fechaInicioDT)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha de vencimiento debe ser posterior a la fecha de inicio'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _guardando = true);

    final poliza = Poliza(
      id: widget.poliza?.id,
      codigo: _codigoCtrl.text.trim(),
      cliente: _clienteCtrl.text.trim(),
      tipoSeguro: _tipoSeguroSeleccionado!,
      fechaInicio: _aISO(_fechaInicioCtrl.text.trim()),
      fechaVencimiento: _aISO(_fechaVencimientoCtrl.text.trim()),
      valorAsegurado: double.parse(_valorCtrl.text.trim()),
    );

    final vm = Provider.of<PolizaViewModel>(context, listen: false);
    bool ok;

    if (_esEditar) {
      ok = await vm.actualizarPoliza(poliza.id!, poliza);
    } else {
      ok = await vm.crearPoliza(poliza);
    }

    if (mounted) {
      setState(() => _guardando = false);

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.ultimoError ?? 'Error al guardar'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poliza guardada correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (_esEditar) {
        Navigator.pop(context);
      } else {
        _limpiarFormulario();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEditar ? 'Editar Poliza' : 'Nueva Poliza',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Container(
        color: colorScheme.surfaceContainerLowest,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextField(_codigoCtrl, 'Codigo', 'Ej: POL-2025-001', Icons.qr_code, false, 30),
              const SizedBox(height: 12),
              _buildTextField(_clienteCtrl, 'Cliente', 'Nombre del cliente', Icons.person, false, 150),
              const SizedBox(height: 12),
              _buildComboBox(),
              const SizedBox(height: 12),
              _buildFechaField(_fechaInicioCtrl, 'Fecha de Inicio', Icons.calendar_today),
              const SizedBox(height: 12),
              _buildFechaField(_fechaVencimientoCtrl, 'Fecha de Vencimiento', Icons.event_busy),
              const SizedBox(height: 12),
              _buildTextField(_valorCtrl, 'Valor Asegurado', 'Ej: 50000.00', Icons.attach_money, true, null),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _esEditar ? 'Actualizar Poliza' : 'Registrar Poliza',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, IconData icon, bool isNumber, int? maxLength) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: ctrl,
      maxLength: maxLength,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        if (isNumber) {
          final num = double.tryParse(v.trim());
          if (num == null) return 'Valor invalido';
          if (num <= 0) return 'Debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  Widget _buildComboBox() {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: _tiposSeguro.contains(_tipoSeguroSeleccionado) ? _tipoSeguroSeleccionado : null,
      decoration: InputDecoration(
        labelText: 'Tipo de Seguro',
        prefixIcon: Icon(Icons.category, color: colorScheme.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      items: _tiposSeguro.map((tipo) {
        return DropdownMenuItem(value: tipo, child: Text(tipo));
      }).toList(),
      onChanged: (value) {
        setState(() => _tipoSeguroSeleccionado = value);
      },
      validator: (value) => value == null ? 'Selecciona un tipo de seguro' : null,
    );
  }

  Widget _buildFechaField(TextEditingController ctrl, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: () => _seleccionarFecha(ctrl),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'DD/MM/AAAA',
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        if (v.trim().length < 10) return 'Formato: DD/MM/AAAA';
        final parts = v.trim().split('/');
        if (parts.length != 3) return 'Formato invalido';
        return null;
      },
    );
  }
}
