import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:queries/collections.dart';
import 'package:universal_io/io.dart';
import 'package:piprof/naosuportato/open_file.dart' if (dart.library.io) 'package:open_file/open_file.dart';
import 'package:piprof/naosuportato/path_provider.dart' if (dart.library.io) 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;

class GenerateCsvService {
  // PUBLIC
  static generateCsvFromUsuarioAndNote(UsuarioModel usuario) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();
    planilha.add(['Usuario', 'Valor']);
    planilha.add(['id', '${usuario.id}']);
    planilha.add(['ativo', '${usuario.ativo}']);
    planilha.add(['nome', '${usuario.nome}']);
    planilha.add(['matricula', '${usuario.matricula}']);
    planilha.add(['email', '${usuario.email}']);
    planilha.add(['cracha', '${usuario.cracha}']);
    planilha.add(['celular', '${usuario.celular}']);
    planilha.add(['foto', '=IMAGE("${usuario.foto.url}")']);

    List<TarefaModel> tarefaList = List<TarefaModel>();

    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(TarefaModel.collection)
        .where("aluno.id", isEqualTo: usuario.id)
        // .where("ativo", isEqualTo: true)
        .getDocuments();

    Map<String, Variavel> variavelMap = Map<String, Variavel>();
    Map<String, Pedese> pedeseMap = Map<String, Pedese>();

    planilha.add(['Avaliação', 'Questão', 'Item', 'Valor']);
    for (var tarefaDocSnapshot in futureQuerySnapshot.documents) {
      TarefaModel tarefa = TarefaModel(id: tarefaDocSnapshot.documentID).fromMap(tarefaDocSnapshot.data);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'id', '${tarefa.id}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'aberta', '${tarefa.aberta}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'ativa', '${tarefa.ativo}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'avaliacao', '${tarefa.avaliacao.nome}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'questao', '${tarefa.questao.numero}']);
      planilha
          .add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'situacao nome', '${tarefa.situacao.nome}']);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'situacao arquivo',
        '=HYPERLINK("${tarefa.situacao.url}";"Link para o arquivo")'
      ]);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'tempo', '${tarefa.tempo}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'tentativa', '${tarefa.tentativa}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'tentou', '${tarefa.tentou}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'inicio', '${tarefa.inicio}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'iniciou', '${tarefa.iniciou}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'enviou', '${tarefa.enviou}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'fim', '${tarefa.fim}']);
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'modificado', '${tarefa.modificado}']);

      var dicVariavel = Dictionary.fromMap(tarefa.variavel);
      var variavelOrdered =
          dicVariavel.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
      variavelMap.clear();
      variavelMap = variavelOrdered.toMap();

      for (var variavel in variavelMap.entries) {
        print(variavel.key);
        planilha
            .add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'variavel nome', '${variavel.value.nome}']);
        planilha
            .add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'variavel valor', '${variavel.value.valor}']);
      }

      var dicPedese = Dictionary.fromMap(tarefa.pedese);
      var pedeseOrderBy = dicPedese.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
      pedeseMap.clear();
      pedeseMap = pedeseOrderBy.toMap();
      String nota = '=';
      for (var pedese in pedeseMap.entries) {
        print(pedese.key);

        nota = nota + '+${pedese.value.nota}';
        planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'pedese nome', '${pedese.value.nome}']);
        if (pedese.value.tipo == 'numero' || pedese.value.tipo == 'palavra' || pedese.value.tipo == 'texto') {
          planilha.add(
              ['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'pedese resposta', '${pedese.value.resposta}']);
        } else if (pedese.value.tipo == 'imagem') {
          planilha.add([
            '${tarefa.avaliacao.nome}',
            '${tarefa.questao.numero}',
            'pedese resposta',
            '=IMAGE("${pedese.value.resposta}")',
          ]);
        } else if (pedese.value.tipo == 'arquivo' || pedese.value.tipo == 'url') {
          planilha.add([
            '${tarefa.avaliacao.nome}',
            '${tarefa.questao.numero}',
            'pedese resposta',
            '=HYPERLINK("${pedese.value.resposta}","Link para o arquivo")'
          ]);
        }
        planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'pedese nota', '${pedese.value.nota}']);
      }
      planilha.add(['${tarefa.avaliacao.nome}', '${tarefa.questao.numero}', 'notaTotal', '$nota']);
    }
// print(planilha.toList());
    String csvData = ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioModel\n$csvData\n--- generateCsvFromUsuarioModel');
    // _saveFileAndOpen(csvData);
  }

  static generateCsvFromUsuarioListDaTurma(TurmaModel turma) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();

    planilha.add(['Turma', 'Valor']);
    planilha.add(['id', '${turma.id}']);
    planilha.add(['ativo', '${turma.ativo}']);
    planilha.add(['nome', '${turma.nome}']);
    planilha.add(['instituicao', '${turma.instituicao}']);
    planilha.add(['componente', '${turma.componente}']);
    planilha.add(['descricao', '${turma.descricao}']);
    planilha.add(['questoes', '${turma.questaoNumeroAdicionado - turma.questaoNumeroExcluido}']);

    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(UsuarioModel.collection)
        // .where("ativo", isEqualTo: true)
        .where("turmaList", arrayContains: turma.id)
        .getDocuments();

    planilha.add([
      'foto',
      'nome',
      'matricula',
      'email',
      'celular',
      'cracha',
    ]);
    for (var usuarioDocSnapshot in futureQuerySnapshot.documents) {
      UsuarioModel usuario = UsuarioModel(id: usuarioDocSnapshot.documentID).fromMap(usuarioDocSnapshot.data);
      planilha.add([
        '=IMAGE("${usuario.foto.url}")',
        '${usuario.nome}',
        '${usuario.matricula}',
        '${usuario.email}',
        '${usuario.celular}',
        '${usuario.cracha}',
      ]);
    }

// print(planilha.toList());
    String csvData = ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    print('+++ generateCsvFromUsuarioListDaTurma\n$csvData\n--- generateCsvFromUsuarioListDaTurma');
    // _saveFileAndOpen(csvData);
  }

  static _saveFileAndOpen(String csvData) async {
    //gerar e salvar
    var csvDirectory = (await getExternalStorageDirectory()).path + "/";
    var fileDirectory = "$csvDirectory";
    String filename = "filename.csv";

    await _salvarArquivoCsv(csvData, filename, fileDirectory);
    await _openFileFromDirectory(filename, fileDirectory);
  }

  //PRIVATE
  static Future<File> _salvarArquivoCsv(String csvData, String filename, String fileDirectory) async {
    File csvFile = new File(fileDirectory + filename);
    await csvFile.writeAsString(csvData);
    return csvFile;
  }

  static _openFileFromDirectory(String filename, String fileDirectory) async {
    // Veja https://pub.dev/packages/open_file
    await OpenFile.open(
      fileDirectory + filename,
    );
    // await OpenFile.open(fileDirectory + filename,
    //     type:
    //         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    // await OpenFile.open(fileDirectory + filename,
    //     type:
    //         "application/vnd.ms-excel");
  }
}