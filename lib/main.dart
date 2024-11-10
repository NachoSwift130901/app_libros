import 'dart:convert';

import 'package:app_libros/blocs/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionInyectada());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'API Demo',
      
      home: BookSearchPage(),
    );
  }
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
  const BarraNavegacion({super.key});

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

class PantallaBuscar extends StatelessWidget {
  const PantallaBuscar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hola');
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