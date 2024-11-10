import 'package:app_libros/blocs/bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:app_libros/modelos/Libro.dart';
import 'package:bloc_test/bloc_test.dart';


void main() {
  blocTest<AppBloc, AppEstado>(
    'Se inicializa',
    build: () => AppBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () =>  <AppEstado>[Operacional(listaLibros: [])],
  );
}