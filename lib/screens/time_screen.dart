import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:activity_app/models/token.dart';
import 'package:activity_app/models/response.dart';
import 'package:activity_app/components/loader_component.dart';
import 'package:activity_app/models/times.dart';
import 'package:activity_app/helpers/api_helper.dart';

class TimeScreen extends StatefulWidget {
  final Token token;
  final Times times;

  const TimeScreen({super.key, required this.token, required this.times});

  @override
  // ignore: library_private_types_in_public_api
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  bool _showLoader = false;

  String _observation = '';
  String _timework = '';
  String _date = '';
  String _activitiesId = '';
  String _timeId = '';
  String _observationError = '';
  bool _observationShowError = false;

  String _timeworkError = '';
  bool _timeworkShowError = false;

  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _timeworkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _activitiesIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timeId = widget.times.timesId.toString();
    _observation = widget.times.observation;
    _timework = widget.times.timeWork.toString();
    _date = widget.times.date.toString();
    _activitiesId = widget.times.activitiesId.toString();

    _dateController.text = _date;
    _observationController.text = _observation;
    _timeworkController.text = _timework;
    _activitiesIdController.text = _activitiesId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.times.activitiesId == 0
            ? 'Registrar tiempo'
            : widget.times.observation),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _showObservation(),
              _showTimeWork(),
              _showActivityId(),
              _showDate(),
              _showButtons(),
            ],
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Por favor espere...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showObservation() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _observationController,
        decoration: InputDecoration(
          hintText: 'Observación...',
          labelText: 'Observación',
          errorText: _observationShowError ? _observationError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _observation = value;
        },
      ),
    );
  }

  Widget _showTimeWork() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _timeworkController,
        decoration: InputDecoration(
          hintText: 'Ingresa el tiempo trabajado...',
          labelText: 'Tiempo(H)',
          errorText: _timeworkShowError ? _timeworkError : null,
          suffixIcon: const Icon(Icons.numbers),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _timework = value;
        },
      ),
    );
  }

  Widget _showActivityId() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _activitiesIdController,
        decoration: InputDecoration(
          hintText: 'Ingresa el id de la actividad',
          labelText: 'Id de la actividad',
          suffixIcon: const Icon(Icons.password),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _activitiesId = value;
        },
      ),
    );
  }

  Widget _showDate() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        enabled: false,
        controller: _dateController,
        decoration: InputDecoration(
          hintText: 'Ingresa la fecha...',
          labelText: 'Fecha registro',
          suffixIcon: const Icon(Icons.calendar_month),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _date = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return const Color(0xFF120E43);
                }),
              ),
              onPressed: () => _save(),
              child: const Text('Guardar'),
            ),
          ),
          widget.times.activitiesId == 0
              ? Container()
              : const SizedBox(
                  width: 20,
                ),
          widget.times.activitiesId == 0
              ? Container()
              : Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return const Color(0xFFB4161B);
                      }),
                    ),
                    onPressed: () => _confirmDelete(),
                    child: const Text('Borrar'),
                  ),
                ),
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.times.timesId == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_observation.isEmpty) {
      isValid = false;
      _observationShowError = true;
      _observationError = 'Debes ingresar una observación.';
    } else {
      _observationShowError = false;
    }

    if (_timework.isEmpty) {
      isValid = false;
      _timeworkShowError = true;
      _timeworkError = 'Debes ingresar las horas.';
    }

    setState(() {});
    return isValid;
  }

  void _addRecord() async {
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

    Map<String, dynamic> request = {
      'observation': _observation,
      'timeWork': _timework,
      'date': _date,
      'activitiesId': _activitiesId,
    };

    Response response =
        await ApiHelper.post('/api/Times/', request, widget.token);

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

    Navigator.pop(context, 'yes');
  }

  void _saveRecord() async {
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

    Map<String, dynamic> request = {
      'timesId': _timeId,
      'observation': _observation,
      'timeWork': _timework,
      'date': _date,
      'activitiesId': _activitiesId,
    };

    Response response =
        await ApiHelper.put('/api/Times/', _timeId, request, widget.token);

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

    Navigator.pop(context, 'yes');
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmación',
        message: '¿Estas seguro de querer borrar el registro?',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: 'no', label: 'No'),
          const AlertDialogAction(key: 'yes', label: 'Sí'),
        ]);

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
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

    Response response =
        await ApiHelper.delete('/api/Times/', _timeId, widget.token);

    setState(() {
      _showLoader = false;
    });
    if (response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Información:',
          message: 'Borrado correctamente',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }
    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error ${widget.times.timesId}',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }
  }
}
