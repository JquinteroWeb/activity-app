import 'package:activity_app/screens/activity_screen.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:activity_app/models/token.dart';
import 'package:activity_app/models/response.dart';
import 'package:activity_app/components/loader_component.dart';
import 'package:activity_app/models/activities.dart';
import 'package:activity_app/helpers/api_helper.dart';
import 'package:activity_app/screens/time_screen.dart';
import 'package:intl/intl.dart';

class ActivitiesScreen extends StatefulWidget {
  final Token token;

  const ActivitiesScreen({super.key, required this.token});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Activities> _activities = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
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

  Future<Null> _getActivities() async {
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

    Response response = await ApiHelper.getActivities(widget.token);

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
      _activities = response.result;
    });
  }

  Widget _getContent() {
    return _activities.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay actividades con ese criterio de búsqueda.'
              : 'No hay actividades registradas.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getActivities,
      child: ListView(
        children: _activities.map((e) {
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
                          e.description,
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
                const Text('Escriba las primeras letras de la actividad'),
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
    _getActivities();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Activities> filteredList = [];
    for (var brand in _activities) {
      if (brand.description.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(brand);
      }
    }

    setState(() {
      _activities = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ActivityScreen(
        token: widget.token,
        activities: Activities(
            description: '', status: false, usersId: widget.token.idUser),
      );
    }));
    if (result == 'yes') {
      _getActivities();
    }
  }

  void _goEdit(Activities activities) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityScreen(
          token: widget.token,
          activities: activities,
        ),
      ),
    );
    if (result == 'yes') {
      _getActivities();
    }
  }
}
