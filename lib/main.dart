// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
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
            icon: Icon(Icons.abc),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Mis Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
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
        onPressed: () {
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

          //   context.read<AppBloc>().add(AgregarLibro(
          //       libro: newLibro
          //       )

          //   );
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
  DateTime? _fechaSeleccionada;
  int _rating = 1;
  String _prestadoA = '';
  String _resena = '';

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

    void guardarLibro(Libro newLibro) {
      context.read<AppBloc>().add(AgregarLibro(libro: newLibro));
      Navigator.pop(context);
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
                });
              },
            ),
            if (_isPrestado)
              TextField(
                decoration: const InputDecoration(labelText: 'Prestado a'),
                onChanged: (value) {
                  setState(() {
                    _prestadoA = value;
                  });
                },
              ),
            SwitchListTile(
              title: const Text('Marcar como leido'),
              value: _isLeido,
              onChanged: (bool value) {
                setState(() {
                  _isLeido = value;
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
                    esPrestado: _isPrestado,
                    prestadoA: '',
                    prestadoDe: '',
                    fechaPrestacion: '',
                    fechaRegreso: '',
                    fechaLectura: _fechaSeleccionada.toString(),
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
    var estado = context.watch<AppBloc>().state;

    if (estado is Operacional) {
        libros = (estado).listaLibros;

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
                      items: <String>[
                        'Título',
                        'Autor',
                        'Calificación',
                        'Fecha'
                      ].map<DropdownMenuItem<String>>((String value) {
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
                                builder: ((context) =>
                                    DetalleLibroMisLibrosPage(libro: libro))));
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

  const DetalleLibroMisLibrosPage({
    Key? key,
    required this.libro,
  }) : super(key: key);

  @override
  State<DetalleLibroMisLibrosPage> createState() =>
      _DetalleLibroMisLibrosPageState();
}

class _DetalleLibroMisLibrosPageState extends State<DetalleLibroMisLibrosPage> {
  late Libro libro;

  @override
  void initState() {
    super.initState();
    libro = widget.libro;
  }

  Future<void> _editarLibro(Libro libro) async {
    final result = await showModalBottomSheet<Libro>(
      context: context,
      builder: (context) => EditarLibroModal(libro: libro),
    );
    if (result != null) {
      setState(() {
        libro = result;
      });
    }
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
          int index = state.listaLibros.indexWhere((l) => l.isbn == libro.isbn);
          if (index != -1) {
            setState(() {
              libro = state.listaLibros[index];
            });
          }
        }
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
              Text('Calificación: ${libro.rating}/10',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.critica.isNotEmpty)
                Text('Crítica: ${libro.critica}',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (libro.esPrestado)
                Text('Prestado a: ${libro.prestadoA}',
                    style: const TextStyle(fontSize: 18)),
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

  const EditarLibroModal({
    Key? key,
    required this.libro,
  }) : super(key: key);

  @override
  State<EditarLibroModal> createState() => _EditarLibroModalState();
}

class _EditarLibroModalState extends State<EditarLibroModal> {
  late bool _isLeido;
  late bool _isPrestado;
  DateTime? _fechaSeleccionada;
  late int _rating;
  late String _prestadoA;
  late String _resena;

  @override
  void initState() {
    super.initState();
    _isLeido = widget.libro.fechaLectura != null;
    _isPrestado = widget.libro.esPrestado;
    _fechaSeleccionada = _parseFecha(widget.libro.fechaLectura);
    _rating = widget.libro.rating ?? 1;
    _prestadoA = widget.libro.prestadoA ?? '';
    _resena = widget.libro.critica;
  }

  DateTime? _parseFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return null;
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      return null;
    }
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void guardarCambios() {
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

    context.read<AppBloc>().add(EditarLibro(libro: libroEditado));

    Navigator.pop(context, libroEditado);

    setState(() {});
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
                });
              },
            ),
            if (_isPrestado)
              TextField(
                decoration: const InputDecoration(labelText: 'Prestado a'),
                controller: TextEditingController(text: _prestadoA),
                onChanged: (value) {
                  setState(() {
                    _prestadoA = value;
                  });
                },
              ),
            SwitchListTile(
              title: const Text('Marcar como leído'),
              value: _isLeido,
              onChanged: (bool value) {
                setState(() {
                  _isLeido = value;
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
                controller: TextEditingController(text: _resena),
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
        ),
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

    if(estado is Operacional) {
      libros = estado.listaLibros;
    }

    if (libros.isEmpty) { 
      return const Center( 
          child: Text('Aún no tienes libros suficientes para generar reportes :('), 
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
              ],
              onChanged: (value) {
                setState(() {
                  _criterioSeleccionado = value!;    
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () async {
                DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024, 1, 1),
                  lastDate: DateTime(2024, 12, 31),
                  initialDateRange: DateTimeRange(
                    start: DateTime(2024,1,1),
                    end: DateTime(2024,12,31),
                  ),
                );
                if(picked != null) {
                  setState(() {
                    _rangoFechas = picked;
                  });
                }
              },
            ),
            if(_rangoFechas != null)
              Text('Seleccionado: ${_rangoFechas!.start.toLocal()} - ${_rangoFechas!.end.toLocal()}'),
            const SizedBox(height: 20), // Espacio entre el dropdown y el gráfico
             
            Expanded(
              child: charts.PieChart<String>(
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
                    outsideJustification: charts.OutsideJustification.endDrawArea,
                    horizontalFirst: false,
                    desiredMaxRows: 2,
                    cellPadding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                    entryTextStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.purple.shadeDefault,
                      fontFamily: 'Georgia',
                      fontSize: 11,
                    )
                  ),
                  charts.SelectNearest(),
                  charts.DomainHighlighter(),
                ],
              ),
            )
          ],
        ),
      );
  }

  List<charts.Series<PieChartData, String>> _generarDatosParaGrafica(List<Libro> libros) {
    // Filtrar libros por rango de fechas si se ha seleccionado 
    if (_rangoFechas != null) { 
      libros = libros.where((libro) { 
      final fechaPublicacion = DateTime.parse(libro.fechaPublicacion); 
      return fechaPublicacion.isAfter(_rangoFechas!.start) && fechaPublicacion.isBefore(_rangoFechas!.end); 
      }).toList(); 
    }

    if (_criterioSeleccionado == 'Género que más se repite') { 
      // Generar datos para la gráfica de pastel basada en el conteo de géneros 
      Map<String, int> conteoGeneros = {}; 
      for (var libro in libros) { 
        conteoGeneros.update(libro.genero, (value) => value + 1, ifAbsent: () => 1); 
      } 

      final data = conteoGeneros.entries .map((entry) => PieChartData(entry.key, entry.value.toDouble())) .toList(); 
      return [ charts.Series<PieChartData, String>(
         id: 'Géneros Repetidos', 
         data: data, 
         domainFn: (PieChartData entry, _) => entry.genero, 
         measureFn: (PieChartData entry, _) => entry.promedio, 
         labelAccessorFn: (PieChartData entry, _) => '${entry.genero}: ${entry.promedio.toStringAsFixed(1)}', 
         ), 
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
        conteoGeneros.update(libro.genero, (value) => value + 1, ifAbsent: () => 1);
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
        labelAccessorFn: (PieChartData entry, _) =>'${entry.genero}: ${entry.promedio.toStringAsFixed(1)}',
      ),
    ];
  }
}



class PieChartData {
    final String genero;
    final double promedio;

    PieChartData(this.genero, this.promedio);
  }