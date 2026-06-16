class Poliza {
  final int? id;
  final String codigo;
  final String cliente;
  final String tipoSeguro;
  final String fechaInicio;
  final String fechaVencimiento;
  final double valorAsegurado;

  Poliza({
    this.id,
    required this.codigo,
    required this.cliente,
    required this.tipoSeguro,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.valorAsegurado,
  });

  factory Poliza.fromJson(Map<String, dynamic> json) {
    return Poliza(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      codigo: json['codigo']?.toString() ?? '',
      cliente: json['cliente']?.toString() ?? '',
      tipoSeguro: json['tipo_seguro']?.toString() ?? '',
      fechaInicio: json['fecha_inicio']?.toString() ?? '',
      fechaVencimiento: json['fecha_vencimiento']?.toString() ?? '',
      valorAsegurado: double.tryParse(json['valor_asegurado']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'cliente': cliente,
      'tipo_seguro': tipoSeguro,
      'fecha_inicio': fechaInicio,
      'fecha_vencimiento': fechaVencimiento,
      'valor_asegurado': valorAsegurado,
    };
  }
}
