import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/poliza.dart';

class PolizaViewModel extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8000/polizas/';

  List<Poliza> _polizas = [];
  List<Poliza> get polizas => _polizas;

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _ultimoError;
  String? get ultimoError => _ultimoError;

  final Set<int> _idsEliminando = {};
  bool isEliminando(int id) => _idsEliminando.contains(id);

  Future<void> cargarPolizas() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await http.get(Uri.parse('$baseUrl?limit=10'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List polizasJson = data['polizas'];
        _polizas = polizasJson.map((e) => Poliza.fromJson(e)).toList();
      } else {
        _errorMessage = 'Error al cargar las polizas';
      }
    } catch (e) {
      _errorMessage = 'Error de conexion: $e';
    }

    _loading = false;
    notifyListeners();
  }

  String _leerError(http.Response resp) {
    try {
      final body = jsonDecode(resp.body);
      return body['detail']?.toString() ?? 'Error del servidor';
    } catch (_) {
      return 'Error del servidor (${resp.statusCode})';
    }
  }

  Future<bool> crearPoliza(Poliza poliza) async {
    _ultimoError = null;
    try {
      final resp = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(poliza.toJson()),
      );
      if (resp.statusCode == 201) {
        await cargarPolizas();
        return true;
      }
      _ultimoError = _leerError(resp);
      return false;
    } catch (e) {
      _ultimoError = 'Error de conexion: $e';
      return false;
    }
  }

  Future<bool> actualizarPoliza(int id, Poliza poliza) async {
    _ultimoError = null;
    try {
      final resp = await http.put(
        Uri.parse('$baseUrl$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(poliza.toJson()),
      );
      if (resp.statusCode == 200) {
        await cargarPolizas();
        return true;
      }
      _ultimoError = _leerError(resp);
      return false;
    } catch (e) {
      _ultimoError = 'Error de conexion: $e';
      return false;
    }
  }

  Future<bool> eliminarPoliza(int id) async {
    _ultimoError = null;
    _idsEliminando.add(id);
    notifyListeners();

    try {
      final resp = await http.delete(Uri.parse('$baseUrl$id'));
      if (resp.statusCode == 200) {
        await cargarPolizas();
        _idsEliminando.remove(id);
        notifyListeners();
        return true;
      }
      _ultimoError = _leerError(resp);
      _idsEliminando.remove(id);
      notifyListeners();
      return false;
    } catch (e) {
      _ultimoError = 'Error de conexion: $e';
      _idsEliminando.remove(id);
      notifyListeners();
      return false;
    }
  }
}
