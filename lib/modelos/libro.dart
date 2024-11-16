import 'package:equatable/equatable.dart';

class Libro with EquatableMixin {
   String isbn;
   String titulo;
   String autor;
   String genero;
   String portadaUrl;
   String fechaPublicacion;
   int? rating;
   String critica;
   bool esPrestado;
   String? prestadoA;
   String? prestadoDe;
   String? fechaPrestacion;
   String? fechaRegreso;
   String? fechaLectura;
   int totalPaginas;

   factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      isbn: map['isbn']??'', 
      titulo: map['titulo']??'', 
      autor: map['autor']??'', 
      genero: map['genero']??'',
      portadaUrl: map['portadaUrl']??'', 
      fechaPublicacion: map['fechaPublicacion']??'', 
      critica: map['critica']??'', 
      esPrestado: map['esPrestado']??false, 
      prestadoA: map['prestadoA']??'', 
      prestadoDe: map['prestadoDe']??'', 
      fechaPrestacion: map['fechaPrestacion']??'', 
      fechaRegreso: map['fechaRegreso']??'', 
      fechaLectura: map['fechaLectura']??'', 
      totalPaginas: map['totalPaginas']??0, 
      rating: map['rating']??0
      );
   }


   Libro({
    required this.isbn,
    required this.titulo,
    required this.autor,
    required this.genero,
    required this.portadaUrl,
    required this.fechaPublicacion,
    required this.critica,
    required this.esPrestado,
    required this.prestadoA,
    required this.prestadoDe,
    required this.fechaPrestacion,
    required this.fechaRegreso,
    required this.fechaLectura,
    required this.totalPaginas,
    required this.rating,

   });
   
     @override
     List<Object?> get props => [isbn, titulo, autor, genero, portadaUrl, fechaPublicacion, rating, critica, esPrestado, prestadoA, prestadoDe, fechaPrestacion, fechaRegreso, fechaLectura, totalPaginas];
   
   
}

