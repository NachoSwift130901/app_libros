import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
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