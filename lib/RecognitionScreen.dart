

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesis_proyecto/ML/Recognition.dart';
import 'package:tesis_proyecto/ML/Recognizer.dart';

class RecognitionScreen extends StatefulWidget{
  const RecognitionScreen({Key? key}) : super(key: key);
  @override
  State<RecognitionScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RecognitionScreen>{
  //declarar variables
  late ImagePicker imagePicker;
  File? _image;
  FlutterTts flutterTts = FlutterTts();

  //Declarar detector
  late FaceDetector faceDetector;

//declarar reconocimiento de rostro
  late Recognizer recognizer;

  //funcion para hablar el texto
  void speak(String text) async {
    await flutterTts.setLanguage("es-ES"); // Establecer idioma a español
    await flutterTts.setPitch(1); // Ajustar el tono de la voz
    await flutterTts.speak(text); // Convertir texto en voz
  }

  @override
  void initState(){
    //implementar initstate
    super.initState();
    imagePicker = ImagePicker();

    //inicializar detector facial
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);

    //inicializar reconocimiento facial
    recognizer = Recognizer();
  }

// capturar imagen usando camara
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  //capturar imagen usando galeria
  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  //Código de deteccion de rostro
  List<Face> faces = [];
  List<Recognition> recognitions = [];
  doFaceDetection()async {
    // remover rotacion de imagen de camara
    InputImage inputImage = InputImage.fromFile(_image!);
    recognitions.clear();

    //image = await _image?.readAsBytes();
    image = await decodeImageFromList(_image!.readAsBytesSync());

    //pasar entrada de detector facial y obtener rostros detectados
    faces = await faceDetector.processImage(inputImage);
    for(Face face in faces){
      final Rect boundingBox = face.boundingBox;
      print("Rect = "+boundingBox.toString());
      speak("Rostro detectado");

      num left = boundingBox.left<0?0:boundingBox.left;
      num top = boundingBox.top<0?0:boundingBox.top;
      num right = boundingBox.right>image.width?image.width-1:boundingBox.right;;
      num bottom = boundingBox.bottom>image.height?image.height-1:boundingBox.bottom;;
      num width = right-left;
      num height = bottom - top;

      final bytes = _image!.readAsBytesSync();
      img.Image? faceImg = img.decodeImage(bytes!);
      img.Image croppedFace = img.copyCrop(faceImg!, x: left.toInt(), y: top.toInt(), width: width.toInt(), height: height.toInt());
      Recognition recognition = recognizer.recognize(croppedFace, boundingBox);
      if(recognition.distance>1){
        recognition.name = "Unknown";
      }
      recognitions.add(recognition);
      print("Recognized face "+recognition.name);
      speak("Rostro de ${recognition.name}");
      //showFaceRegistrationDialogue(Uint8List.fromList(img.encodeBmp(croppedFace)), recognition);
    }
    //drawRectangleAroundFaces();
    drawRectangleAroundFace();

    //llamar metodo para realizar reconocimiento facial en rostros detectados

  }

  //Remover rotacion de imagenes de camara
  removeRotation(File inputImage) async {
    final img.Image? capturedImage = img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  //TODO perform Face Recognition

  //TODO Face Registration Dialogue
  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(Uint8List cropedFace, Recognition recognition){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration",textAlign: TextAlign.center),alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              Image.memory(
                cropedFace,
                width: 200,
                height: 200,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration( fillColor: Colors.white, filled: true,hintText: "Enter Name")
                ),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                  onPressed: () {
                    recognizer.registerFaceInDB(textEditingController.text, recognition.embeddings.toString());
                    textEditingController.text = "";
                    Navigator.pop(context as BuildContext);
                    ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
                      content: Text("Face Registered"),
                    ));
                  },style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,minimumSize: const Size(200,40)),
                  child: const Text("Register"))
            ],
          ),
        ),contentPadding: EdgeInsets.zero,
      ),
    );
  }


  //Dibujar rectangulo en rostro
  var image;
  drawRectangleAroundFace() async {

    print("${image.width}  ${image.height}");
    setState(() {
      image;
      recognitions;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reconocer Persona",
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
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          image != null
              ?
          //Container(
          //      margin: const EdgeInsets.only(top: 100),
          //    width: screenWidth - 50,
          //  height: screenWidth - 50,
          //child: Image.file(_image!),
          //  )
          Container(
            margin: const EdgeInsets.only(
                top: 60, left: 30, right: 30, bottom: 0),
            child: FittedBox(
              child: SizedBox(
                width: image.width.toDouble(),
                height: image.width.toDouble(),
                child: CustomPaint(
                  painter: FacePainter(
                      facesList: recognitions, imageFile: image),
                ),
              ),
            ),
          )
              :Container(
            margin: const EdgeInsets.only(top: 100),
            child: Image.asset("images/logo.png",
              width: screenWidth -100,
              height: screenWidth - 100,
            ),
          ),
          Container(
            height: 50,
          ),

          //Seccion que muestra botones para elegir y capturar imagenes
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: (){
                      _imgFromGallery();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 -70,
                      height: screenWidth / 2 -70,
                      child: Icon(Icons.image,
                        color: Colors.blue, size: screenWidth / 7,),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Recognition> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size){
    if(imageFile != null){
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 5;

    for(Recognition face in facesList){
      canvas.drawRect(face.location, p);

      TextSpan textSpan = TextSpan(text: face.name,style: TextStyle(color: Colors.black,fontSize: 40));
      TextPainter tp = TextPainter(text: textSpan,textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(face.location.left, face.location.top));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return true;
  }
}