import 'package:app_libros/modelos/libro.dart';
import 'package:equatable/equatable.dart';

class InfoPrestacion with EquatableMixin { 
  final String isbn; 
  final String? prestadoA; 
  final String? prestadoDe; 
  final String? fechaPrestacion; 
  final String? fechaRegreso; 
  
  InfoPrestacion({ required this.isbn, this.prestadoA, this.prestadoDe, this.fechaPrestacion, this.fechaRegreso, }); 
  
  factory InfoPrestacion.fromLibro(Libro libro) { 
    return InfoPrestacion(
       isbn: libro.isbn, 
       prestadoA: libro.prestadoA, 
       prestadoDe: libro.prestadoDe, 
       fechaPrestacion: libro.fechaPrestacion, 
       fechaRegreso: libro.fechaRegreso, );
 } 
 
 @override List<Object?> get props => [isbn, prestadoA, prestadoDe, fechaPrestacion, fechaRegreso]; }