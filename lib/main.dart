// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:convert';
import 'package:app_libros/modelos/info_prestacion.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as material;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app_libros/blocs/bloc.dart';
import 'package:app_libros/modelos/libro.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionInyectada());
}

class AplicacionInyectada extends StatelessWidget {
  const AplicacionInyectada({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrganizadorLibros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: material.BlocProvider(
        create: (context) => AppBloc()..add(Inicializado()),
        child: const MaterialApp(
          home: BarraNavegacion(),
        ),
      ),
    );
  }
}

// Barra de Navegacion

class BarraNavegacion extends StatefulWidget {
  const BarraNavegacion({Key? key}) : super(key: key);

  @override
  State<BarraNavegacion> createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _currentIndex = 0;

  String obtenerTitulo() {
    switch (_currentIndex) {
      case 0:
        return 'Buscar Libros';
      case 1:
        return 'Mis libros';
      case 2:
        return 'Reportes';
      default:
        return 'Unknown';
    }
  }

  final List<Widget> _paginas = [
    const PantallaBuscar(),
    const PantallaMisLibros(),
    const PantallaReportes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(obtenerTitulo()),
      ),
      body: _paginas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 153, 153, 153),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mis Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}

// Pantalla Buscador

class PantallaBuscar extends StatefulWidget {
  const PantallaBuscar({super.key});

  @override
  State<PantallaBuscar> createState() => _PantallaBuscarState();
}

class _PantallaBuscarState extends State<PantallaBuscar> {
  List books = [];
  TextEditingController searchController = TextEditingController();

