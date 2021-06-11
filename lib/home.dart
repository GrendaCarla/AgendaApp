import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:appAgenda/agenda.dart';
import 'package:appAgenda/utils/common.dart';
import 'package:appAgenda/utils/consts.dart';

class HomeApp extends StatefulWidget {
  static String tag = '/home';
  HomeApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeApp> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  void desfazCheckList(int linha, var semana, String check, DateTime data2) {
    /*---------------------------------------------------------------------- \
    |   Este metodo desfaz checkliste apos o dia da semana selecionado       |
    \ ----------------------------------------------------------------------*/

    // ---------- desfaz checkliste apos o dia da semana selecionado ----------
    if (check != "") {
      for (int b = 0; b < 7; b++) {
        if (semana[b] == true) {
          int diaObj = b; // primeiro dia d lista
          int diaAtu = DateTime.now().weekday; // dia da semana atual
          int diaCheck =
              DateTime.parse(check).weekday; // dia q foi dado o check

          if (diaAtu > diaObj && (diaObj >= diaCheck || diaAtu < diaCheck)) {
            alterarCheckList(linha, "");
          }
        }
      }
    }

    removerInfoVencido(linha, data2, check, semana);
  }

  void removerInfoVencido(int linha, DateTime data2, String check, var semana) {
    /*---------------------------------------------------------------------- \
    |   Este metodo remove as informações dos objetivos que ja passaram da   |
    |   data de termino.                                                     |
    \ ----------------------------------------------------------------------*/

    // --------------- removendo objetivos ultrapassados ----------------

    // verifica se a data do objetivo ja vençeu ou se o checkliste foi
    //  selecionado a pelomenos um dia

    if ((data2.add(const Duration(days: 1))).isAfter(DateTime.now()) == false ||
        data2.add(const Duration(days: 1)) == DateTime.now() ||
        ((check == "" ? true : dateFormat.parse(check) != DateTime.now()) &&
            check != "" &&
            semana.indexOf(true) == -1 &&
            ((check == ""
                ? true
                : dateFormat.parse(check).add(const Duration(days: 1)) ==
                            DateTime.now() ||
                        check == ""
                    ? true
                    : dateFormat
                        .parse(check)
                        .add(const Duration(days: 1))
                        .isBefore(DateTime.now()))))) {
      // --------------- remove ---------------------

      int numero = 0;
      Firestore.instance
          .collection('infoAgenda')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          if (numero == linha) {
            ds.reference.delete();
          }
          numero++;
        }
      });
    }
  }

  void alterarCheckList(int numLinha, String value) {
    int numero = 0;
    Firestore.instance.collection('infoAgenda').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        if (numero == numLinha) {
          ds.reference.updateData({'checkList': value});
        }
        numero++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppConsts.setWidthSize(MediaQuery.of(context).size.width);
    AppConsts.setHightSize(MediaQuery.of(context).size.height);
    var snapshots = Firestore.instance.collection('infoAgenda').snapshots();

    return Scaffold(
      body: StreamBuilder(
        stream: snapshots,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.documents.length == 0) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '       Aperte o botão para\nadicionar um novo objetivo',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> data = snapshot.data.documents[i].data;
              DateTime _timestamp = data['dataHora'].toDate();
              String _check = data['checkList'];
              List<bool> _semana = [
                data['semana']['dom'],
                data['semana']['seg'],
                data['semana']['ter'],
                data['semana']['qua'],
                data['semana']['qui'],
                data['semana']['sex'],
                data['semana']['sab']
              ];
              desfazCheckList(i, _semana, _check, _timestamp);

              return Container(
                color: AppConsts.corContainerObjetivo,
                alignment: Alignment.centerRight,
                padding: AppConsts.margemContainerObjetive,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Checkbox(
                      value: _check == "" ? false : true,
                      onChanged: (bool value) {
                        _check =
                            value == false ? "" : DateTime.now().toString();
                        alterarCheckList(i, _check);
                      },
                    ),
                    new ConstrainedBox(
                      constraints: new BoxConstraints(minHeight: 70),
                      child: SizedBox(
                        width: setWidth(320),
                        child: ElevatedButton(
                          child: Column(
                            children: <Widget>[
                              Text(
                                data['objetivo'].toString(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: AppConsts.corLetraBotaoObjetivo(
                                        _check == "" ? false : true,
                                        getCustomFormattedDateTime(
                                            _timestamp.toString(), 'dd/MM/yy'),
                                        getCustomFormattedDateTime(
                                            _timestamp.toString(), 'kk:mm')),
                                    decoration:
                                        AppConsts.riscarLetraBotaoObjetivo(
                                            _check == "" ? false : true),
                                    decorationThickness: 2),
                              ),
                              Text(
                                  getCustomFormattedDateTime(
                                          _timestamp.toString(), 'dd/MM/yy') +
                                      "       " +
                                      (data['semana']['dom'].toString() == "false"
                                          ? "_"
                                          : "D") +
                                      " " +
                                      (data['semana']['seg'].toString() == "false"
                                          ? "_"
                                          : "S") +
                                      " " +
                                      (data['semana']['ter'].toString() == "false"
                                          ? "_"
                                          : "T") +
                                      " " +
                                      (data['semana']['qua'].toString() == "false"
                                          ? "_"
                                          : "Q") +
                                      " " +
                                      (data['semana']['qui'].toString() ==
                                              "false"
                                          ? "_"
                                          : "Q") +
                                      " " +
                                      (data['semana']['sex'].toString() ==
                                              "false"
                                          ? "_"
                                          : "S") +
                                      " " +
                                      (data['semana']['sab'].toString() ==
                                              "false"
                                          ? "_"
                                          : "S") +
                                      "        " +
                                      getCustomFormattedDateTime(
                                          _timestamp.toString(), 'kk:mm') +
                                      "  ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppConsts.corLetraBotaoObjetivo(
                                          _check == "" ? false : true,
                                          getCustomFormattedDateTime(
                                              _timestamp.toString(),
                                              'dd/MM/yy'),
                                          getCustomFormattedDateTime(
                                              _timestamp.toString(), 'kk:mm')))),
                            ],
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppConsts.corFundoBotaoObjetivo(
                                      _check == "" ? false : true,
                                      getCustomFormattedDateTime(
                                          _timestamp.toString(), 'dd/MM/yy'),
                                      getCustomFormattedDateTime(
                                          _timestamp.toString(), 'kk:mm')))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Agenda(
                                          data['objetivo'].toString(),
                                          _timestamp,
                                          TimeOfDay.fromDateTime(
                                              data['dataHora'].toDate()),
                                          i,
                                          _semana,
                                          [
                                            ((DateTime.fromMicrosecondsSinceEpoch(
                                                        (data['horas']['h1'])
                                                            .microsecondsSinceEpoch))
                                                    .toString())
                                                .substring(11, 16),
                                            ((DateTime.fromMicrosecondsSinceEpoch(
                                                        (data['horas']['h2'])
                                                            .microsecondsSinceEpoch))
                                                    .toString())
                                                .substring(11, 16),
                                            ((DateTime.fromMicrosecondsSinceEpoch(
                                                        (data['horas']['h3'])
                                                            .microsecondsSinceEpoch))
                                                    .toString())
                                                .substring(11, 16),
                                            ((DateTime.fromMicrosecondsSinceEpoch(
                                                        (data['horas']['h4'])
                                                            .microsecondsSinceEpoch))
                                                    .toString())
                                                .substring(11, 16),
                                          ],
                                          [
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                    (data['horas']
                                                                            [
                                                                            'h1'])
                                                                        .microsecondsSinceEpoch))
                                                                .toString())
                                                            .substring(
                                                                11, 16) ==
                                                        "00:00" &&
                                                    ((DateTime.fromMicrosecondsSinceEpoch(
                                                                    (data['horas']
                                                                            [
                                                                            'h2'])
                                                                        .microsecondsSinceEpoch))
                                                                .toString())
                                                            .substring(
                                                                11, 16) ==
                                                        "00:00"
                                                ? false
                                                : true),
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                    (data['horas']
                                                                            [
                                                                            'h3'])
                                                                        .microsecondsSinceEpoch))
                                                                .toString())
                                                            .substring(
                                                                11, 16) ==
                                                        "00:00" &&
                                                    ((DateTime.fromMicrosecondsSinceEpoch(
                                                                    (data['horas']
                                                                            [
                                                                            'h4'])
                                                                        .microsecondsSinceEpoch))
                                                                .toString())
                                                            .substring(
                                                                11, 16) ==
                                                        "00:00"
                                                ? false
                                                : true),
                                          ],
                                          [
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                (data['horas']
                                                                        ['h1'])
                                                                    .microsecondsSinceEpoch))
                                                            .toString())
                                                        .substring(11, 16) ==
                                                    "00:00"
                                                ? false
                                                : true),
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                (data['horas']
                                                                        ['h2'])
                                                                    .microsecondsSinceEpoch))
                                                            .toString())
                                                        .substring(11, 16) ==
                                                    "00:00"
                                                ? false
                                                : true),
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                (data['horas']
                                                                        ['h3'])
                                                                    .microsecondsSinceEpoch))
                                                            .toString())
                                                        .substring(11, 16) ==
                                                    "00:00"
                                                ? false
                                                : true),
                                            (((DateTime.fromMicrosecondsSinceEpoch(
                                                                (data['horas']
                                                                        ['h4'])
                                                                    .microsecondsSinceEpoch))
                                                            .toString())
                                                        .substring(11, 16) ==
                                                    "00:00"
                                                ? false
                                                : true),
                                          ])),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "bnt+",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Agenda(
                    "",
                    DateTime.now(),
                    TimeOfDay.fromDateTime(DateTime.now()),
                    -1,
                    [false, false, false, false, false, false, false],
                    ["00:00", "00:00", "00:00", "00:00"],
                    [false, false],
                    [false, false, false, false])),
          );
        },
        tooltip: 'Adicionar Agenda',
        child: Icon(Icons.add),
      ),
    );
  }
}

getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
  // dateFormat = 'MM/dd/yy';
  final DateTime docDateTime = DateTime.parse(givenDateTime);
  return DateFormat(dateFormat).format(docDateTime);
}
