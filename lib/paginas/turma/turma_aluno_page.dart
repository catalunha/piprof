import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/turma/turma_aluno_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart' if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class TurmaAlunoPage extends StatefulWidget {
  final String turmaID;

  const TurmaAlunoPage(this.turmaID);

  @override
  _TurmaAlunoPageState createState() => _TurmaAlunoPageState();
}

class _TurmaAlunoPageState extends State<TurmaAlunoPage> {
  TurmaAlunoBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaAlunoBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTurmaEvent(widget.turmaID));
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar alunos'),
      ),
      floatingActionButton: StreamBuilder<TurmaAlunoBlocState>(
          stream: bloc.stateStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return FloatingActionButton(
              onPressed: snapshot.data.isDataValid
                  ? () {
                      bloc.eventSink(CadastrarAlunoEvent());
                      Navigator.pop(context);
                    }
                  : null,
              child: Icon(Icons.cloud_upload),
              backgroundColor: snapshot.data.isDataValid ? Colors.blue : Colors.grey,
            );
          }),
      body: StreamBuilder<TurmaAlunoBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TurmaAlunoBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.pedidoRelatorio != null) {
            launch(
                'https://us-central1-pi-brintec.cloudfunctions.net/relatorioOnRequest/listadealunosdaturma?pedido=${snapshot.data.pedidoRelatorio}');
            bloc.eventSink(ResetCreateRelatorioEvent());
          }
          return ListView(
            children: <Widget>[
              ListTile(
                trailing: Icon(Icons.assignment_ind),
                title: Text('Lista de alunos'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/turma/aluno/list",
                    arguments: widget.turmaID,
                  );
                },
              ),
              ListTile(
                trailing: Icon(Icons.grid_on),
                title: Text('Lista de alunos em planilha'),
                onTap: () {
                  bloc.eventSink(CreateRelatorioEvent(widget.turmaID));
                },
              ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Informe a lista de alunos a serem cadastrados.\nUsando o ponto e vírgula para separar as informações.\nUse o formato:\nmatricula ; email ; nome completo do aluno',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: CadastrarAluno(bloc)),
              ListTile(
                trailing: Icon(Icons.thumbs_up_down),
                title: Text('Click aqui para conferir a lista antes de cadastrar'),
                onTap: () {
                  bloc.eventSink(UpdateAnalisarListaDeAlunosEvent());
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      elevation: 5,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            title: Text("Lista após análise. Se estiver consistente pode enviar para cadastro."),
                          ),
                          for (var item in snapshot.data.listaDeAlunos)
                            ListTile(
                              title: Text('Mat.: ${item[0]}\nemail: ${item[1]}\nNome: ${item[2]}'),
                            ),
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                padding: EdgeInsets.only(top: 70),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 123; abc@gmail.com; aaa bbb ccc
// 456; def@gmail.com; ddd eee fff

//
// ;
// 123; abc@gmail.com; aaa bbb ccc
// ;;;;;;
// ;;
// 456; def@gmail.com; ddd eee fff
// 789; def#gmail.com; ddd eee fff
// 1;@;aaa
//
//

class CadastrarAluno extends StatefulWidget {
  final TurmaAlunoBloc bloc;
  CadastrarAluno(this.bloc);
  @override
  CadastrarAlunoState createState() {
    return CadastrarAlunoState(bloc);
  }
}

class CadastrarAlunoState extends State<CadastrarAluno> {
  final _textFieldController = TextEditingController();
  final TurmaAlunoBloc bloc;
  CadastrarAlunoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaAlunoBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TurmaAlunoBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.cadastro;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateListaDeAlunosEvent(text));
          },
        );
      },
    );
  }
}
