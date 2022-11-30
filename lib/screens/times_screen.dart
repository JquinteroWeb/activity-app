import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:activity_app/models/token.dart';
import 'package:activity_app/models/response.dart';
import 'package:activity_app/components/loader_component.dart';
import 'package:activity_app/models/times.dart';
import 'package:activity_app/helpers/api_helper.dart';
import 'package:activity_app/screens/time_screen.dart';
import 'package:intl/intl.dart';

class TimesScreen extends StatefulWidget {
  final Token token;

  const TimesScreen({super.key, required this.token});

  @override
  _TimesScreenState createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  List<Times> _times = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiempos'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: const Icon(Icons.filter_none))
              : IconButton(
                  onPressed: _showFilter, icon: const Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getTimes() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getTimes(widget.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    setState(() {
      _times = response.result;
    });
  }

  Widget _getContent() {
    return _times.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay tiempos con ese criterio de búsqueda.'
              : 'No hay tiempos registradas.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getTimes,
      child: ListView(
        children: _times.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.observation,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text('Filtrar Tiempos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Escriba las primeras letras del tiempo'),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'Criterio de búsqueda...',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    _search = value;
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => _filter(), child: const Text('Filtrar')),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getTimes();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Times> filteredList = [];
    for (var brand in _times) {
      if (brand.observation.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(brand);
      }
    }

    setState(() {
      _times = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      var now = DateTime.now();
      String dateTime = DateFormat('yyyy-MM-dd').format(now);
      return TimeScreen(
        token: widget.token,
        times: Times(
            timesId: 0,
            activitiesId: 0,
            date: dateTime.toString(),
            observation: '',
            timeWork: 0),
      );
    }));
    if (result == 'yes') {
      _getTimes();
    }
  }

  void _goEdit(Times times) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeScreen(
          token: widget.token,
          times: times,
        ),
      ),
    );
    if (result == 'yes') {
      _getTimes();
    }
  }
}
