import 'package:flutter/material.dart';
import 'package:appAgenda/utils/common.dart';
import 'package:appAgenda/utils/consts.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:appAgenda/home.dart';

class Agenda extends StatefulWidget {
  final String objetivo;
  final DateTime dataHora;
  final TimeOfDay hora;
  final int numLinha;
  final List<bool> semana;
  final List<String> horas;
  final List<bool> onOffPai;
  final List<bool> onOffFilho;

  Agenda(
    this.objetivo,
    this.dataHora,
    this.hora,
    this.numLinha,
    this.semana,
    this.horas,
    this.onOffPai,
    this.onOffFilho,
  );

  @override
  _MyHomePageState2 createState() => _MyHomePageState2(
        objetivo,
        dataHora,
        hora,
        numLinha,
        semana,
        horas,
        onOffPai,
        onOffFilho,
      );
}

class _MyHomePageState2 extends State<Agenda> {
  String objetivo;
  DateTime dataHora;
  TimeOfDay hora;
  int numLinha;
  int selecaoBarraNavegacao = 1;
  List<bool> semana;
  List<bool> onOffPai; // on off pai da notificação e alarme
  List<bool> onOffFilho; // on off filhos da notificação e alarme
  List<String> horas; // as horas dos filhos
  TimeOfDay horasSelecionadas = TimeOfDay.now();
  DateTime dataHoras;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  // horario da notificação e alarme q vai aparecer na tela (usa essa string pra ver q a hora mudou da anterior, alem de conseguir começar a hora com 00:00)

  _MyHomePageState2(
    this.objetivo,
    this.dataHora,
    this.hora,
    this.numLinha,
    this.semana,
    this.horas,
    this.onOffPai,
    this.onOffFilho,
  );

