import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/turma/turma_aluno_bloc.dart';

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
                      bloc.eventSink(SaveEvent());
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
          return ListView(
            children: <Widget>[
              ListTile(
                trailing: Icon(Icons.person_pin_circle),
                title: Text('Alunos e notas'),
              ),
              ListTile(
                trailing: Icon(Icons.recent_actors),
                title: Text('Lista de alunos em planilha'),
                onTap: () {
                  bloc.eventSink(NotaListEvent(widget.turmaID));
                },
              ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Cole a seguir a lista de alunos para esta turma no formato:\nmatricula ; email ; nome completo\nusando o ponto e a vírgula para separar as informações.',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: CadastrarAluno(bloc)),
            ],
          );
        },
      ),
    );
  }
}

// 123; abc@gmail.com; aaa bbb ccc
// 456; def@gmail.com; ddd eee fff

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
            bloc.eventSink(GetCadastrarAlunoEvent(text));
          },
        );
      },
    );
  }
}
