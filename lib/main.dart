import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_recognition/controller/text_format_controller.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_text_recognition/scallable_ocr.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  // Gemini.init(
  //     apiKey: const String.fromEnvironment('AIzaSyDyPEPp5H3KoRaZuK2Nu5CCjiuDL5zcJNs'), enableDebugging: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Text Recognition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Text Recognition Screen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  TextFormatController textFormatController = Get.put(TextFormatController());

  var imagePicker = ImagePicker();
  late ITextRecognizer recognizer;
  String imgPath = "";
  List textList = [];

  RecognitionResponse? response;

  Future<String?> obtainImage(ImageSource source) async {
    final file = await imagePicker.pickImage(source: source);
    return file?.path;
  }

  Future<void> processImage(String imgPath) async {
    final recognizedText = await recognizer.processImage(imgPath).then((value) => textFormatController.textFormatRepo(extractedText: value));
    setState(() {
      response = RecognitionResponse(
          imgPath: imgPath,
          recognizedText: recognizedText);
      if (kDebugMode) {
        // print(response?.imgPath);
      }
      if (kDebugMode) {
        // print(response?.recognizedText);
        textList.add(response?.recognizedText);
        _parseAndDisplayText(response!.recognizedText, context);
      }
    });
    // print("===================>>> $textList");
  }
  void _parseAndDisplayText(String text, BuildContext context) {
    // Define regex patterns for extraction
    RegExp organizationPattern = RegExp(r'(?<=\bOrganization:\s)(.+?)(?<=\bLTD\s)\b');
    RegExp addressPattern = RegExp(r'\b\d{1,5}\s[A-z0-9\s]{1,}(?=\,\s[A-z]{2,}\s\d{5}\b)');
    RegExp phonePattern = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    RegExp namePattern = RegExp(r'([A-Z][a-z]+(?: [A-Z][a-z]+)*)');
    RegExp emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b');
    RegExp designationPattern = RegExp(r'\b(?:[A-Z][a-z]*\s*){1,3}\b');
    RegExp webAddressPattern = RegExp(r'(https?://)?(www\.)?[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,6}');

    // Extract information using regex patterns
    String organizationName = organizationPattern.firstMatch(text)?.group(0) ?? 'Not found';
    String address = addressPattern.firstMatch(text)?.group(0) ?? 'Not found';
    String phoneNumber = phonePattern.firstMatch(text)?.group(0) ?? 'Not found';
    String personName = namePattern.firstMatch(text)?.group(0) ?? 'Not found';
    String email = emailPattern.firstMatch(text)?.group(0) ?? 'Not found';
    String designation = designationPattern.firstMatch(text)?.group(0) ?? 'Not found';
    String webAddress = webAddressPattern.firstMatch(text)?.group(0) ?? 'Not found';

    // Display extracted information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Extracted Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(),
              Text('Organization Name: $organizationName'),
              Text('Address: $address'),
              Text('Phone Number: $phoneNumber'),
              Text('Person Name: $personName'),
              Text('Email: $email'),
              Text('Designation: $designation'),
              Text('Web Address: $webAddress'),
            ],
          ),
        );
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    recognizer = MLKitTextRecognizer();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(recognizer is MLKitTextRecognizer){
      (recognizer as MLKitTextRecognizer).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 400,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Image.file(File(imgPath) , fit: BoxFit.fill,
                ),
            ),
            const Text(
              'Text Recognition',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FlutterScalableOcr(),));
            }, child: Text("Click here"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return imagePickAlert(
                  onCameraPressed: () async {
                    imgPath = (await obtainImage(ImageSource.camera))!;
                    setState(() {

                    });
                    processImage(imgPath);
                    Navigator.of(context).pop();
                  },
                  onGalleryPressed: () async {
                    imgPath = (await obtainImage(ImageSource.gallery))!;
                    setState(() {

                    });
                    processImage(imgPath);
                    Navigator.of(context).pop();
                  },
                );
              },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Widget imagePickAlert({void Function()? onCameraPressed, void Function()? onGalleryPressed}){
    return AlertDialog(
      title: const Text("Pick a source"),
      content: SizedBox(
        width: 150,
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(
                "Camera",
              ),
              onTap: onCameraPressed,
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text(
                "Gallery",
              ),
              onTap: onGalleryPressed,
            ),

          ],
        ),
      ),
    );
  }
}

class MLKitTextRecognizer extends ITextRecognizer{
  late TextRecognizer recognizer;
  MLKitTextRecognizer(){
    recognizer = TextRecognizer();
  }

  void dispose(){
    recognizer.close();
  }

  @override
  Future<String> processImage(String imgPath) async {
    // TODO: implement processImage
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await recognizer.processImage(image);
    return recognized.text;
    throw UnimplementedError();
  }

}

abstract class ITextRecognizer{
  Future<String> processImage(String imgPath);
}

class RecognitionResponse{
  final String imgPath;
  final String recognizedText;

  RecognitionResponse({required this.imgPath, required this.recognizedText});
  @override
  bool operator ==(covariant RecognitionResponse other) {
    if (identical(this, other)) return true;

    if (kDebugMode) {
      print("========================>>>$recognizedText");
    }

    return other.imgPath == imgPath && other.recognizedText == recognizedText;
  }

  @override
  int get hashCode => imgPath.hashCode ^ recognizedText.hashCode;

}

///<<<====================== Code for scallable OCR ====================>>>
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:async';
// import 'package:mnc_identifier_ocr/mnc_identifier_ocr.dart';
// import 'package:mnc_identifier_ocr/model/ocr_result_model.dart';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   OcrResultModel? result;
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> scanKtp() async {
//     OcrResultModel? res;
//     try {
//       res = await MncIdentifierOcr.startCaptureKtp(withFlash: true, cameraOnly: true);
//     } catch (e) {
//       debugPrint('something goes wrong $e');
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       result = res;
//     });
//   }
//
//   _imgGlr() async {
//     final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
//     debugPrint('path: ${image?.path}');
//   }
//
//   _imgCmr() async {
//     final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
//     debugPrint('path: ${image?.path}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Stack(
//           children: [
//             Text('Ktp data: ${result?.toJson()}'),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(onPressed: scanKtp, child: const Text('PUSH HERE')),
//                   const SizedBox(height: 8),
//                   ElevatedButton(onPressed: _imgCmr, child: const Text('CAMERA')),
//                   const SizedBox(height: 8),
//                   ElevatedButton(onPressed: _imgGlr, child: const Text('GALLERY')),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }