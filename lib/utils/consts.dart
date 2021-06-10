import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*  ---------------- Alguns atributos das paginas -----------------

 *  Contem atributos de width e height.
 
 *  Contem atributos de cores de fundo e letras.

 *  Contem atributos de margem, fonte de letra.
 
*/

class AppConsts {
  static double widthPercentage;
  static double heightPercentage;

  static double widthSize;
  static double heightSize;

  static const double xdWidthSize = 375.0;
  static const double xdHeightSize = 667.0;

  static void setWidthSize(double size) {
    widthSize = size;
    widthPercentage = widthSize / xdWidthSize;
  }

  static void setHightSize(double size) {
    heightSize = size;
    heightPercentage = heightSize / xdHeightSize;
  }

// *------------------------ coisas responsivas ------------------------------

  // tamanho dos botoes circulares
  static double botaoCircular = 50.0;

//* ------------------------------ PAG2 --------------------------------

  // ------- tamanho da fonte e cor do texto do alarme e notificação -------
  static TextStyle estiloTextoAlarmeNotifPai(bool pai) {
    return TextStyle(
        fontSize: 13,
        color: pai == false ? Colors.black.withOpacity(0.5) : Colors.black);
  }

  // --------- tamanho e tipo da fonte e cor do texto da --------------
  //  ----------------- hora do alarme e notificação ------------------
  static TextStyle estiloTextoHorasAlarmeNotif(bool pai) {
    return TextStyle(
        color: pai == false ? Colors.black.withOpacity(0.5) : Colors.black,
        fontSize: 24,
        fontFamily: 'Fantasy');
  }

  // --------- tamanho e tipo da fonte e cor do texto da --------------
  //  ----------------------- data e hora final -----------------------
  static TextStyle estiloTextoDataHoraFinal() {
    return TextStyle(color: Colors.black, fontSize: 26, fontFamily: 'Fantasy');
  }

  // elevação dos botões da data e hora
  static double dateAndHourElevation = 0;

  // cor de fundo do botão da data e das horas
  static Color corFundoDataHora = Colors.transparent;

  //-------------------- cor dos botões do dia da semana ---------------------
  static Color corBotaoSemana(bool i) {
    return i == false ? Color(0xFF5F8DF1) : Colors.blue[200];
  }

// *----------------------------- PAG1 ----------------------------------

  //-----------------  Cor de fundo do botão objetivo --------------------------
  static Color corFundoBotaoObjetivo(bool i, String data, String hora) {
    // esta função escolhe a cor de fundo adequada a situação.

    if (hora == "") {
      return Color(0xFFFFFFFF);
    }

    Color cor = Color(0xFF5F8DF1);

    var datHoraObjetivo = DateTime.parse("20" +
        data.substring(6, 8) +
        "-" +
        data.substring(3, 5) +
        "-" +
        data.substring(0, 2) +
        " " +
        hora.substring(0, 2) +
        ":" +
        hora.substring(3, 5) +
        ":00Z");

    int horaAtualMinutos =
        (int.parse(DateFormat('kk').format(DateTime.now())) * 60) +
            (int.parse(DateFormat('mm').format(DateTime.now())));

    int horaObjetivoMinutos = (int.parse(hora.substring(0, 2)) * 60) +
        (int.parse(hora.substring(3, 5)));

    if (datHoraObjetivo.isAfter(DateTime.now()) == false) {
      if (horaAtualMinutos < horaObjetivoMinutos &&
          horaAtualMinutos + 60 >= horaObjetivoMinutos) {
        cor = Color(0xFF900033);
      } else if (horaAtualMinutos >= horaObjetivoMinutos &&
          (int.parse(hora.substring(0, 2))) == 0 &&
          (int.parse(DateFormat('kk').format(DateTime.now()))) == 23 &&
          (int.parse(hora.substring(3, 5))) <=
              (int.parse(DateFormat('mm').format(DateTime.now())))) {
        cor = Color(0xFF900033);
      } else if (horaAtualMinutos >= horaObjetivoMinutos) {
        cor = Color(0xFF380059);
      }
    }

    return i == false ? cor : Color(0xFFFFFFFF);
  }

  //-----------------  Cor da letra do botão objetivo --------------------------
  static Color corLetraBotaoObjetivo(bool i, String data, String hora) {
    // esta função escolhe a cor da letra adequada a situação.

    Color cor = Color(0xFFFFFFFF);

    if (hora == "") {
      return cor;
    }

    var datHoraObjetivo = DateTime.parse("20" +
        data.substring(6, 8) +
        "-" +
        data.substring(3, 5) +
        "-" +
        data.substring(0, 2) +
        " " +
        hora.substring(0, 2) +
        ":" +
        hora.substring(3, 5) +
        ":00Z");

    int horaAtualMinutos =
        (int.parse(DateFormat('kk').format(DateTime.now())) * 60) +
            (int.parse(DateFormat('mm').format(DateTime.now())));

    int horaObjetivoMinutos = (int.parse(hora.substring(0, 2)) * 60) +
        (int.parse(hora.substring(3, 5)));

    if (datHoraObjetivo.isAfter(DateTime.now()) == false) {
      if (horaAtualMinutos >= horaObjetivoMinutos) {
        cor = Color(0xFFFF0033);
      }
    }

    return i == false ? cor : Color(0x887F7EB2);
  }

  // ----------- função de riscar o nome do objetivo concluido -------------
  static TextDecoration riscarLetraBotaoObjetivo(bool i) {
    return i == false ? TextDecoration.none : TextDecoration.lineThrough;
  }

  // cor de fundo do container objetivo
  static Color corContainerObjetivo = Colors.transparent;

  // margem do container objetivo
  static EdgeInsets margemContainerObjetive =
      EdgeInsets.only(bottom: 5, top: 5, right: 5);
}
