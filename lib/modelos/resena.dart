import 'package:equatable/equatable.dart';

class Resena with EquatableMixin{
  String isbnLibro;
  String rating;
  String comentario;

  Resena({
    required this.isbnLibro,
    required this.rating,
    required this.comentario,
  });
  
  @override
  List<Object?> get props => throw UnimplementedError();
}