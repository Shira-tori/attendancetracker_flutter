import 'dart:io';
import 'dart:convert';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendify_/sql.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
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
                          'SELECT fullname, username, password, role_id, users_tbl.user_id, flutter_teachers_tbl.teacher_id FROM users_tbl INNER JOIN flutter_teachers_tbl ON flutter_teachers_tbl.user_id = users_tbl.user_id WHERE username = "${usernameController.text}" AND password = "${passwordController.text}"');
                      if (result.isNotEmpty) {
                        for (var row in result) {
                          if (row[3] == 1) {
                            print(row[5]);
                            List<Object> argumets = [row[0], row[4], row[5]];
                            // ignore: use_build_context_synchronously
                            Navigator.pushNamed(context, "/teachers_homescreen",
                                arguments: argumets);
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
  List<Widget> widgets = [];
  List<Widget> absentWidgets = [];
  List<String?> namesOfStudents = [];
  List<String?> absentees = [];
  late int lengthOfAbsentees;
  late int lengthOfNamesOfStudents;
  var profilePic;
  bool profilePicLoaded = false;
  bool gotStudnets = false;

  void checkPfpInDatabase(args) async {
    Database db = Database();
    var conn = await db.getConnection();
    var result =
        await conn.query("SELECT pfp FROM users_tbl WHERE fullname = '$args'");
    for (var row in result) {
      if (row[0] != null) {
        setState(() {
          profilePic = base64Decode(
            row[0].toString(),
          );
        });
      }
    }

    conn.close();
  }

  void getStudents(user_id) async {
    var teacher_id;
    Database db = Database();
    var conn = await db.getConnection();
    var teacher_id_result = await conn.query(
        "SELECT teacher_id FROM flutter_teachers_tbl INNER JOIN users_tbl ON users_tbl.user_id = flutter_teachers_tbl.user_id WHERE flutter_teachers_tbl.user_id = $user_id");
    for (var row in teacher_id_result) {
      teacher_id = row[0];
    }
    var result = await conn.query(
        "SELECT student_fullname FROM flutter_students_tbl WHERE teacher_id = $teacher_id");
    conn.close();
    for (var row in result) {
      setState(
        () {
          absentees.add(row[0]);
        },
      );
    }
  }

  void addPresent() {
    setState(() {
      namesOfStudents.length = namesOfStudents.length;
      absentees.length = absentees.length;
    });
  }

  @override
  void dispose() {
    widgets = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Object> args =
        ModalRoute.of(context)!.settings.arguments as List<Object>;
    List<String> name = args[0].toString().split(" ");
    if (profilePicLoaded == false) {
      checkPfpInDatabase(args[0].toString());
      profilePicLoaded = true;
    }
    if (gotStudnets == false) {
      getStudents(args[1]);
      gotStudnets = true;
    }
    lengthOfAbsentees = absentees.length;
    lengthOfNamesOfStudents = namesOfStudents.length;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF416E8E),
          title: const Text(
            "Attendify",
            style: TextStyle(color: Colors.white),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: "Muli-Bold",
            fontSize: 20,
          ),
          bottom: TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.black,
            indicator: const BoxDecoration(color: Color(0xFFCBF7ED)),
            tabs: <Widget>[
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.home),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Tracker')
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
                    Text('Scanner')
                  ],
                ),
              ),
            ],
          ),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        body: TabBarView(
          children: <Widget>[
            Scaffold(
              body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/bg2.jpg"),
                      fit: BoxFit.cover,
                      colorFilter:
                          ColorFilter.mode(Color(0xdd416e8e), BlendMode.darken),
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xCC22395C),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    right: 20, bottom: 10, top: 10),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) =>
                                                    const Color(0xFFCBF7ED))),
                                    onPressed: () async {
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2023, 3),
                                          lastDate: DateTime(2023, 7));
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_outlined,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          " ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                            fit: FlexFit.loose,
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green.shade500,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30))),
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                270,
                                        height: 210,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                                return Scaffold(
                                                  appBar: AppBar(
                                                    backgroundColor:
                                                        const Color(0xFF416E8E),
                                                  ),
                                                  body: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "images/bg2.jpg"),
                                                            fit: BoxFit.cover,
                                                            colorFilter:
                                                                ColorFilter.mode(
                                                                    Color(
                                                                        0xdd1C4274),
                                                                    BlendMode
                                                                        .darken)),
                                                      ),
                                                      child: ListView(
                                                        children: widgets,
                                                      )),
                                                );
                                              }),
                                            );
                                          },
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text("PRESENT",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "Muli-Bold")),
                                                const Icon(Icons.person_sharp,
                                                    size: 70),
                                                Text(
                                                  "${namesOfStudents.length}",
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )
                                              ]),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (absentWidgets.isEmpty) {
                                            for (var name in absentees) {
                                              absentWidgets.add(
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(8),
                                                  child: Material(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  20)),
                                                      color: const Color(
                                                          0xFFCBF7ED),
                                                      child: ListTile(
                                                          title: Text(name!))),
                                                ),
                                              );
                                            }
                                          }

                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      const Color(0xFF416E8E),
                                                ),
                                                body: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "images/bg2.jpg"),
                                                          fit: BoxFit.cover,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  Color(
                                                                      0xdd1C4274),
                                                                  BlendMode
                                                                      .darken)),
                                                    ),
                                                    child: ListView(
                                                        children:
                                                            absentWidgets)),
                                              );
                                            },
                                          ));
                                        },
                                        child: Container(
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFDB4E4E),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            margin: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                270,
                                            height: 210,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text("ABSENT",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "Muli-Bold")),
                                                const Icon(Icons.person_off,
                                                    size: 70),
                                                Text("${absentees.length}",
                                                    style: const TextStyle(
                                                        fontFamily: "Muli-Bold",
                                                        fontSize: 30))
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Flexible(
                            fit: FlexFit.loose,
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Material(
                                    color: const Color(0xFFCBF7ED),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: ListTile(
                                      title: const Text("Masterlist",
                                          style: TextStyle(
                                              fontFamily: "Muli-Bold")),
                                      onTap: () async {
                                        List<Widget> studentsList = [];
                                        if (studentsList.isEmpty) {
                                          var db = Database();
                                          var conn = await db.getConnection();
                                          var result = await conn.query(
                                              "SELECT student_fullname FROM flutter_students_tbl WHERE teacher_id = ${args[2]} ORDER BY student_fullname ASC");
                                          for (var row in result) {
                                            studentsList.add(
                                              Container(
                                                margin: const EdgeInsets.all(8),
                                                child: Material(
                                                  color:
                                                      const Color(0xFFCBF7ED),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
                                                  child: ListTile(
                                                    leading: const Icon(
                                                        Icons.person),
                                                    style: ListTileStyle.list,
                                                    title: Text(
                                                      row[0],
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              "Muli-Bold"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) {
                                              return Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      const Color(0xFF416E8E),
                                                ),
                                                body: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          "images/bg2.jpg"),
                                                      fit: BoxFit.cover,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              Color(0xdd1C4274),
                                                              BlendMode.darken),
                                                    ),
                                                  ),
                                                  child: ListView(
                                                      children: studentsList),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 2),
                                  child: Material(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: const Color(0xFFCBF7ED),
                                    child: ListTile(
                                      title: const Text("Export as Excel",
                                          style: TextStyle(
                                              fontFamily: "Muli-Bold")),
                                      onTap: () async {
                                        Permission.accessMediaLocation
                                            .request();
                                        List<Directory>? saveDir =
                                            await getExternalStorageDirectories(
                                                type:
                                                    StorageDirectory.documents);
                                        String directory = saveDir![0].path;
                                        print(directory);
                                        var now = DateTime.now();
                                        var attendanceExcel =
                                            Excel.createExcel();
                                        Sheet attendanceSheet = attendanceExcel[
                                            '${now.year}-${now.month}-${now.day}'];
                                        attendanceSheet
                                            .cell(CellIndex.indexByString('A1'))
                                            .value = 'STUDENT';
                                        attendanceSheet
                                            .cell(CellIndex.indexByString('B1'))
                                            .value = 'TIME';
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text("Export"),
                                            content:
                                                const Text("Are you sure?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    var counter = 2;
                                                    for (var names
                                                        in namesOfStudents) {
                                                      attendanceSheet
                                                              .cell(CellIndex
                                                                  .indexByString(
                                                                      'A$counter'))
                                                              .value =
                                                          names?.split('::')[0];
                                                      attendanceSheet
                                                              .cell(CellIndex
                                                                  .indexByString(
                                                                      'B$counter'))
                                                              .value =
                                                          names?.split('::')[1];
                                                      counter++;
                                                    }
                                                    List<int>? fileBytes =
                                                        attendanceExcel.save();

                                                    File(
                                                        "$directory/${now.year}-${now.month}-${now.day}.xlsx")
                                                      ..createSync(
                                                          recursive: true)
                                                      ..writeAsBytes(
                                                          fileBytes!);
                                                    Navigator.pop(context);
                                                    OpenFile.open(
                                                        "$directory/${now.year}-${now.month}-${now.day}.xlsx");
                                                  },
                                                  child: const Text("Yes")),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("No")),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  )),
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
              child: Center(
                child: QrCodeScanner(
                    addPresent: addPresent,
                    namesOfStudents: namesOfStudents,
                    absentees: absentees,
                    widgets: widgets,
                    absentWidgets: absentWidgets,
                    teacher_id: args[2]),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF416E8E),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 250,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/drawerbg.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Color(0xf1416E8E), BlendMode.darken),
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
                                        "UPDATE users_tbl SET pfp = '$base64' WHERE fullname = '${args[0].toString()}'");
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
                                        radius: 70,
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
                                args[0].toString(),
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
  final Function addPresent;
  var namesOfStudents;
  var absentees;
  var widgets;
  var teacher_id;
  var absentWidgets;

  QrCodeScanner({
    super.key,
    required this.addPresent,
    required this.namesOfStudents,
    required this.absentees,
    required this.widgets,
    required this.teacher_id,
    required this.absentWidgets,
  });

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

          for (var name in widget.namesOfStudents) {
            print(name);
            if (resultText?.split(':')[0] == name.toString().split("::")[0]) {
              repeated = true;
              break;
            } else {
              repeated = false;
            }
          }

          if (repeated == false) {
            try {
              if (resultText?.split(':')[2] == 'SECRET_KEY' &&
                  resultText?.split(':')[1] ==
                      widget.teacher_id.toString().trim()) {
                var hour = DateTime.now().hour;
                var minute = DateTime.now().minute < 10
                    ? '0${DateTime.now().minute}'
                    : DateTime.now().minute;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Name: ${resultText?.split(":")[0]}, Time: $hour:$minute, Teacher_ID: ${widget.teacher_id}"),
                    duration: const Duration(seconds: 2),
                  ),
                );
                widget.widgets.add(
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: const Color(0xFFCBF7ED),
                      child: ListTile(
                        subtitle: Text("Time: $hour:$minute"),
                        title: Text(
                          '${resultText?.split(':')[0]}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () => null,
                      ),
                    ),
                  ),
                );

                widget.namesOfStudents
                    .add("${resultText?.split(':')[0]}::$hour:$minute");
                widget.absentees.remove("${resultText?.split(':')[0]}");
                int counter = 0;
                for (var row in widget.absentWidgets) {
                  if (row.child.child.title.data ==
                      "${resultText?.split(':')[0]}") {
                    widget.absentWidgets.remove(row);
                    break;
                  }
                  counter++;
                }
                print(
                    "${resultText?.split(':')[0]}, ${widget.namesOfStudents[widget.namesOfStudents.length - 1]}");
                print(
                    "namesOfStudents: ${widget.namesOfStudents.length}, absentees: ${widget.absentees.length}");
                widget.addPresent();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("INVALID QR CODE"),
                    duration: Duration(seconds: 1),
                  ),
                );
                print(resultText?.split(':'));
              }
            } catch (e) {
              print(e);
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
