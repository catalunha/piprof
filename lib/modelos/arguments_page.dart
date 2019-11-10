class EncontroCRUDPageArguments {
  final String turmaID;
  final String encontroID;

  EncontroCRUDPageArguments({this.turmaID, this.encontroID});
}

class AvaliacaoCRUDPageArguments {
  final String turmaID;
  final String avaliacaoID;

  AvaliacaoCRUDPageArguments({this.turmaID, this.avaliacaoID});
}

class QuestaoCRUDPageArguments {
  final String avaliacaoID;
  final String questaoID;

  QuestaoCRUDPageArguments({this.avaliacaoID, this.questaoID});
}

class SituacaoCRUDPageArguments {
  final String pastaID;
  final String situacaoID;

  SituacaoCRUDPageArguments({this.pastaID, this.situacaoID});
}

class SimulacaoCRUDPageArguments {
  final String situacaoID;
  final String simulacaoID;

  SimulacaoCRUDPageArguments({this.situacaoID, this.simulacaoID});
}

class SimulacaoVariavelCRUDPageArguments {
  final String simulacaoID;
  final String variavelKey;

  SimulacaoVariavelCRUDPageArguments({this.simulacaoID, this.variavelKey});
}
class SimulacaoPedeseCRUDPageArguments {
  final String simulacaoID;
  final String pedeseKey;

  SimulacaoPedeseCRUDPageArguments({this.simulacaoID, this.pedeseKey});
}
