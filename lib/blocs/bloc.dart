import 'package:app_libros/modelos/info_prestacion.dart';
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
    String rutaBaseDatos =
        '${await fabricaBaseDatos.getDatabasesPath()}/baseMovil2.db';
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
      'libros',
      where: 'isbn = ?',
      whereArgs: [isbn],
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
  final List<InfoPrestacion> listaPrestamos;

  Operacional({required this.listaLibros, required this.listaPrestamos});

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
  final InfoPrestacion infoPrestacion;

  EditarLibro({required this.libro, required this.infoPrestacion});
}

// ----------- BLOC ----------------//

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<Libro> _listaLibros = [];
  List<InfoPrestacion> _listaPrestamos = [];

  RepositorioBD repo = RepositorioBD();

  Future<void> todosLosLibros() async {
    await repo.inicializar();

    var resultadoConsulta = await db.rawQuery('SELECT * FROM libros');
    _listaLibros = resultadoConsulta.map((e) => Libro.fromMap(e)).toList();
    print(_listaLibros);
    todasLasConsultas();
  }

  Future<void> todasLasConsultas() async {
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery('SELECT * FROM prestamos');
    _listaPrestamos =
        resultadoConsulta.map((e) => InfoPrestacion.fromMap(e)).toList();
    print(_listaPrestamos);
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
    await todosLosLibros();
    await todasLasConsultas();
  }

  Future<void> editarLibro(Libro libro, InfoPrestacion infoPrestacion) async {
    // Si se registra una fecha de regreso, marcar esPrestado como falso
    if (infoPrestacion.fechaRegreso != null &&
        infoPrestacion.fechaRegreso!.isNotEmpty) {
      libro.esPrestado = false;
    }

    // Actualizar los detalles del libro
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
      ],
    );

    // Verificar y manejar la tabla de prestamos
    if (libro.esPrestado) {
      // Buscar registros de prestamos con el mismo ISBN y sin fecha de regreso
      final List<Map<String, dynamic>> existingPrestamo = await db.rawQuery(
        'SELECT * FROM prestamos WHERE isbn = ? AND fechaRegreso IS NULL',
        [libro.isbn],
      );

      if (existingPrestamo.isNotEmpty) {
        // Si existe un prestamo activo, actualizarlo
        await db.rawUpdate(
          ''' UPDATE prestamos 
            SET prestadoA = ?, prestadoDe = ?, fechaPrestacion = ?, fechaRegreso = ? 
            WHERE isbn = ? AND fechaRegreso IS NULL ''',
          [
            infoPrestacion.prestadoA,
            infoPrestacion.prestadoDe,
            infoPrestacion.fechaPrestacion,
            infoPrestacion.fechaRegreso,
            libro.isbn
          ],
        );
      } else {
        // Si no hay registros activos (sin fecha de regreso), crear uno nuevo
        await db.rawInsert(
          ''' INSERT INTO prestamos ( isbn, prestadoA, prestadoDe, fechaPrestacion, fechaRegreso ) VALUES (?, ?, ?, ?, ?) ''',
          [
            libro.isbn,
            infoPrestacion.prestadoA,
            infoPrestacion.prestadoDe,
            infoPrestacion.fechaPrestacion,
            infoPrestacion.fechaRegreso
          ],
        );
      }
    } else {
      // Si el libro no está prestado, actualizar la fecha de regreso (si aplica)
      if (infoPrestacion.fechaRegreso != null &&
          infoPrestacion.fechaRegreso!.isNotEmpty) {
        await db.rawUpdate(
          ''' UPDATE prestamos 
            SET fechaRegreso = ? 
            WHERE isbn = ? AND fechaRegreso IS NULL ''',
          [infoPrestacion.fechaRegreso, libro.isbn],
        );
      }
    }
  }

  Future<void> eliminarLibro(String isbn) async {
    await db.rawDelete('''DELETE FROM libros WHERE isbn = ?''', [isbn]);
  }

  Future<bool> existeISBN(String isbn) async {
    return await repo.existeISBN(isbn);
  }

  // onEVENTOS //
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      await todosLosLibros();
      await todasLasConsultas();

      emit(Operacional(
          listaLibros: _listaLibros, listaPrestamos: _listaPrestamos));
    });

    on<AgregarLibro>(((event, emit) async {
      await agregarLibro(event.libro);
      await todosLosLibros();
      await todasLasConsultas();
      emit((Operacional(
          listaLibros: _listaLibros, listaPrestamos: _listaPrestamos)));
    }));

    on<EliminarLibro>(((event, emit) async {
      await eliminarLibro(event.isbn);
      await todosLosLibros();
      await todasLasConsultas();
      emit((Operacional(
          listaLibros: _listaLibros, listaPrestamos: _listaPrestamos)));
    }));

    on<EditarLibro>(((event, emit) async {
      await editarLibro(event.libro, event.infoPrestacion);
      await todosLosLibros();
      await todasLasConsultas();
      emit((Operacional(
          listaLibros: _listaLibros, listaPrestamos: _listaPrestamos)));
    }));
  }
}
