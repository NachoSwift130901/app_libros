import 'package:equatable/equatable.dart';

class InfoPrestacion with EquatableMixin {
  String? prestadoDe;
  String? prestadoA;
  DateTime fechaPrestacion;
  DateTime? fechaRegreso;

  InfoPrestacion({
    required this.prestadoDe,
    required this.prestadoA,
    required this.fechaPrestacion,
  });
  
  @override

  List<Object?> get props => [];
}