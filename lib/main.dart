import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg2.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Color(0xdd1C4274), BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontFamily: "Muli-Bold",
                  fontSize: 50,
                  color: Color(0xFFFCCB01),
                ),
              ),
              const Text(
                "Log in to you account",
                style: TextStyle(
                  fontFamily: "Muli-Bold",
                  fontSize: 20,
                  color: Color(0xFFBFDFF5),
                ),
              ),
              const SizedBox(height: 47),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: usernameController,
                  style: const TextStyle(
                      color: Color(0xFFBFDFF5), fontFamily: "Muli-Bold"),
                  cursorColor: const Color(0xFFFCCB01),
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.person,
                      color: Color(0xFFFCCB01),
                    ),
                    labelText: "Username",
                    labelStyle: TextStyle(
                      fontFamily: "Muli-Bold",
                      color: Color(0xFFBFDFF5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFBFDFF5), width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        color: Color(0xFFBFDFF5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                      color: Color(0xFFBFDFF5), fontFamily: "Muli-Bold"),
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.key,
                      color: Color(0xFFFCCB01),
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontFamily: "Muli-Bold",
                      color: Color(0xFFBFDFF5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        color: Color(0xFFBFDFF5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        color: Color(0xFFBFDFF5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xFFFCCB01))),
                  child: const Text(
                    "Login",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCCB01),
            title: const Text("Home Page"),
            titleTextStyle: const TextStyle(
              fontFamily: "Muli-Bold",
              fontSize: 20,
            ),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: "Home"),
                Tab(text: "Camera"),
              ],
            ),
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            }),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/bg2.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Color(0xdd1C4274), BlendMode.darken)),
                ),
                child: const Center(
                  child: Text("Hi"),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/bg2.jpg"),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Color(0xdd1C4274), BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: QrCodeScanner(),
                ),
              ),
            ],
          ),
          drawer: const Drawer()),
    );
  }
}

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color(0xFFFCCB01),
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    String? prevText;
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (scanData.code != prevText) {
          result = scanData;
          String? resultText = result!.code;
          prevText = resultText;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$resultText"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
