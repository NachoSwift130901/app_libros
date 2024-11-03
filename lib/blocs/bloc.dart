import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';





// ----------- Estados --------------//

sealed class AppEstado with EquatableMixin {}

class Inicial extends AppEstado {

  @override
  List<Object?> get props => [];

}

class Operacional extends AppEstado {
  @override
  
  List<Object?> get props => throw UnimplementedError();

}