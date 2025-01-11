import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'RegistrationScreen.dart';
import 'RecognitionScreen.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen>{
  FlutterTts flutterTts = FlutterTts();

  //funcion para hablar el texto
  void speak(String text) async {
    await flutterTts.setLanguage("es-ES"); // Establecer idioma a español
    await flutterTts.setPitch(1); // Ajustar el tono de la voz
    await flutterTts.speak(text); // Convertir texto en voz
  }

  @override
  Widget build(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonWidth = screenWidth - 30;
    double imageSize = screenWidth - 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inicio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, //Centrar el título en la AppBar
        backgroundColor: Colors.blue,
        elevation: 4.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Image.asset(
              "images/logo.png",
              width: imageSize,
              height: imageSize,
              semanticLabel: 'Logo de la aplicación',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                ElevatedButton(onPressed: () {
                  speak("Boton de registro");
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>const RegistrationScreen()));
                  }, 
                style: ElevatedButton.styleFrom(minimumSize: Size(buttonWidth, 50),
            ),
                  child: const Text("Registrar"),),
             Container(height: 20,),
                ElevatedButton(onPressed: () {
                  speak("Boton de reconocimiento");
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>const RecognitionScreen()));
             },
                  style: ElevatedButton.styleFrom(minimumSize: Size(buttonWidth, 50),), child: const Text("Recognize"),
             ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//const SizedBox(height: 20,)