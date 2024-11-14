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

  blocTest<AppBloc, AppEstado>(
     'Agregar libro', 
     build: () => AppBloc(), 
     act: (bloc) => bloc.add(AgregarLibro( isbn: '1234567890', titulo: 'Título del libro', autor: 'Autor del libro', genero: 'Género', portadaUrl: 'URL de la portada', fechaPublicacion: DateTime.now(), rating: 5, critica: 'Buena crítica', esPrestado: false, prestadoA: null, prestadoDe: null, fechaPrestacion: null, fechaRegreso: null, fechaLectura: null, totalPaginas: 300, )), 
     expect: () => <AppEstado>[Operacional(listaLibros: [])],
  );
}