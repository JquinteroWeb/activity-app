import 'dart:ffi';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:activity_app/models/token.dart';
import 'package:activity_app/models/response.dart';
import 'package:activity_app/components/loader_component.dart';
import 'package:activity_app/models/activities.dart';
import 'package:activity_app/helpers/api_helper.dart';

class ActivityScreen extends StatefulWidget {
  final Token token;
  final Activities activities;

  const ActivityScreen(
      {super.key, required this.token, required this.activities});

  @override
  // ignore: library_private_types_in_public_api
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _showLoader = false;
  String _activitiesId = '';
  String _description = '';
  bool _status = false;
  String _userId = '';

  String _descriptionError = '';
  bool _descriptionShowError = false;

  String _statusError = '';
  bool _statusShowError = false;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _description = widget.activities.description.toString();
    _status = widget.activities.status;
    _userId = widget.activities.usersId.toString();
    _activitiesId = widget.activities.activitiesId.toString();
    _descriptionController.text = _description;
    _statusController.text = _status ? 'Incompleta' : 'Completa';
    _userIdController.text = _userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activities.activitiesId == 0
            ? 'Registrar actividad'
            : widget.activities.description),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _showDescription(),
              _showStatus(),
              _showUserId(),
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

  Widget _showDescription() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: 'Descripción...',
          labelText: 'Descripción',
          errorText: _descriptionShowError ? _descriptionError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _description = value;
        },
      ),
    );
  }

  Widget _showStatus() {
    var status = [
      const DropdownMenuItem(value: true, child: Text("Completado")),
      const DropdownMenuItem(value: false, child: Text("Incompleto")),
    ];

    return DropdownButton(
      value: _status,
      items: status,
      onChanged: (value) {
        _status = value!;
      },
    );
  }

  Widget _showUserId() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _userIdController,
        decoration: InputDecoration(
          enabled: false,
          labelText: 'Id Usuario',
          suffixIcon: const Icon(Icons.password),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _userId = value;
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
          widget.activities.activitiesId == 0
              ? Container()
              : const SizedBox(
                  width: 20,
                ),
          widget.activities.activitiesId == 0
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

    widget.activities.activitiesId == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_description.isEmpty) {
      isValid = false;
      _descriptionShowError = true;
      _descriptionError = 'Debes ingresar una descripción.';
    } else {
      _descriptionShowError = false;
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
      'description': _description,
      'status': _status,
      'usersId': _userId,
    };

    Response response =
        await ApiHelper.post('/api/Activities/', request, widget.token);

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
      'activitiesId': _activitiesId,
      'description': _description,
      'status': _status,
      'usersId': _userId,
    };

    Response response = await ApiHelper.put(
        '/api/Activities/', _activitiesId, request, widget.token);

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
        await ApiHelper.delete('/api/Activities/', _activitiesId, widget.token);

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
          title: 'Error ${widget.activities.activitiesId}',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }
  }
}
