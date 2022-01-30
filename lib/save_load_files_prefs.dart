import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FilesPrefsScreen extends StatelessWidget {
  const FilesPrefsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Записываем из файла и shared preferences',
      home: FlutterDemo(storage: CounterStorage(),
      ),
    );
  }
}


//Начало CounterStorage
class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}
//конец CounterStorage


class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;
  int _counterSh = 0;

  @override
  void initStateSh() {
    super.initState();
    _loadCounterSh();
  }
//Loading counter value on start
  void _loadCounterSh() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterSh = (prefs.getInt('counter') ?? 0);
    });
  }

  //Incrementing counter after click
  void _incrementCounterSh() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterSh = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counterSh);
    });
  }

  //Начало инициализации
  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранение и загрузка данных'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _incrementCounter, child: const Text('Добавить через файл'),),
            Center(
              child: Text(
                'Кнопку нажали $_counter раз(а) используя файл${_counter == 1 ? '' : ''}.',
              textScaleFactor: 1.1,
              ),
            ),
            const Padding(padding: EdgeInsets.all(50.0)),
            ElevatedButton(onPressed: _incrementCounterSh, child: const Text('Добавить через shared preferences'),),
            Center(
              child: Text(
                'Кнопку нажали $_counterSh раз(а) используя shared preferences${_counterSh == 1 ? '' : ''}.',
                  textScaleFactor: 1.1,),
            ),
          ],
        ),
      ),
    );
  }
}