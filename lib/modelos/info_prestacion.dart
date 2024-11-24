import 'package:equatable/equatable.dart';

class InfoPrestacion with EquatableMixin { 
  final String isbn; 
  final String? prestadoA; 
  final String? prestadoDe; 
  final String? fechaPrestacion; 
  final String? fechaRegreso; 
  
  InfoPrestacion({ required this.isbn, this.prestadoA, this.prestadoDe, this.fechaPrestacion, this.fechaRegreso, }); 
  
  factory InfoPrestacion.fromMap(Map<String, dynamic> map) { 
    return InfoPrestacion(
       isbn: map['isbn'], 
       prestadoA: map['prestadoA']??'', 
       prestadoDe: map['prestadoDe']??'', 
       fechaPrestacion: map['fechaPrestacion']??'', 
       fechaRegreso: map['fechaRegreso']??'',
       );
 } 
 
 @override List<Object?> get props => [isbn, prestadoA, prestadoDe, fechaPrestacion, fechaRegreso]; }