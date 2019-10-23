import 'package:flutter/material.dart';
import 'package:marcador_truco/models/player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _changeName = TextEditingController();
  var _playerOne = Player(name: "Time 1", score: 0, victories: 0);
  var _playerTwo = Player(name: "Time 2", score: 0, victories: 0);
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _resetPlayers();
  }

  void _resetPlayer({Player player, bool resetVictories = true}) {
    setState(() {
      player.score = 0;
      if (resetVictories) player.victories = 0;
    });
  }

  void _resetPlayers({bool resetVictories = true}) {
    _resetPlayer(player: _playerOne, resetVictories: resetVictories);
    _resetPlayer(player: _playerTwo, resetVictories: resetVictories);
  }

  void _resetPoints() {
    _resetPlayer(player: _playerOne, resetVictories: false);
    _resetPlayer(player: _playerTwo, resetVictories: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[400],
        title: Text("Marcador de Truco"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Zerar',
                  message:
                      'Tem certeza que deseja começar novamente a pontuação?',
                  confirm: () {
                    _resetPlayers();
                  });
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Zerar Pontos',
                  message:
                      'Deseja zerar os pontos ? Obs.: As vitórias nãos erão zeradas.',
                  confirm: () {
                    _resetPoints();
                  });
            },
            icon: Icon(Icons.restore),
          ),
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Resetar Nomes',
                  message: 'Deseja resetar os nomes de volta ao padrão?',
                  confirm: () {
                    setState(() {
                      _playerOne.name = 'Time 1';
                      _playerTwo.name = 'Time 2';
                    });
                  });
            },
            icon: Icon(Icons.restore),
          ),
        ],
      ),
      body: Container(padding: EdgeInsets.all(20.0), child: _showPlayers()),
    );
  }

  Widget _showPlayerBoard(Player player) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _showPlayerName(player.name, () {
            _showPlayerNameDialog(
                title: '${player.name}',
                message: 'Escolha um novo nome:',
                confirm: () {
                  setState(() {
                    player.name = _changeName.text;
                  });
                },
                cancel: () {});
          }),
          _showPlayerScore(player.score),
          _showPlayerVictories(player.victories),
          _showScoreButtons(player),
        ],
      ),
    );
  }

  Widget _showPlayers() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _showPlayerBoard(_playerOne),
        _showPlayerBoard(_playerTwo),
      ],
    );
  }

  Widget _showPlayerName(String name, Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
            color: Colors.purple[400]),
      ),
    );
  }

  Widget _showPlayerVictories(int victories) {
    return Text(
      "Vitórias: $victories",
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _showPlayerScore(int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52.0),
      child: Text(
        "$score",
        style: TextStyle(fontSize: 120.0),
      ),
    );
  }

  Widget _buildRoundedButton(
      {String text, double size = 70.0, Color color, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          color: color,
          height: size,
          width: size,
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget _showScoreButtons(Player player) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildRoundedButton(
          text: '-',
          color: Colors.black.withOpacity(0.1),
          onTap: _isButtonDisabled == true
              ? null
              : () {
                  if (player.score <= 0) {
                    _isButtonDisabled = true;
                    return;
                  }
                  setState(() {
                    player.score--;
                  });
                },
        ),
        _buildRoundedButton(
          text: '+',
          color: Colors.purple[600],
          onTap: () {
            if (player.score > 0) {
              _isButtonDisabled = false;
            }
            setState(() {
              player.score++;
            });

            if (_playerOne.score == 11 && _playerTwo.score == 11) {
              _showDialog(
                  title: 'Mão de ferro',
                  message:
                      'Todos os jogadores devem virar as cartas viradas para baixo. Quem vencer a mão, vence a partida.',
                  confirm: () {},
                  cancel: () {
                    setState(() {
                      player.score--;
                    });
                  });
            }

            if (player.score == 12) {
              _showDialog(
                  title: 'Fim do jogo',
                  message: '${player.name} ganhou (ganharam)!',
                  confirm: () {
                    setState(() {
                      player.victories++;
                      player.score = 0;
                    });
                  },
                  cancel: () {
                    setState(() {
                      player.score--;
                    });
                  });
            }
          },
        ),
      ],
    );
  }

  void _showDialog(
      {String title, String message, Function confirm, Function cancel}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm != null) confirm();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancel != null) cancel();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPlayerNameDialog(
      {String title, String message, Function confirm, Function cancel}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: _renderForm(),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm != null) confirm();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancel != null) cancel();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _renderForm() {
    return TextFormField(
      controller: _changeName,
      decoration: InputDecoration(labelText: 'Edite o nome do time:'),
    );
  }
}
