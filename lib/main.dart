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
  final _toDoController = TextEditingController();

  List _toDoList = [];

  // Método que ira criar um override que irá sobrescreve a aplicação toda vez que abri ela
  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  // Função da adicionar uma tarefa
  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo['title'] = _toDoController.text;
      _toDoController.text = '';
      newToDo['ok'] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blue,
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
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(
                    _toDoList[index]['title'],
                  ),
                  value: _toDoList[index]['ok'],
                  secondary: CircleAvatar(
                    child: Icon(
                      _toDoList[index]['ok'] ? Icons.check : Icons.error,
                    ),
                  ),
                  onChanged: (c) {
                    setState(() {
                      _toDoList[index]['ok'] = c;
                      _saveData();
                    });
                  },
                );
              },
            ),
          ),
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

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
