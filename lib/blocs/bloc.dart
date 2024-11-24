import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_libros/modelos/libro.dart';
import 'package:flutter/foundation.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// ----------- BD ----------------//

late Database db;

class RepositorioBD {
  Future<void> inicializar() async {
    
    var fabricaBaseDatos = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    String rutaBaseDatos ='${await fabricaBaseDatos.getDatabasesPath()}/baseMovil2.db';
    db = await fabricaBaseDatos.openDatabase(rutaBaseDatos,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                    CREATE TABLE libros (
                      isbn TEXT PRIMARY KEY,
                      titulo TEXT NOT NULL,
                      genero TEXT NOT NULL,
                      autor TEXT NOT NULL,
                      portadaURL TEXT,
                      fechaPublicacion DATE,
                      totalPaginas INTEGER,
                      fechaLectura DATE, 
                      rating INTEGER,
                      critica TEXT,
                      esPrestado INTEGER
                    )
                    ''');

              await db.execute(''' 
                    CREATE TABLE prestamos ( 
                      prestamoID INTEGER PRIMARY KEY AUTOINCREMENT, 
                      isbn TEXT, 
                      prestadoA TEXT, 
                      prestadoDe TEXT, 
                      fechaPrestacion DATE, 
                      fechaRegreso DATE, 
                      FOREIGN KEY (isbn) REFERENCES libros(isbn)
                    )
                    ''');
            }));
  }

  Future<bool> existeISBN(String isbn) async { 
    final List<Map<String, dynamic>> maps = await db.query(
       'libros', where: 'isbn = ?', whereArgs: [isbn], 
      ); 
    return maps.isNotEmpty; 
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
  final Libro libro;

  AgregarLibro({required this.libro});
}

class EliminarLibro extends AppEvento {
  final String isbn;

  EliminarLibro({required this.isbn});
}

class EditarLibro extends AppEvento {
  final Libro libro;

  EditarLibro({required this.libro});
}

// ----------- BLOC ----------------//

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<Libro> _listaLibros = [];

  RepositorioBD repo = RepositorioBD();

  Future<void> todosLosLibros() async {
    await repo.inicializar();

      var resultadoConsulta = await db.rawQuery('SELECT * FROM libros');
      _listaLibros = resultadoConsulta.map((e) => Libro.fromMap(e)).toList();
      print(_listaLibros);
    
  }

  Future<void> todasLasConsultas() async {
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery('SELECT * FROM lecturas');
    _listaLibros = resultadoConsulta.map((e) => Libro.fromMap(e)).toList();
  }

  Future<void> agregarLibro(Libro libro) async {
    await db.rawInsert(
        ''' INSERT INTO libros ( isbn, titulo, genero, autor, portadaURL, fechaPublicacion, totalPaginas, fechaLectura, rating, critica, esPrestado ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ''',
        [
          libro.isbn,
          libro.titulo,
          libro.genero,
          libro.autor,
          libro.portadaUrl,
          libro.fechaPublicacion.toString(),
          libro.totalPaginas,
          libro.fechaLectura?.toString(),
          libro.rating,
          libro.critica,
          libro.esPrestado ? 1 : 0
        ]);

    if (libro.esPrestado) {
      await db.rawInsert(
          ''' INSERT INTO prestamos ( isbn, prestadoA, prestadoDe, fechaPrestacion, fechaRegreso ) VALUES (?, ?, ?, ?, ?) ''',
          [
            libro.isbn,
            libro.prestadoA,
            libro.prestadoDe,
            libro.fechaPrestacion,
            libro.fechaRegreso
          ]);
    }
    print('AQUI');
    print(libro.prestadoA);
    print(libro.fechaPrestacion);
    print(libro.prestadoDe);
    print(libro.fechaRegreso);

    await todosLosLibros();
  }

  Future<void> editarLibro(Libro libro) async {
    await db.rawUpdate(
        ''' UPDATE libros SET titulo = ?, genero = ?, autor = ?, portadaURL = ?, fechaPublicacion = ?, totalPaginas = ?, fechaLectura = ?, rating = ?, critica = ?, esPrestado = ? WHERE isbn = ? ''',
        [
          libro.titulo,
          libro.genero,
          libro.autor,
          libro.portadaUrl,
          libro.fechaPublicacion,
          libro.totalPaginas,
          libro.fechaLectura,
          libro.rating,
          libro.critica,
          libro.esPrestado ? 1 : 0,
          libro.isbn
        ]);
  }

  Future<void> eliminarLibro(String isbn) async {
    await db.rawDelete('''DELETE FROM libros WHERE isbn = ?''', [isbn]);
  }

  Future<bool> existeISBN(String isbn) async { return await repo.existeISBN(isbn); }
  // onEVENTOS //
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      await todosLosLibros();

      emit(Operacional(listaLibros: _listaLibros));
    });

    on<AgregarLibro>(((event, emit) async {
      await agregarLibro(event.libro);
      await todosLosLibros();
      emit((Operacional(listaLibros: _listaLibros)));
    }));

    on<EliminarLibro>(((event, emit) async {
      await eliminarLibro(event.isbn);
      await todosLosLibros();
      emit((Operacional(listaLibros: _listaLibros)));
    }));

    on<EditarLibro>(((event, emit) async {
      await editarLibro(event.libro);
      await todosLosLibros();
      emit((Operacional(listaLibros: _listaLibros)));
    }));
  }
}
