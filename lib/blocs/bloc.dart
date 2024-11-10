import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_libros/modelos/Libro.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';


// ----------- BD ----------------//

late Database db;
class RepositorioBD {
  
  Future<void> inicializar() async {
    var fabricaBaseDatos = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    String rutaBaseDatos = '${await fabricaBaseDatos.getDatabasesPath()}/baseMovil2.db';
    db = await fabricaBaseDatos.openDatabase(rutaBaseDatos,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            '''
            CREATE TABLE libros (
              isbn TEXT PRIMARY KEY,
              titulo TEXT NOT NULL,
              autor TEXT NOT NULL,
              portadaURL TEXT,
              fechaPublicacion DATE,
              rating INTEGER, 
              critica TEXT, 
              esPrestado BOOLEAN, 
              prestadoA TEXT, 
              prestadoDe TEXT, 
              fechaPrestacion DATE, 
              fechaRegreso DATE, 
              fechaLectura DATE, 
              totalPaginas INTEGER
            )
            '''  
          );
        }
      )
    );
    
  }
}






// ----------- Estados --------------//

sealed class AppEstado with EquatableMixin {}

class Inicial extends AppEstado {

  @override
  List<Object?> get props => [];

}

class Operacional extends AppEstado {
  final List<Libro> listaLibros;

  Operacional({required this.listaLibros});

  @override
  List<Object?> get props => [listaLibros];

}

// ----------- Eventos --------------//

sealed class AppEvento {}

class Inicializado extends AppEvento {}

// Libros

class AgregarLibro extends AppEvento {
   final String isbn;
   final String titulo;
   final String autor;
   final String portadaUrl;
   final DateTime fechaPublicacion;
   final int rating;
   final String critica;
   final bool esPrestado;
   final String? prestadoA;
   final String? prestadoDe;
   final DateTime? fechaPrestacion;
   final DateTime? fechaRegreso;
   final DateTime? fechaLectura;
   final int totalPaginas;

  AgregarLibro({required this.isbn, required this.titulo, required this.autor, required this.portadaUrl, required this.fechaPublicacion, required this.rating, required this.critica, required this.esPrestado, required this.prestadoA, required this.prestadoDe, required this.fechaPrestacion, required this.fechaRegreso, required this.fechaLectura, required this.totalPaginas});
}

class EliminarLibro extends AppEvento {
  final Libro libro;

  EliminarLibro({required this.libro});
}

class ActualizarLibro extends AppEvento {
   final String isbn;
   final String titulo;
   final String autor;
   final String portadaUrl;
   final DateTime fechaPublicacion;
   final int rating;
   final String critica;
   final bool esPrestado;
   final String? prestadoA;
   final String? prestadoDe;
   final DateTime? fechaPrestacion;
   final DateTime? fechaRegreso;
   final DateTime? fechaLectura;
   final int totalPaginas;

  ActualizarLibro({required this.isbn, required this.titulo, required this.autor, required this.portadaUrl, required this.fechaPublicacion, required this.rating, required this.critica, required this.esPrestado, required this.prestadoA, required this.prestadoDe, required this.fechaPrestacion, required this.fechaRegreso, required this.fechaLectura, required this.totalPaginas});
}

// ----------- BLOC ----------------//

class AppBloc extends Bloc<AppEvento, AppEstado> {
   List<Libro> _listaLibros = [];

  RepositorioBD repo = RepositorioBD();

  Future<void> todosLosLibros() async {
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery('SELECT * FROM libros');
    _listaLibros = resultadoConsulta.map((e) => Libro.fromMap(e)).toList();
  }


  // onEVENTOS //
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async{
      await todosLosLibros();

      emit(Operacional(listaLibros: _listaLibros));
    });
  }
}