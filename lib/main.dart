import 'dart:convert';


import 'package:app_libros/blocs/bloc.dart';
import 'package:app_libros/modelos/libro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      home: BlocProvider(
        create: (context) => AppBloc()..add(Inicializado()),
        child: const BarraNavegacion(),
      ),
    );
  }
}

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {


  List books = [];
  TextEditingController searchController = TextEditingController();


  Future<void> buscarLibros(String query) async {
    const apiKey ='AIzaSyANoCFakFV-D0QXg8hQbeKvdlMKxaVH8z8';
    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        books = data ['items'];
      });
    } 
    else {
      print('Error en la solicitud : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Libros'),
      ),
      body:  Column(
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
                final isbnList = libro['industryIdentifiers']?.map((id) => id['identifier']).toList() ?? ['No ISBN'];
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
                  subtitle: Text(libro['authors']?.join(', ') ?? 'Autor desconocido'),
                  trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ISBN: ${isbnList.join(', ')}'),
                    Text('Páginas: $pageCount'),
                  ],
                  ),
                );
              },
            ),
          )
        ],
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
        return  'Unknown';
    }
  }
  
  final List<Widget> _paginas = [
    const PantallaBuscar(),
    const PantallaMisLibros(),
    const PantallaReportes(),
  ];


  @override
  Widget build(BuildContext context) {
    var estado = context.watch<AppBloc>().state;
    
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(obtenerTitulo()),
      ),
      body: _paginas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
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
    const apiKey ='AIzaSyANoCFakFV-D0QXg8hQbeKvdlMKxaVH8z8';
    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        books = data ['items'];
      });
    } 
    else {
      print('Error en la solicitud : ${response.statusCode}');
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
                final isbnList = libro['industryIdentifiers']?.map((id) => id['identifier']).toList() ?? ['No ISBN'];
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
                  subtitle: Text(libro['authors']?.join(', ') ?? 'Autor desconocido'),
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
                      )
                    );
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
    final isbnLista = libro['industryIdentifiers']?.map((id) => id['identifier']).toList() ?? ['No ISBN'];
    final pageCount = libro['pageCount']?.toString() ?? 'N/A';
    final imageUrl = libro['imageLinks']?['thumbnail'] ?? '';
    final isbn = libro['isbn'] ?? 'Desconocido'; 
    final titulo = libro['title'] ?? 'Sin título';
    final autor = libro['authors']?.join(', ') ?? 'Autor desconocido'; 
    const genero = 'Horror'; 
    final portadaUrl = imageUrl; 
    final fechaPublicacion = DateTime.now(); 
    final totalPaginas = int.tryParse(pageCount) ?? 0;
   
   
   
    void agregarLibro(String isbn, String titulo, String autor, String genero, String portadaUrl, DateTime fechaPublicacion, int rating, String critica, bool esPrestado, String? prestadoA, String? prestadoDe, DateTime? fechaPrestacion, DateTime? fechaRegreso, DateTime? fechaLectura, int totalPaginas) {
      context.read<AppBloc>().add(AgregarLibro(
        isbn: isbn, 
        titulo: titulo, 
        genero: genero, 
        autor: autor, 
        portadaUrl: portadaUrl, 
        fechaPublicacion: fechaPublicacion, 
        rating: rating, 
        critica: critica, 
        esPrestado: esPrestado, 
        prestadoA: prestadoA, 
        prestadoDe: prestadoDe, 
        fechaPrestacion: fechaPrestacion, 
        fechaRegreso: fechaRegreso, 
        fechaLectura: fechaLectura, 
        totalPaginas: totalPaginas));
    }


    return  Scaffold(
      appBar: AppBar(
        title: Text(libro['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty ? Image.network(imageUrl) : const Icon(Icons.book, size: 100), 
            const SizedBox(height: 16), 
            Text('Título: ${libro['title']}', style: const TextStyle(fontSize: 18)), 
            const SizedBox(height: 8), 
            Text('Autor: ${libro['authors']?.join(', ') ?? 'Autor desconocido'}', style: const TextStyle(fontSize: 18)), 
            const SizedBox(height: 8), 
            Text('ISBN: ${isbnLista.join(', ')}', style: const TextStyle(fontSize: 18)), 
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
              return  Container(
                padding: const EdgeInsets.all(16.0),
                child:  AgregarModal(
                  isbn: isbn, 
                  titulo: titulo, 
                  autor: autor, 
                  genero: genero, 
                  portadaUrl: portadaUrl, 
                  fechaPublicacion: fechaPublicacion, 
                  totalPaginas: totalPaginas,
                ),
              );
            }
          );
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

  const AgregarModal({super.key, required this.isbn, required this.titulo, required this.autor, required this.genero, required this.portadaUrl, required this.fechaPublicacion, required this.totalPaginas});

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
    if(picked != null && picked != _fechaSeleccionada){
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  
    void guardarLibro() {
      print('agregar libroooo');
      context.read<AppBloc>().add(AgregarLibro(
          // isbn: libro.libro['isbn'], 
          // titulo: libro.libro['title'], 
          // genero: 'Horror', 
          // autor: libro.libro['authors']?.join(',') ?? 'Autor desconocido', 
          // portadaUrl: libro.libro['imageLinks']?['thumbnail'] ?? '', 
          // fechaPublicacion: DateTime.parse(libro.libro['publishedDate'] ?? DateTime.now().toString()), 
          // rating: _rating, 
          // critica: _resena, 
          // esPrestado: _isPrestado, 
          // prestadoA: _isPrestado ? _prestadoA : null, 
          // prestadoDe: null, 
          // fechaPrestacion: _isPrestado ? DateTime.now() : null, 
          // fechaRegreso: _isPrestado ? DateTime.now().add(const Duration(days: 30)) : null, 
          // fechaLectura: _isLeido ? _fechaSeleccionada : null, 
          // totalPaginas: int.tryParse(libro.libro['pageCount']?.toString() ?? '0') ?? 0
          isbn: '1234567890', titulo: 'Título del libro', autor: 'Autor del libro', genero: 'Género', portadaUrl: 'URL de la portada', fechaPublicacion: DateTime.now(), rating: 5, critica: 'Buena crítica', esPrestado: false, prestadoA: null, prestadoDe: null, fechaPrestacion: null, fechaRegreso: null, fechaLectura: null, totalPaginas: 300
          )
          
      );
    Navigator.pop(context);
  }






    return  Container(
      padding: const EdgeInsets.all(16.0),
      child:  SingleChildScrollView(
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
            if(_isPrestado) 
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
            if(_isLeido) ...[
              ListTile(
                title: const Text('Fecha de lectura'),
                subtitle: Text(
                _fechaSeleccionada == null 
                ? 'Selecciona una fecha' 
                : DateFormat.yMMMd().format(_fechaSeleccionada!)
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => seleccionarFecha(context),
              ),
              ListTile(
                title: const Text('Calificar libro'),
                subtitle: Text('$_rating/10'),
                trailing: DropdownButton<int>(
                  value: _rating,
                  items:  
                    List.generate(10, (index) => index + 1)
                    .map((value) =>DropdownMenuItem<int>(
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
              onPressed: guardarLibro,
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

  
  @override
  Widget build(BuildContext context) {
    List<Libro> libros = [];

    var estado = context.watch<AppBloc>().state;

    if(estado is Inicial){
      return const Center(child: CircularProgressIndicator());
    }

    if(estado is Operacional){
      libros = (estado).listaLibros.cast<Libro>();
      
    }

    if(libros.isEmpty){
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aun no tienes libros :(')
          ],
        ),
      );
    }

    
    
    

    BlocBuilder<AppBloc, AppEstado>(
      builder: (context, state) {
          return Expanded(
            child: ListView.builder(
              itemCount: libros.length,
              itemBuilder: (context, index) {
                final libro = libros[index];
                return ListTile(
                  leading: libro.portadaUrl.isNotEmpty 
                  ? Image.network(libro.portadaUrl, width: 50, fit: BoxFit.cover)
                  : const Icon(Icons.book),
                  title: Text(libro.titulo),
                  subtitle: Text(libro.autor),
                  onTap: () {
                    
                  },
                );
              },
            ),
          );
      },
    );





    return const Text('Hola desde mis libros');
  }
}

// Pantalla Reportes

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  @override
  Widget build(BuildContext context) {
    return const Text('Hola desde reportes');
  }
}