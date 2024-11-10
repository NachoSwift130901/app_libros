import 'package:app_libros/modelos/Libro.dart';
import 'package:equatable/equatable.dart';

class Autor with EquatableMixin {
  String nombre;
  List<Libro> libros;

  Autor({
    required this.nombre,
    required this.libros,
  });

  factory Autor.fromMap(Map<String, dynamic> map) {
    return Autor(
      nombre: map['nombre'],
      libros: map['libros'],
    );
  }
  
  @override
  
  List<Object?> get props => [nombre, libros];
}