  Future<void> buscarLibros(String query) async {
    const apiKey = 'AIzaSyANoCFakFV-D0QXg8hQbeKvdlMKxaVH8z8';
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        books = data['items'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar libro',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  buscarLibros(searchController.text);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final libro = books[index]['volumeInfo'];
              final isbnList = libro['industryIdentifiers']
                      ?.map((id) => id['identifier'])
                      .toList() ??
                  ['No ISBN'];
              final pageCount = libro['pageCount']?.toString();
              final imageUrl = libro['imageLinks']?['thumbnail'] ?? '';

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.book),
                title: Text(libro['title']),
                subtitle:
                    Text(libro['authors']?.join(', ') ?? 'Autor desconocido'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ISBN: ${isbnList.join(', ')}'),
                    Text('Páginas: $pageCount'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleLibroPage(libro: libro),
                      ));
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class DetalleLibroPage extends StatelessWidget {
  final Map libro;

  const DetalleLibroPage({Key? key, required this.libro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isbnLista =
        libro['industryIdentifiers']?.map((id) => id['identifier']).toList() ??
            ['No ISBN'];
    final pageCount = libro['pageCount']?.toString() ?? 'N/A';
    final imageUrl = libro['imageLinks']?['thumbnail'] ?? '';
    final isbn = libro['industryIdentifiers']?.first['identifier'];
    final titulo = libro['title'] ?? 'Sin título';
    final autor = libro['authors']?.join(', ') ?? 'Autor desconocido';
    final genero = libro['categories'] != null
        ? libro['categories'].join(', ')
        : 'Género desconocido';
    final portadaUrl = imageUrl;
    final fechaPublicacion = DateTime.now();
    final totalPaginas = int.tryParse(pageCount) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(libro['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : const Icon(Icons.book, size: 100),
            const SizedBox(height: 16),
            Text('Título: ${libro['title']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                'Autor: ${libro['authors']?.join(', ') ?? 'Autor desconocido'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Género: ${libro['categories']?.join(', ') ?? 'Desconocido'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ISBN: ${isbnLista.join(', ')}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Páginas: $pageCount', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bloc = context.read<AppBloc>();
          final bool existe = await bloc.existeISBN(isbn);
          if (existe) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Información'),
                  content: const Text('Este libro ya está en la biblioteca.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: AgregarModal(
                      isbn: isbn,
                      titulo: titulo,
                      autor: autor,
                      genero: genero,
                      portadaUrl: portadaUrl,
                      fechaPublicacion: fechaPublicacion,
                      totalPaginas: totalPaginas,
                    ),
                  );
                });
          }
          // Navigator.pop(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AgregarModal extends StatefulWidget {
  final String isbn;
  final String titulo;
  final String autor;
  final String genero;
  final String portadaUrl;
  final DateTime fechaPublicacion;
  final int totalPaginas;

  const AgregarModal(
      {super.key,
      required this.isbn,
      required this.titulo,
      required this.autor,
      required this.genero,
      required this.portadaUrl,
      required this.fechaPublicacion,
      required this.totalPaginas});

  @override
  State<AgregarModal> createState() => _AgregarModalState();
}

class _AgregarModalState extends State<AgregarModal> {
  bool _isLeido = false;
  bool _isPrestado = false;
  bool _isPrestadoA = false;
  bool _isPrestadoDe = false;
  DateTime? _fechaSeleccionada;
  int _rating = 0;
  String _prestadoA = '';
  String _prestadoDe = '';
  String _resena = '';
  DateTime? _fechaPrestacion;
  DateTime? _fechaRegreso;

  @override
  Widget build(BuildContext context) {
    Future<void> seleccionarFecha(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _fechaSeleccionada) {
        setState(() {
          _fechaSeleccionada = picked;
        });
      }
    }

    Future<void> seleccionarFechaPrestacion(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _fechaPrestacion) {
        setState(() {
          _fechaPrestacion = picked;
        });
      }
    }

    Future<void> seleccionarFechaRegreso(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _fechaRegreso) {
        setState(() {
          _fechaRegreso = picked;
        });
      }
    }

    bool validarFormulario() {
      if (_isPrestado) {
        if ((_isPrestadoA && _prestadoA.isEmpty) ||
            (_isPrestadoDe && _prestadoDe.isEmpty)) {
          return false;
        }
        if (_fechaPrestacion == null) {
          return false;
        }
      }
      if (_isLeido && _fechaSeleccionada == null) {
        return false;
      }
      return true;
    }

    void mostrarAlertaError(String mensaje) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    void guardarLibro(Libro newLibro) {
      if (!validarFormulario()) {
        mostrarAlertaError(
            'Todos los campos necesarios deben estar completos.');
        return;
      }
      context.read<AppBloc>().add(AgregarLibro(libro: newLibro));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Libro guardado correctamente'), ), );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Es prestado?'),
              value: _isPrestado,
              onChanged: (bool value) {
                setState(() {
                  _isPrestado = value;
                  _isPrestadoA = true;
                });
              },
            ),
            if (_isPrestado) ...[
              SwitchListTile(
                title: const Text('Prestado A'),
                value: _isPrestadoA,
                onChanged: (bool value) {
                  setState(() {
                    _isPrestadoA = value;
                    if (value) {
                      _isPrestadoDe = false;
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Prestado de'),
                value: _isPrestadoDe,
                onChanged: (bool value) {
                  setState(() {
                    _isPrestadoDe = value;
                    if (value) {
                      _isPrestadoA = false;
                    }
                  });
                },
              ),
              if (_isPrestadoA) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Prestado a'),
                  onChanged: (value) {
                    setState(() {
                      _prestadoA = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Fecha de Prestación'),
                  subtitle: Text(_fechaPrestacion == null
                      ? 'Selecciona una fecha'
                      : DateFormat.yMMMd().format(_fechaPrestacion!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => seleccionarFechaPrestacion(context),
                ),
                ListTile(
                  title: const Text('Fecha de Regreso'),
                  subtitle: Text(_fechaRegreso == null
                      ? 'Selecciona una fecha'
                      : DateFormat.yMMMd().format(_fechaRegreso!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => seleccionarFechaRegreso(context),
                ),
              ],
              if (_isPrestadoDe) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Prestado de'),
                  onChanged: (value) {
                    setState(() {
                      _prestadoDe = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Fecha de Prestación'),
                  subtitle: Text(_fechaPrestacion == null
                      ? 'Selecciona una fecha'
                      : DateFormat.yMMMd().format(_fechaPrestacion!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => seleccionarFechaPrestacion(context),
                ),
                ListTile(
                  title: const Text('Fecha de Regreso'),
                  subtitle: Text(_fechaRegreso == null
                      ? 'Selecciona una fecha'
                      : DateFormat.yMMMd().format(_fechaRegreso!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => seleccionarFechaRegreso(context),
                ),
              ],
            ],
            SwitchListTile(
              title: const Text('Marcar como leido'),
              value: _isLeido,
              onChanged: (bool value) {
                setState(() {
                  _isLeido = value;
                  if (value) {
                    _rating = 1;
                  }
                });
              },
            ),
            if (_isLeido) ...[
              ListTile(
                title: const Text('Fecha de lectura'),
                subtitle: Text(_fechaSeleccionada == null
                    ? 'Selecciona una fecha'
                    : DateFormat.yMMMd().format(_fechaSeleccionada!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => seleccionarFecha(context),
              ),
              ListTile(
                title: const Text('Calificar libro'),
                subtitle: Text('$_rating/10'),
                trailing: DropdownButton<int>(
                  value: _rating,
                  items: List.generate(10, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _rating = value!;
                    });
                  },
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reseña',
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _resena = value;
                  });
                },
              )
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Libro newLibro = Libro(
                    isbn: widget.isbn,
                    titulo: widget.titulo,
                    autor: widget.autor,
                    genero: widget.genero,
                    portadaUrl: widget.portadaUrl,
                    fechaPublicacion: widget.fechaPublicacion.toIso8601String(),
                    rating: _rating,
                    critica: _resena,
                    esPrestado: _isPrestadoA || _isPrestadoDe,
                    prestadoA: _isPrestadoA ? _prestadoA : null,
                    prestadoDe: _isPrestadoDe ? _prestadoDe : null,
                    fechaPrestacion: _fechaPrestacion?.toIso8601String(),
                    fechaRegreso: _fechaRegreso?.toIso8601String(),
                    fechaLectura: _fechaSeleccionada?.toIso8601String(),
                    totalPaginas: widget.totalPaginas);
                guardarLibro(newLibro);
              },
              child: const Text('Guardar libro'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla MisLibros

class PantallaMisLibros extends StatefulWidget {
  const PantallaMisLibros({super.key});

  @override
  State<PantallaMisLibros> createState() => _PantallaMisLibrosState();
}

class _PantallaMisLibrosState extends State<PantallaMisLibros> {
  String _ordenSeleccionado = 'Título';

  @override
  Widget build(BuildContext context) {
    List<Libro> libros = [];
    List<InfoPrestacion> prestamos = [];

    var estado = context.watch<AppBloc>().state;

    if (estado is Operacional) {
      libros = (estado).listaLibros;
      prestamos = (estado).listaPrestamos;
    }

    if (estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (libros.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Aun no tienes libros :(')],
        ),
      );
    }

    return material.BlocBuilder<AppBloc, AppEstado>(
      builder: (context, state) {
        libros.sort((a, b) {
          switch (_ordenSeleccionado) {
            case 'Autor':
              return a.autor.compareTo(b.autor);
            case 'Calificación':
              return (b.rating ?? 0).compareTo(a.rating ?? 0);
            case 'Fecha':
              return DateTime.parse(b.fechaPublicacion)
                  .compareTo(DateTime.parse(a.fechaPublicacion));
            default:
              return a.titulo.compareTo(b.titulo);
          }
        });

        // Ordenar la lista de prestamos por fecha de préstamo en orden descendente.
        prestamos.sort((a, b) => DateTime.parse(b.fechaPrestacion!)
            .compareTo(DateTime.parse(a.fechaPrestacion!)));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ordenar por:'),
                  DropdownButton<String>(
                    value: _ordenSeleccionado,
                    onChanged: (String? newValue) {
                      setState(() {
                        _ordenSeleccionado = newValue!;
                      });
                    },
                    items: <String>['Título', 'Autor', 'Calificación', 'Fecha']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: libros.length,
                itemBuilder: (context, index) {
                  final libro = libros[index];
                  // Filtrar prestamos por ISBN y obtener el más reciente.
                  final prestamosFiltrados = prestamos
                      .where((prestamo) => prestamo.isbn == libro.isbn)
                      .toList();

                  final infoPrestacionReciente = prestamosFiltrados.isNotEmpty
                      ? prestamosFiltrados.first
                      : null;
                  return ListTile(
                    leading: libro.portadaUrl.isNotEmpty
                        ? Image.network(libro.portadaUrl,
                            width: 50, fit: BoxFit.cover)
                        : const Icon(Icons.book),
                    title: Text(libro.titulo),
                    subtitle: Text(libro.autor),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ISBN : ${libro.isbn}'),
                        Text('Paginas : ${libro.totalPaginas}')
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => DetalleLibroMisLibrosPage(
                                    libro: libro,
                                    infoPrestacion: infoPrestacionReciente ??
                                        InfoPrestacion(isbn: libro.isbn),
                                  ))));
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class DetalleLibroMisLibrosPage extends StatefulWidget {
  final Libro libro;
  final InfoPrestacion infoPrestacion;

  const DetalleLibroMisLibrosPage({
    Key? key,
    required this.libro,
    required this.infoPrestacion,
  }) : super(key: key);

  @override
  State<DetalleLibroMisLibrosPage> createState() =>
      _DetalleLibroMisLibrosPageState();
}

class _DetalleLibroMisLibrosPageState extends State<DetalleLibroMisLibrosPage> {
  late Libro libro;
  late InfoPrestacion infoPrestacion;

  @override
  void initState() {
    super.initState();
    libro = widget.libro;
    infoPrestacion = widget.infoPrestacion;
  }

  Future<void> _editarLibro(Libro libro) async {
    final result = await showModalBottomSheet<Libro>(
      context: context,
      builder: (context) => EditarLibroModal(
        libro: libro,
        infoPrestacion: infoPrestacion,
      ),
    );
    if (result != null) {
      setState(() {
        libro = result;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Libro actualizado correctamente'), ), );
  }

  void _mostrarModalEliminar(Libro libro) {
    final outerContext = context;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Borrar permanentemente'),
            content:
                const Text('¿Estás seguro de que deseas eliminar este libro?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  outerContext
                      .read<AppBloc>()
                      .add(EliminarLibro(isbn: libro.isbn));
                  Navigator.of(context).pop();
                  Navigator.of(outerContext).pop();
                  ScaffoldMessenger.of(outerContext).showSnackBar( const SnackBar( content: Text('Libro eliminado correctamente'), ), );
                },
                child: const Text('Eliminar'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return material.BlocListener<AppBloc, AppEstado>(
      listener: (context, state) {
        if (state is Operacional) {
          // Actualiza la información del libro
          int indexLibro =
              state.listaLibros.indexWhere((l) => l.isbn == libro.isbn);
          if (indexLibro != -1) {
            setState(() {
              libro = state.listaLibros[indexLibro];
            });
          }

          // Actualiza la información de infoprestación
          int indexPrestacion = state.listaPrestamos
              .indexWhere((p) => p.isbn == infoPrestacion.isbn);
          if (indexPrestacion != -1) {
            setState(() {
              infoPrestacion = state.listaPrestamos[indexPrestacion];
            });
          }
        }
        print(infoPrestacion);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(libro.titulo),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              libro.portadaUrl.isNotEmpty
                  ? Image.network(libro.portadaUrl)
                  : const Icon(Icons.book, size: 100),
              const SizedBox(height: 16),
              Text('Título: ${libro.titulo}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Autor: ${libro.autor}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('ISBN: ${libro.isbn}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Páginas: ${libro.totalPaginas}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Género: ${libro.genero}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.fechaLectura != null)
                Text('Fecha de Lectura: ${libro.fechaLectura}',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.rating != 0)
                Text('Calificación: ${libro.rating}/10',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.critica.isNotEmpty)
                Text('Crítica: ${libro.critica}',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.esPrestado) ...[
                if (infoPrestacion.prestadoA != null &&
                    infoPrestacion.prestadoA!.isNotEmpty) ...[
                  Text('Prestado a: ${infoPrestacion.prestadoA}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                      'Fecha prestacion : ${DateFormat.yMd().format(DateTime.parse(infoPrestacion.fechaPrestacion!))}',
                      style: const TextStyle(fontSize: 18)),
                ],
                if (infoPrestacion.prestadoDe != null &&
                    infoPrestacion.prestadoDe!.isNotEmpty) ...[
                  Text('Prestado de: ${infoPrestacion.prestadoDe}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                      'Fecha prestacion : ${DateFormat.yMd().format(DateTime.parse(infoPrestacion.fechaPrestacion!))}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ]
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  _editarLibro(libro);
                },
                child: const Icon(Icons.edit),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: () {
                  _mostrarModalEliminar(libro);
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditarLibroModal extends StatefulWidget {
  final Libro libro;
  final InfoPrestacion infoPrestacion;

  const EditarLibroModal({
    Key? key,
    required this.libro,
    required this.infoPrestacion,
  }) : super(key: key);

  @override
  State<EditarLibroModal> createState() => _EditarLibroModalState();
}

class _EditarLibroModalState extends State<EditarLibroModal> {
  late bool _isLeido;
  late bool _isPrestado;
  late bool _isPrestadoA;
  late bool _isPrestadoDe;
  DateTime? _fechaSeleccionada;
  late int _rating;
  late String _prestadoA;
  late String _prestadoDe;
  late String _resena;
  DateTime? _fechaPrestacion;
  DateTime? _fechaRegreso;

  late TextEditingController _prestadoAController;
  late TextEditingController _prestadoDeController;
  late TextEditingController _resenaController;

  @override
  void initState() {
    super.initState();
    _isLeido = widget.libro.fechaLectura != null;
    _isPrestado = widget.libro.esPrestado;

    // Evaluar los campos de InfoPrestacion para determinar el estado inicial
    _isPrestadoA = widget.infoPrestacion.prestadoA != null &&
        widget.infoPrestacion.prestadoA!.isNotEmpty;
    _isPrestadoDe = widget.infoPrestacion.prestadoDe != null &&
        widget.infoPrestacion.prestadoDe!.isNotEmpty;

    _fechaSeleccionada = _parseFecha(widget.libro.fechaLectura);
    _rating = widget.libro.rating != null && widget.libro.rating! > 0
        ? widget.libro.rating!
        : 1;
    _prestadoA = widget.infoPrestacion.prestadoA ?? '';
    _prestadoDe = widget.infoPrestacion.prestadoDe ?? '';
    _resena = widget.libro.critica;
    _fechaPrestacion = _parseFecha(widget.infoPrestacion.fechaPrestacion);
    _fechaRegreso = _parseFecha(widget.infoPrestacion.fechaRegreso);

    // Inicializar controladores
    _prestadoAController = TextEditingController(text: _prestadoA);
    _prestadoDeController = TextEditingController(text: _prestadoDe);
    _resenaController = TextEditingController(text: _resena);
  }

  DateTime? _parseFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return null;
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      return null;
    }
  }

  Future<void> seleccionarFecha(BuildContext context, DateTime? selectedDate,
      Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        onSelect(picked);
      });
    }
  }

  void guardarCambios() {
    if (!validarFormulario()) {
      mostrarAlertaError('Por favor completa todos los campos requeridos.');
      return;
    }
    Libro libroEditado = Libro(
      isbn: widget.libro.isbn,
      titulo: widget.libro.titulo,
      autor: widget.libro.autor,
      genero: widget.libro.genero,
      portadaUrl: widget.libro.portadaUrl,
      fechaPublicacion: widget.libro.fechaPublicacion,
      critica: _resena,
      esPrestado: _isPrestado,
      prestadoA: _isPrestado ? _prestadoA : '',
      prestadoDe: widget.libro.prestadoDe,
      fechaPrestacion: widget.libro.fechaPrestacion,
      fechaRegreso: widget.libro.fechaRegreso,
      fechaLectura: _isLeido ? _fechaSeleccionada?.toIso8601String() : '',
      totalPaginas: widget.libro.totalPaginas,
      rating: _rating,
    );

    // Crear la información de préstamo actualizada
    InfoPrestacion infoPrestacion = InfoPrestacion(
      isbn: widget.libro.isbn,
      prestadoA: _isPrestadoA ? _prestadoA : null,
      prestadoDe: _isPrestadoDe ? _prestadoDe : null,
      fechaPrestacion: _fechaPrestacion?.toIso8601String(),
      fechaRegreso: _fechaRegreso?.toIso8601String(),
    );

    context
        .read<AppBloc>()
        .add(EditarLibro(libro: libroEditado, infoPrestacion: infoPrestacion));

    Navigator.pop(context, libroEditado);

    setState(() {});
  }

  bool validarFormulario() {
    if (_isPrestado) {
      if ((_isPrestadoA && _prestadoA.isEmpty) ||
          (_isPrestadoDe && _prestadoDe.isEmpty)) {
        return false;
      }
      if (_fechaPrestacion == null) {
        return false;
      }
    }
    if (_isLeido && _fechaSeleccionada == null) {
      return false;
    }
    return true;
  }

  void mostrarAlertaError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Es prestado?'),
                value: _isPrestado,
                onChanged: (bool value) {
                  setState(() {
                    _isPrestado = value;
                    if (!value) {
                      _isPrestadoA = false;
                      _isPrestadoDe = false;
                    }
                  });
                },
              ),
              if (_isPrestado) ...[
                SwitchListTile(
                  title: const Text('Prestado A'),
                  value: _isPrestadoA,
                  onChanged: (bool value) {
                    setState(() {
                      _isPrestadoA = value;
                      if (value) {
                        _isPrestadoDe = false;
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Prestado De'),
                  value: _isPrestadoDe,
                  onChanged: (bool value) {
                    setState(() {
                      _isPrestadoDe = value;
                      if (value) {
                        _isPrestadoA = false;
                      }
                    });
                  },
                ),
                if (_isPrestadoA) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Prestado a'),
                    controller: _prestadoAController,
                    onChanged: (value) {
                      setState(() {
                        _prestadoA = value;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Fecha de Prestación'),
                    subtitle: Text(_fechaPrestacion == null
                        ? 'Selecciona una fecha'
                        : DateFormat.yMMMd().format(_fechaPrestacion!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => seleccionarFecha(context, _fechaPrestacion,
                        (picked) => _fechaPrestacion = picked),
                  ),
                  ListTile(
                    title: const Text('Fecha de Regreso'),
                    subtitle: Text(_fechaRegreso == null
                        ? 'Selecciona una fecha'
                        : DateFormat.yMMMd().format(_fechaRegreso!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => seleccionarFecha(context, _fechaRegreso,
                        (picked) => _fechaRegreso = picked),
                  ),
                ],
                if (_isPrestadoDe) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Prestado de'),
                    controller: _prestadoDeController,
                    onChanged: (value) {
                      setState(() {
                        _prestadoDe = value;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Fecha de Prestación'),
                    subtitle: Text(_fechaPrestacion == null
                        ? 'Selecciona una fecha'
                        : DateFormat.yMMMd().format(_fechaPrestacion!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => seleccionarFecha(context, _fechaPrestacion,
                        (picked) => _fechaPrestacion = picked),
                  ),
                  ListTile(
                    title: const Text('Fecha de Regreso'),
                    subtitle: Text(_fechaRegreso == null
                        ? 'Selecciona una fecha'
                        : DateFormat.yMMMd().format(_fechaRegreso!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => seleccionarFecha(context, _fechaRegreso,
                        (picked) => _fechaRegreso = picked),
                  ),
                ],
                SwitchListTile(
                  title: const Text('Marcar como leído'),
                  value: _isLeido,
                  onChanged: (bool value) {
                    setState(() {
                      _isLeido = value;
                      if (value = false) {
                        _rating = 0;
                      }
                    });
                  },
                ),
                if (_isLeido) ...[
                  ListTile(
                    title: const Text('Fecha de lectura'),
                    subtitle: Text(
                      _fechaSeleccionada == null
                          ? 'Selecciona una fecha'
                          : DateFormat.yMMMd().format(_fechaSeleccionada!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => seleccionarFecha(context, _fechaSeleccionada,
                        (picked) => _fechaSeleccionada = picked),
                  ),
                  ListTile(
                    title: const Text('Calificar libro'),
                    subtitle: Text('$_rating/10'),
                    trailing: DropdownButton<int>(
                      value: _rating,
                      items: List.generate(10, (index) => index + 1)
                          .map((value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _rating = value!;
                        });
                      },
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Reseña',
                    ),
                    maxLines: 3,
                    controller: _resenaController,
                    onChanged: (value) {
                      setState(() {
                        _resena = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: guardarCambios,
                  child: const Text('Guardar cambios'),
                ),
              ],
            ]),
      ),
    );
  }
}

// Pantalla Reportes

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  String _criterioSeleccionado = 'Género que más me gusta';
  DateTimeRange? _rangoFechas;
  @override
  Widget build(BuildContext context) {
    List<Libro> libros = [];

    var estado = context.watch<AppBloc>().state;

    if (estado is Operacional) {
      libros = estado.listaLibros;
    }

    if (libros.isEmpty) {
      return const Center(
        child:
            Text('Aún no tienes libros suficientes para generar reportes :('),
      );
    }

    final series = _generarDatosParaGrafica(libros);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            value: _criterioSeleccionado,
            items: const [
              DropdownMenuItem(
                value: 'Género que más me gusta',
                child: Text('Género que más me gusta'),
              ),
              DropdownMenuItem(
                value: 'Género que más se repite',
                child: Text('Género que más se repite'),
              ),
              DropdownMenuItem(
                value: 'Autor que más me gusta',
                child: Text('Autor que más me gusta'),
              ),
              DropdownMenuItem(
                value: 'Páginas leídas en el año',
                child: Text('Páginas leídas en el año'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _criterioSeleccionado = value!;
                if (_criterioSeleccionado == 'Páginas leídas en el año') {
                  _rangoFechas = DateTimeRange(
                    start: DateTime(DateTime.now().year, 1, 1),
                    end: DateTime(DateTime.now().year, 12, 31),
                  );
                } else {
                  _rangoFechas = null;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              {
                if (_criterioSeleccionado == 'Páginas leídas en el año') {
                  int? selectedYear = await showYearPicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2024),
                  );
                  if (selectedYear != null) {
                    setState(() {
                      _rangoFechas = DateTimeRange(
                        start: DateTime(selectedYear, 1, 1),
                        end: DateTime(selectedYear, 12, 31),
                      );
                    });
                  }
                } else {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(1950, 1, 1),
                    lastDate: DateTime(2024, 12, 31),
                    initialDateRange: DateTimeRange(
                      start: DateTime(2024, 1, 1),
                      end: DateTime(2024, 12, 31),
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _rangoFechas = picked;
                    });
                  }
                }
              }
            },
          ),
          if (_rangoFechas != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _criterioSeleccionado == 'Páginas leídas en el año'
                      ? 'Seleccionado: ${_rangoFechas!.start.year}'
                      : 'Seleccionado: ${_rangoFechas!.start.toLocal().toIso8601String().substring(0, 10)} - ${_rangoFechas!.end.toLocal().toIso8601String().substring(0, 10)}',
                ),
                if (_criterioSeleccionado == 'Páginas leídas en el año')
                  Text(
                      'Total de páginas leídas: ${_calcularTotalPaginasLeidas(libros, _rangoFechas)}'),
              ],
            ),
          const SizedBox(height: 20), // Espacio entre el dropdown y el gráfico

          Expanded(
            child: _criterioSeleccionado == 'Páginas leídas en el año'
                ? charts.BarChart(
                    series,
                    animate: true,
                    barGroupingType: charts.BarGroupingType.grouped,
                    behaviors: [
                      charts.ChartTitle('Meses del Año',
                          behaviorPosition: charts.BehaviorPosition.bottom,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea),
                      charts.ChartTitle('Páginas Leídas',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea),
                    ],
                    domainAxis: charts.OrdinalAxisSpec(
                      viewport: charts.OrdinalViewport('01', 12),
                      renderSpec: const charts.SmallTickRendererSpec(
                          labelRotation: 45,
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          )),
                    ),
                    defaultRenderer: charts.BarRendererConfig(
                      barRendererDecorator: charts.BarLabelDecorator<
                          String>(), // Agrega etiquetas
                      cornerStrategy: const charts.ConstCornerStrategy(
                          4), // Bordes redondeados opcionales
                    ),
                    customSeriesRenderers: [
                      charts.BarRendererConfig(
                        customRendererId: 'customBar',
                        barRendererDecorator: charts.BarLabelDecorator<
                            String>(), // Decorador para esta serie
                      ),
                    ],
                  )
                : charts.PieChart<String>(
                    series,
                    animate: true,
                    defaultRenderer: charts.ArcRendererConfig<String>(
                      arcWidth: 60,
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(
                          labelPosition: charts.ArcLabelPosition.inside,
                        ),
                      ],
                    ),
                    behaviors: [
                      charts.DatumLegend(
                        outsideJustification:
                            charts.OutsideJustification.endDrawArea,
                        horizontalFirst: false,
                        desiredMaxRows: 2,
                        cellPadding:
                            const EdgeInsets.only(right: 4.0, bottom: 4.0),
                        entryTextStyle: charts.TextStyleSpec(
                          color: charts.MaterialPalette.purple.shadeDefault,
                          fontFamily: 'Georgia',
                          fontSize: 11,
                        ),
                      ),
                      charts.SelectNearest(),
                      charts.DomainHighlighter(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  int _calcularTotalPaginasLeidas(
      List<Libro> libros, DateTimeRange? rangoFechas) {
    int totalPaginas = 0;
    for (var libro in libros) {
      final fechaLectura = DateTime.parse(libro.fechaLectura!);
      if (rangoFechas != null &&
          (fechaLectura.isAfter(rangoFechas.start) ||
              fechaLectura.isAtSameMomentAs(rangoFechas.start)) &&
          (fechaLectura.isBefore(rangoFechas.end) ||
              fechaLectura.isAtSameMomentAs(rangoFechas.end))) {
        totalPaginas += libro.totalPaginas;
      }
    }
    return totalPaginas;
  }

  List<charts.Series<dynamic, String>> _generarDatosParaGrafica(
      List<Libro> libros) {
    // Filtrar libros por rango de fechas si se ha seleccionado
    if (_rangoFechas != null) {
      libros = libros.where((libro) {
        final fechaLectura = DateTime.parse(libro.fechaLectura!);
        return fechaLectura.isAfter(_rangoFechas!.start) &&
            fechaLectura.isBefore(_rangoFechas!.end);
      }).toList();
    }

    if (_criterioSeleccionado == 'Autor que más me gusta') {
      // Generar datos para la gráfica de pastel basada en autores
      Map<String, int> conteoAutores = {};
      for (var libro in libros) {
        conteoAutores.update(
          libro.autor,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      final data = conteoAutores.entries
          .map((entry) => PieChartData(entry.key, entry.value.toDouble()))
          .toList();
      return [
        charts.Series<PieChartData, String>(
          id: 'Autores',
          data: data,
          domainFn: (PieChartData entry, _) => entry.genero,
          measureFn: (PieChartData entry, _) => entry.promedio,
          labelAccessorFn: (PieChartData entry, _) =>
              '${entry.genero}: ${entry.promedio.toInt()}',
        ),
      ];
    }

    if (_criterioSeleccionado == 'Género que más se repite') {
      // Generar datos para la gráfica de pastel basada en el conteo de géneros
      Map<String, int> conteoGeneros = {};
      for (var libro in libros) {
        conteoGeneros.update(libro.genero, (value) => value + 1,
            ifAbsent: () => 1);
      }

      final data = conteoGeneros.entries
          .map((entry) => PieChartData(entry.key, entry.value.toDouble()))
          .toList();
      return [
        charts.Series<PieChartData, String>(
          id: 'Géneros Repetidos',
          data: data,
          domainFn: (PieChartData entry, _) => entry.genero,
          measureFn: (PieChartData entry, _) => entry.promedio,
          labelAccessorFn: (PieChartData entry, _) =>
              '${entry.genero}: ${entry.promedio.toStringAsFixed(1)}',
        ),
      ];
    }

    if (_criterioSeleccionado == 'Páginas leídas en el año') {
      // Generar datos para la gráfica de barras basada en las páginas leídas
      Map<String, int> paginasLeidasPorMes = {
        '01': 0,
        '02': 0,
        '03': 0,
        '04': 0,
        '05': 0,
        '06': 0,
        '07': 0,
        '08': 0,
        '09': 0,
        '10': 0,
        '11': 0,
        '12': 0,
      };
      for (var libro in libros) {
        final fechaLectura = DateTime.parse(libro.fechaLectura!);
        if (_rangoFechas != null &&
            (fechaLectura.isAfter(_rangoFechas!.start) ||
                fechaLectura.isAtSameMomentAs(_rangoFechas!.start)) &&
            (fechaLectura.isBefore(_rangoFechas!.end) ||
                fechaLectura.isAtSameMomentAs(_rangoFechas!.end))) {
          final mes = fechaLectura.month.toString().padLeft(2, '0');
          paginasLeidasPorMes.update(
            mes,
            (value) => value + libro.totalPaginas,
            ifAbsent: () => libro.totalPaginas,
          );
        }
      }
      final data = paginasLeidasPorMes.entries
          .map((entry) => BarChartData(entry.key, entry.value.toDouble()))
          .toList();
      return [
        charts.Series<BarChartData, String>(
          id: 'Páginas Leídas',
          data: data,
          domainFn: (BarChartData entry, _) => entry.mes,
          measureFn: (BarChartData entry, _) => entry.paginas,
          labelAccessorFn: (BarChartData entry, _) =>
              '${entry.paginas.toInt()}', // Valor mostrado como etiqueta
        )..setAttribute(charts.rendererIdKey, 'customBar'),
      ];
    }

    // Generar datos para la gráfica de pastel
    Map<String, double> generoPromedios = {};
    for (var libro in libros) {
      if (libro.rating != null) {
        generoPromedios.update(
          libro.genero,
          (value) => value + libro.rating!,
          ifAbsent: () => libro.rating!.toDouble(),
        );
      }
    }

    // Calcular promedio por género
    Map<String, double> promediosFinales = {};
    Map<String, int> conteoGeneros = {};
    for (var libro in libros) {
      if (libro.rating != null) {
        conteoGeneros.update(libro.genero, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    generoPromedios.forEach((genero, sumaRatings) {
      promediosFinales[genero] = sumaRatings / conteoGeneros[genero]!;
    });

    // Crear datos para la gráfica
    final data = promediosFinales.entries
        .map((entry) => PieChartData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<PieChartData, String>(
        id: 'Géneros',
        data: data,
        domainFn: (PieChartData entry, _) => entry.genero,
        measureFn: (PieChartData entry, _) => entry.promedio,
        labelAccessorFn: (PieChartData entry, _) =>
            '${entry.genero}: ${entry.promedio.toStringAsFixed(1)}',
      ),
    ];
  }
}

class PieChartData {
  final String genero;
  final double promedio;

  PieChartData(this.genero, this.promedio);
}

class BarChartData {
  final String mes;
  final double paginas;

  BarChartData(this.mes, this.paginas);
}

Future<int?> showYearPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  int? selectedYear;
  await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Selecciona el año'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: firstDate,
            lastDate: lastDate,
            initialDate: initialDate,
            selectedDate: initialDate,
            onChanged: (DateTime dateTime) {
              selectedYear = dateTime.year;
              Navigator.pop(context);
            },
          ),
        ),
      );
    },
  );
  return selectedYear;
}
