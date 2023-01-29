import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendify_/sql.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

void main() async {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      routes: {
        '/teachers_homescreen': (context) => const HomeScreen(),
        '/students_homescreen': (context) => const StudentsHomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool failed = false;
  bool loading = false;
  var db = Database();

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
              const SizedBox(height: 26),
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
                  onPressed: () async {
                    try {
                      setState(() {
                        loading = true;
                      });
                      Database db = Database();
                      var conn = await db.getConnection();
                      var result = await conn.query(
                          'SELECT fullname, username, password, role_id FROM users_tbl WHERE username = "${usernameController.text}" AND password = "${passwordController.text}"');
                      if (result.isNotEmpty) {
                        for (var row in result) {
                          if (row[3] == 1) {
                            // ignore: use_build_context_synchronously
                            Navigator.pushNamed(context, "/teachers_homescreen",
                                arguments: row[0]);
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.pushNamed(
                                context, "/students_homescreen");
                          }
                        }
                      } else {
                        setState(() {
                          failed = true;
                          loading = false;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        failed = true;
                        loading = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => const Color(0xFFFCCB01),
                    ),
                  ),
                  child: loading == false
                      ? const Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xdd1C4274),
                            fontFamily: "Muli-Bold",
                            fontSize: 15,
                          ),
                        )
                      : Container(
                          height: 20.0,
                          width: 20.0,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              failed == true
                  ? const SizedBox(
                      width: 300,
                      child: Text(
                        "An error has occured.",
                        style: TextStyle(
                            color: Colors.red, fontFamily: "Muli-Bold"),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()
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
  static List<Widget> widgets = [];
  static List<String?> namesOfStudents = [];
  var profilePic;
  bool profilePicLoaded = false;

  void checkPfpInDatabase(args) async {
    Database db = Database();
    var conn = await db.getConnection();
    var result =
        await conn.query("SELECT pfp FROM users_tbl WHERE fullname = '$args'");
    for (var row in result) {
      setState(() {
        profilePic = base64Decode(
          "${row[0].toString()}",
        );
      });
    }

    conn.close();
  }

  @override
  void dispose() {
    widgets = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    List<String> name = args.split(" ");
    if (profilePicLoaded == false) {
      checkPfpInDatabase(args);
      profilePicLoaded = true;
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCCB01),
          title: const Text(
            "Home Page",
          ),
          titleTextStyle: const TextStyle(
            fontFamily: "Muli-Bold",
            fontSize: 20,
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.home),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Home')
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Camera')
                  ],
                ),
              ),
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
            Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  Permission.accessMediaLocation.request();
                  List<Directory>? saveDir =
                      await getExternalStorageDirectories(
                          type: StorageDirectory.documents);
                  String directory = saveDir![0].path;
                  print(directory);
                  var now = DateTime.now();
                  var attendanceExcel = Excel.createExcel();
                  Sheet attendanceSheet =
                      attendanceExcel['${now.year}-${now.month}-${now.day}'];
                  attendanceSheet.cell(CellIndex.indexByString('A1')).value =
                      'STUDENT';
                  attendanceSheet.cell(CellIndex.indexByString('B1')).value =
                      'TIME';
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Export"),
                      content: const Text("Are you sure?"),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              var counter = 2;
                              for (var names
                                  in _HomeScreenState.namesOfStudents) {
                                attendanceSheet
                                    .cell(CellIndex.indexByString('A$counter'))
                                    .value = names?.split('::')[0];
                                attendanceSheet
                                    .cell(CellIndex.indexByString('B$counter'))
                                    .value = names?.split('::')[1];
                                counter++;
                              }
                              List<int>? fileBytes = attendanceExcel.save();

                              File(
                                  "$directory/${now.year}-${now.month}-${now.day}.xlsx")
                                ..createSync(recursive: true)
                                ..writeAsBytes(fileBytes!);
                              Navigator.pop(context);
                              OpenFile.open(
                                  "$directory/${now.year}-${now.month}-${now.day}.xlsx");
                            },
                            child: const Text("Yes")),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("No")),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.addchart),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/bg2.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Color(0xdd1C4274), BlendMode.darken)),
                ),
                child:
                    ListView(addAutomaticKeepAlives: false, children: widgets),
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
        drawer: Drawer(
          backgroundColor: const Color(0xFFFCCB01),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/drawerbg.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Color(0xf11C4274), BlendMode.darken),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var pickedImage = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    var bytes = await File(pickedImage.path)
                                        .readAsBytes();
                                    setState(
                                      () {
                                        profilePic = bytes;
                                      },
                                    );
                                    var base64 = base64Encode(bytes);
                                    var db = Database();
                                    var conn = await db.getConnection();
                                    conn.query(
                                        "UPDATE users_tbl SET pfp = '$base64' WHERE fullname = '$args'");
                                  }
                                },
                                child: profilePic == null
                                    ? CircleAvatar(
                                        radius: 50,
                                        child: Text(
                                          "${name[0][0]}${name[1][0]}",
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            MemoryImage(profilePic),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 10, bottom: 20, right: 10),
                          child: Row(
                            children: [
                              Text(
                                args,
                                style: const TextStyle(
                                  fontFamily: "Muli-Bold",
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text(
                        "Home",
                        style: TextStyle(
                          fontFamily: "Muli-Bold",
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => null,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/", (Route<dynamic> route) => false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
  static QRViewController? controller;
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
      child: Stack(
        children: [
          _buildQrView(context),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFFFCCB01)),
              ),
              onPressed: () async {
                await controller?.toggleFlash();
              },
              child: const Text("Toggle flash"),
            ),
          ),
        ],
      ),
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
        cutOutSize: scanArea,
        borderColor: const Color(0xFFFCCB01),
        borderRadius: 3.0,
        borderWidth: 10.0,
        borderLength: 30.0,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    String? prevText;
    setState(() {
      _QrCodeScannerState.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (scanData.code != prevText) {
          result = scanData;
          String? resultText = result!.code;
          prevText = resultText;
          bool repeated = false;

          for (var name in _HomeScreenState.namesOfStudents) {
            if (resultText?.split('::')[0] == name) {
              repeated = true;
              break;
            } else {
              repeated = false;
            }
          }

          if (repeated == false) {
            try {
              if (resultText?.split(':')[1] == 'SECRET_KEY') {
                var hour = DateTime.now().hour;
                var minute = DateTime.now().minute < 10
                    ? '0${DateTime.now().minute}'
                    : DateTime.now().minute;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("${resultText?.split(":")[0]}::$hour:$minute"),
                    duration: const Duration(seconds: 2),
                  ),
                );
                _HomeScreenState.widgets.add(
                  ListTile(
                    tileColor: Colors.yellow,
                    title: Text(
                      '${resultText?.split(':')[0]}::$hour:$minute',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => null,
                  ),
                );
                _HomeScreenState.namesOfStudents
                    .add("${resultText?.split(':')[0]}::$hour:$minute");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("INVALID QR CODE"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            } catch (e) {
              print("An error has occured.");
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This QR Code has already been scanned."),
              ),
            );
          }
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

class StudentsHomeScreen extends StatefulWidget {
  const StudentsHomeScreen({super.key});

  @override
  State<StudentsHomeScreen> createState() => _StudentsHomeScreenState();
}

class _StudentsHomeScreenState extends State<StudentsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
    );
  }
}
