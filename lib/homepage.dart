import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  bool isImageSelected = false;
  bool isLoading = false;
  XFile? selectedImage;

  final textRecognizer = GoogleMlKit.vision.textRecognizer();
  final ImagePicker _picker = ImagePicker();

  String? extractedText; //to show output text

//method to pick image and process the text
  Future<void> process() async {
    if (selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      final inputImage = InputImage.fromFilePath(selectedImage!.path);
      final visionText = await textRecognizer.processImage(inputImage);

      List<String> recognizedText = [];
      for (final block in visionText.blocks) {
        for (final line in block.lines) {
          recognizedText.add(line.text);
        }
      }

      setState(() {
        extractedText = recognizedText.join('\n');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(screenHeight / 20),
                Text(
                  "Text Recognition System",
                  style: GoogleFonts.orbitron(
                    color: Colors.blueGrey,
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Gap(screenHeight / 20),
                InkWell(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = image;
                        isImageSelected = true;
                        extractedText = null; // Clear previous text
                      });
                      await process();
                    }
                  },
                  child: Container(
                    height: screenHeight / 3,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blueAccent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: (isImageSelected && selectedImage != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.blueAccent,
                            ),
                          ),
                  ),
                ),
                Gap(screenHeight / 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (extractedText != null)
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              extractedText!,
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: screenWidth / 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade500,
                            child: IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: extractedText ?? ""));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Text copied to clipboard"),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Pick an image that contains text to recognize.",
                        style: GoogleFonts.poppins(
                          color: Colors.blueGrey,
                          fontSize: screenWidth / 22,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Gap(screenHeight / 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
