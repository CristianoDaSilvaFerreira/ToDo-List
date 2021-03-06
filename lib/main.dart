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

  // Map para exclusão do ultimo elemento
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

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

  // Função que irá dar uma delayed de carregando para atulizar a lista
  Future<Null> _refresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );

    setState(() {
      _toDoList.sort((a, b) {
        if (a['ok'] && !b['ok']) {
          return 1;
        } else if (!a['ok'] && b['ok']) {
          return -1;
        } else
          return 0;
      });

      _saveData();
    });

    return null;
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
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: buildItem,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget responsavel do criar os itens da lista
  Widget buildItem(BuildContext context, int index) {
    return Card(
      elevation: 2,
      child: Dismissible(
        key: Key(
          DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
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
        ),
        onDismissed: (direction) {
          setState(() {
            // Duplicando o item que deseja remover
            _lastRemoved = Map.from(_toDoList[index]);

            // Salvando a posição removida
            _lastRemovedPos = index;

            // Removendo ele da lista
            _toDoList.removeAt(index);

            // Salvando a lista
            _saveData();

            final snack = SnackBar(
              content: Text('Tarefa \"${_lastRemoved['title']}\" removida!'),
              action: SnackBarAction(
                label: 'Desfazer',
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
              duration: Duration(seconds: 2),
            );

            // Exibindo o snackBar
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
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
