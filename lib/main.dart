import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blue[300],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(color: Colors.blueAccent[300]),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent[300],
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Função que irá retorna o arquivo que irá ser usado para salvar
  Future<File> _getFile() async {
    // Importando os diretorios
    final directory = await getApplicationDocumentsDirectory();

    // Retornando os arquivos
    return File('${directory.path}/data.json');
  }

// Função para salvar os dados
  Future<File> _saveData() async {
    // Transforma a lista em um jSON
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  // Função para obter os dados
  Future<String> _readData() async {
    // Verificando o arquivo
    try {
      final file = await _getFile();
    } catch (e) {
      return null;
    }
  }
}
