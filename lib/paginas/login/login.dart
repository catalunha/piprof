import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/naosuportato/permission_handler.dart'
    if (dart.library.io) 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  final AuthBloc authBloc;

  LoginPage(this.authBloc);

  @override
  LoginPageState createState() {
    return LoginPageState(this.authBloc);
  }
}

class LoginPageState extends State<LoginPage> {
  // PermissionStatus _status;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthBloc authBloc;

  LoginPageState(this.authBloc);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  void _checkPermission() async {
    var a = PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    await a.then(_updateStatus);
  }

  FutureOr _updateStatus(PermissionStatus value) {
    if (value == PermissionStatus.denied) {
      _askPermission();
    }
  }

  _askPermission() async {
    var a = PermissionHandler().requestPermissions([
      PermissionGroup.storage,
    ]);
    await a.then(_onStatusRequested);
  }

  FutureOr _onStatusRequested(Map<PermissionGroup, PermissionStatus> value) {
    _updateStatus(value[PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Center(
                          child: Text(
                            'PI - Prof',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: TextFormField(
                          onSaved: (email) {
                            authBloc.dispatch(UpdateEmailAuthBlocEvent(email));
                          },
                          decoration: InputDecoration(
                            hintText: "Informe seu email",
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: TextFormField(
                          onSaved: (password) {
                            authBloc.dispatch(
                                UpdatePasswordAuthBlocEvent(password));
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Informe sua senha",
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: RaisedButton(
                          child: Text("Acessar",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black)),
                          color: Colors.green,
                          onPressed: () {
                            _formKey.currentState.save();
                            authBloc.dispatch(LoginAuthBlocEvent());
                            // authBloc.perfil.listen((usuarioModel) {
                            //   if (!usuarioModel.professor) {
                            //     print('Usuario logout: ${usuarioModel.nome} é professor: ${usuarioModel.professor}');
                            //     authBloc.dispatch(LogoutAuthBlocEvent());
                            //   }
                            // });
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //     vertical: 12,
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                              'Eita. Esqueci a senha!\nInforme seu email e click...',
                              style: TextStyle(color: Colors.green[600])),
                          trailing: IconButton(
                            tooltip:
                                'Um pedido de nova senha será enviado a seu email.',
                            icon: Icon(Icons.vpn_key, color: Colors.green[600]),
                            onPressed: () {
                              _formKey.currentState.save();
                              authBloc.dispatch(ResetPassword());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Image.asset('assets/imagem/logo.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
