import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> alterarCheckList(int numLinha, bool value) {
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
              bool _check = data['checkList'];

              return Container(
                color: AppConsts.corContainerObjetivo,
                alignment: Alignment.centerRight,
                padding: AppConsts.margemContainerObjetive,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Checkbox(
                      value: _check,
                      onChanged: (bool value) {
                        _check = value;
                        alterarCheckList(i, value);
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
                                        _check,
                                        getCustomFormattedDateTime(
                                            _timestamp.toString(), 'dd/MM/yy'),
                                        getCustomFormattedDateTime(
                                            _timestamp.toString(), 'kk:mm')),
                                    decoration:
                                        AppConsts.riscarLetraBotaoObjetivo(
                                            _check),
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
                                          _check,
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
                                      _check,
                                      getCustomFormattedDateTime(
                                          _timestamp.toString(), 'dd/MM/yy'),
                                      getCustomFormattedDateTime(
                                          _timestamp.toString(), 'kk:mm')))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Agenda(
                                          _check,
                                          data['objetivo'].toString(),
                                          _timestamp,
                                          i, [
                                        data['semana']['dom'],
                                        data['semana']['seg'],
                                        data['semana']['ter'],
                                        data['semana']['qua'],
                                        data['semana']['qui'],
                                        data['semana']['sex'],
                                        data['semana']['sab']
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
                builder: (context) => Agenda(false, "", DateTime.now(), -1, [
                      false,
                      false,
                      false,
                      false,
                      false,
                      false,
                      false
                    ] /*, [false, false], [false, false, false, false], ["00:00", "00:00", "00:00", "00:00"]*/)),
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