  @override
  Widget build(BuildContext context) {
    AppConsts.setWidthSize(MediaQuery.of(context).size.width);
    AppConsts.setHightSize(MediaQuery.of(context).size.height);

    void mudaTela() {
      /*---------------------------------------------------------------------- \
      |   Muda para a Pag1                                                     |
      \ ----------------------------------------------------------------------*/

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeApp()),
      );
    }

    void criar() {
      Firestore.instance.collection('infoAgenda').add({
        'checkList': "",
        'objetivo': objetivo,
        'dataHora': dataHora,
        'semana': {
          'dom': semana[0],
          'seg': semana[1],
          'ter': semana[2],
          'qua': semana[3],
          'qui': semana[4],
          'sex': semana[5],
          'sab': semana[6],
        },
        'horas': {
          'h1': dateFormat.parse("2021-01-01 " + horas[0] + ":00"),
          'h2': dateFormat.parse("2021-01-01 " + horas[1] + ":00"),
          'h3': dateFormat.parse("2021-01-01 " + horas[2] + ":00"),
          'h4': dateFormat.parse("2021-01-01 " + horas[3] + ":00"),
        }
      });
    }

    void alterar() {
      int numero = 0;
      Firestore.instance
          .collection('infoAgenda')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          if (numero == numLinha) {
            ds.reference.updateData({
              'objetivo': objetivo,
              'dataHora': dataHora,
              'semana': {
                'dom': semana[0],
                'seg': semana[1],
                'ter': semana[2],
                'qua': semana[3],
                'qui': semana[4],
                'sex': semana[5],
                'sab': semana[6],
              },
              'horas': {
                'h1': dateFormat.parse("2021-01-01 " + horas[0] + ":00"),
                'h2': dateFormat.parse("2021-01-01 " + horas[1] + ":00"),
                'h3': dateFormat.parse("2021-01-01 " + horas[2] + ":00"),
                'h4': dateFormat.parse("2021-01-01 " + horas[3] + ":00"),
              }
            });
          }
          numero++;
        }
      });
    }

    void deletar() {
      int numero = 0;
      Firestore.instance
          .collection('infoAgenda')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          if (numero == numLinha) {
            ds.reference.delete();
          }
          numero++;
        }
      });

      mudaTela();
    }

    Container criaDiaSemana(String letra, int numero) {
      /*---------------------------------------------------------------------- \
    |   Cria os botões dos dias da semana                                    |
    \ ----------------------------------------------------------------------*/

      return Container(
        height: AppConsts.botaoCircular,
        width: setWidth(AppConsts.botaoCircular - 1),
        padding: EdgeInsets.only(left: 2, right: 2),
        child: FloatingActionButton.extended(
          label: Text("$letra"),
          heroTag: "btnDias$numero",
          onPressed: () {
            setState(() {
              semana[numero] = !semana[numero];
            });
          },
          backgroundColor: AppConsts.corBotaoSemana(semana[numero]),
        ),
      );
    }

    Switch mudaChaveFilha(int numOn, int pai) {
      /*---------------------------------------------------------------------- \
      |   muda o valor dos Switch filho e coloca a hora 00:00                  |
      \ ----------------------------------------------------------------------*/

      return Switch(
        value: onOffFilho[numOn],
        onChanged: (bool value) {
          setState(() {
            if (onOffPai[pai] == true) {
              onOffFilho[numOn] = value;
              horas[numOn] = "00:00";
            } else {
              onOffFilho[numOn] = false;
              horas[numOn] = "00:00";
            }
          });
        },
      );
    }

    Container criaOnOffPai(String titulo, int number) {
      /*---------------------------------------------------------------------- \
    |   Cria a estrutura dos Switch (on off) pai                             |
    \ ----------------------------------------------------------------------*/

      return Container(
        height: 70,
        padding: EdgeInsets.only(left: setWidth(10)),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '$titulo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: onOffPai[number],
              onChanged: (bool value) {
                setState(() {
                  onOffPai[number] = value;
                  if (onOffPai[number] == false && number == 0) {
                    onOffFilho[0] = false;
                    horas[0] = "00:00";
                    mudaChaveFilha(0, number);
                    onOffFilho[1] = false;
                    horas[1] = "00:00";
                    mudaChaveFilha(1, number);
                  } else if (onOffPai[number] == false && number == 1) {
                    onOffFilho[2] = false;
                    horas[2] = "00:00";
                    mudaChaveFilha(2, number);
                    onOffFilho[3] = false;
                    horas[3] = "00:00";
                    mudaChaveFilha(3, number);
                  }
                });
              },
            ),
          ],
        ),
      );
    }

    DateTime formataTimeOfDay(TimeOfDay tod) {
      /*---------------------------------------------------------------------- \
      |   Converte TimeOfDay em DateTime                                       |
      \ ----------------------------------------------------------------------*/

      final now = dataHora;
      DateTime dt =
          DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      return dt;
    }

    void selecionaListaDeHoras(
        BuildContext context, int number, int pai) async {
      /*---------------------------------------------------------------------- \
      |   Seleciona as horas da notificação e alarme                           |
      \ ----------------------------------------------------------------------*/

      if (onOffPai[pai] == true && onOffFilho[number] == true) {
        TimeOfDay picked = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        TimeOfDay selectedTimeListTemporario = TimeOfDay.fromDateTime(
            DateTime.parse("2021-01-01 " +
                horas[number].substring(0, 2) +
                ":" +
                horas[number].substring(3, 5) +
                ":00Z"));
        if (picked != null && picked != selectedTimeListTemporario)
          setState(() {
            horasSelecionadas = picked;
            horas[number] = (horasSelecionadas.toString()).substring(10, 15);
            horasSelecionadas = TimeOfDay(hour: 0, minute: 0);
          });
      }
    }

    Container criaOnOffFilho(String titulo, int numero, int pai) {
      /*---------------------------------------------------------------------- \
    |   Cria a estrutura dos Switch (on off) filho                           |
    \ ----------------------------------------------------------------------*/

      return Container(
        height: 85,
        padding: EdgeInsets.only(left: setWidth(25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$titulo',
                  style: AppConsts.estiloTextoAlarmeNotifPai(onOffPai[pai]),
                ),
                Switch(
                  value: onOffFilho[numero],
                  onChanged: (bool value) {
                    setState(() {
                      if (onOffPai[pai] == true) {
                        onOffFilho[numero] = value;
                        horas[numero] = "00:00";
                      } else {
                        onOffFilho[numero] = false;
                        horas[numero] = "00:00";
                      }
                    });
                  },
                ),
              ],
            ),
            Container(
              height: 30,
              padding: EdgeInsets.only(left: setWidth(20)),
              alignment: Alignment.centerLeft,
              child: FloatingActionButton.extended(
                  label: Text(horas[numero],
                      style: AppConsts.estiloTextoHorasAlarmeNotif(
                          onOffFilho[numero])),
                  elevation: AppConsts.dateAndHourElevation,
                  backgroundColor: AppConsts.corFundoDataHora,
                  heroTag: "btnHoras$numero",
                  onPressed: () => selecionaListaDeHoras(context, numero, pai)),
            ),
          ],
        ),
      );
    }

    void selecionaDate(BuildContext context) async {
      /*---------------------------------------------------------------------- \
      |   Seleciona a data final                                               |
      \ ----------------------------------------------------------------------*/

      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dataHora,
        firstDate: DateTime.now(),
        lastDate: DateTime(2080),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark(),
            child: child,
          );
        },
      );
      print(picked);
      print(dataHora);
      if (picked != null && picked != dataHora)
        setState(() {
          dataHora = picked;
          print(hora);
          dataHora = formataTimeOfDay(hora);
          print(dataHora);
        });
    }

    void selecionaHoras(BuildContext context) async {
      /*---------------------------------------------------------------------- \
      |   Seleciona a hora final                                               |
      \ ----------------------------------------------------------------------*/

      TimeOfDay picked = await showTimePicker(
        initialTime: TimeOfDay.now(),
        context: context,
      );
      if (picked != null && picked != hora)
        setState(() {
          hora = picked;
          dataHora = formataTimeOfDay(hora);
        });
    }

    Future<void> salvaObjetivo() async {
      /*---------------------------------------------------------------------- \
      |   Salva as informações do objetivo na memória                          |
      \ ----------------------------------------------------------------------*/

      if (selecaoBarraNavegacao == 0) {
        if (numLinha != -1) {
          alterar();
        } else {
          criar();
        }
      }

      mudaTela();
    }

    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.save),
              label: "Salvar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cancel),
              label: "Cancelar",
            ),
          ],
          currentIndex: selecaoBarraNavegacao,
          selectedItemColor: Colors.grey[600],
          onTap: (value) {
            selecaoBarraNavegacao = value;
            salvaObjetivo();
          },
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: setWidth(300),
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.center,
                    child: TextFormField(
                      initialValue: objetivo == "" ? "" : objetivo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28.0)),
                        labelStyle: TextStyle(fontSize: 18),
                        labelText: objetivo == "" ? "Objetivo" : "",
                      ),
                      onChanged: (text) {
                        objetivo = text;
                      },
                    ),
                  ),
                  Container(
                    height: AppConsts.botaoCircular,
                    width: AppConsts.botaoCircular,
                    alignment: Alignment.center,
                    child: FloatingActionButton(
                      child: Icon(Icons.delete),
                      heroTag: "btnDeletar",
                      onPressed: () {
                        deletar();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Data de Termino',
                    ),
                    Text(
                      'Tempo Limite',
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      label: Text(DateFormat('dd/MM/yy').format(dataHora),
                          style: AppConsts.estiloTextoDataHoraFinal()),
                      elevation: AppConsts.dateAndHourElevation,
                      backgroundColor: AppConsts.corFundoDataHora,
                      heroTag: "btnData",
                      onPressed: () => selecionaDate(context),
                    ),
                    FloatingActionButton.extended(
                      label: Text(DateFormat('kk:mm').format(dataHora),
                          style: AppConsts.estiloTextoDataHoraFinal()),
                      elevation: AppConsts.dateAndHourElevation,
                      backgroundColor: AppConsts.corFundoDataHora,
                      heroTag: "btnHora",
                      onPressed: () => selecionaHoras(context),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: Text(
                  'Repetir o objetivo toda semana',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  criaDiaSemana("D", 0),
                  criaDiaSemana("S", 1),
                  criaDiaSemana("T", 2),
                  criaDiaSemana("Q", 3),
                  criaDiaSemana("Q", 4),
                  criaDiaSemana("S", 5),
                  criaDiaSemana("S", 6),
                ],
              ),
              criaOnOffPai('Notificação', 0),
              criaOnOffFilho('Notificar quanto tempo antes', 0, 0),
              criaOnOffFilho('Intervalo de notificação frequente', 1, 0),
              criaOnOffPai('Alarme', 1),
              criaOnOffFilho('Alarmar quanto tempo antes', 2, 1),
              criaOnOffFilho('Intervalo de alarme frequente', 3, 1),
            ],
          ),
        ),
      ),
    );
  }
}
