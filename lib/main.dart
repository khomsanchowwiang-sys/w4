import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform

  );
  runApp(const MyApp());





}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  //Ctrl เก็บค่าทุกอย่าง
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();


  //เรียกใช้ตอนกดปุ่ม
  //Voide ตือ ไม่คืนค่า
  void addSong() async {
    //.text คืิอดึงค่าที่เรากรอก ไว้ใน String
    String _songname = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songtype = _songTypeCtrl.text;


    print("ค่าที่เก็บไว้  $_songname | $_name | $_songtype");

//  try พยยาม
    //ให้บันทึกลงไปใน Store
    try {
      //รอ
      //collection("songs")  ดึงค่า สำคัญ
  await FirebaseFirestore.instance.collection("songs").add({

    //จับคู่
    "songname" : _songname,
     "artis" : _name,
    "songType" : _songtype,

  });
//เคลียร์ ช่องว่างหลังพิมพ์ ละกดบันทึก
    _songNameCtrl.clear();
  _nameCtrl.clear();
  _songTypeCtrl.clear();
    //เออเร่อgเล้วจะไปโชว์ที่ Console
      //e คือตัวใดตัวเเปรหนึง
    } catch (e) {
      print("เกิดข้อผิดพลาด : $e");
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Column(children: [

        //จีับคุ๋ กะCrtl
      TextField(
        decoration: InputDecoration(labelText: "ชิ้อเพลง"),
        controller: _songNameCtrl,

      ),
        TextField(
          decoration: InputDecoration(labelText: "ชิ้อศิลปิน"),
          controller: _nameCtrl,
        ),
        TextField(
          decoration: InputDecoration(labelText: "เเนวเพลง"),
          controller: _songTypeCtrl,
        ),

        ElevatedButton(onPressed: addSong, child: Text("บันทึก")),
        Expanded(child:
        StreamBuilder(

          //ดึงจาก   await FirebaseFirestore.instance.collection("songs").add({
            stream: FirebaseFirestore.instance.collection("songs").snapshots(),

            //เเสดงผลออกมา
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);

              }
              //เกิดข้อผิดพฃาดด
              if(snapshot.hasError){

                //ส่งไปยัง snapshot เป็นเป็น to string
                return Center(child: Text(snapshot.error.toString()),);
              }
              //ถ้าสำเร็จก็ดึงข้อมูลมาทั้งหมด docs
              final docs = snapshot.data!.docs;
              //เเกรนหลักคือเเนวตั้ง Colum  (main)
              //เเกรนขวางคือเเนวนอน row (Cross)

              //crossAxisCount จะมีจำนวนเท่าไหร่
              return GridView.builder(
                  //เพิ่มitemCount กัน error
                itemCount: docs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   //จำนวนที่จะเเสดงต่อเเุถว
                  crossAxisCount: 3,

                      //ขนาดกรอบ
                    crossAxisSpacing: 10,
                      //ระยะห่าง
                    mainAxisSpacing: 30
                   ),
                  itemBuilder: (context, index){
                    final songs =  docs[index];
                    final s = songs.data();
                    //InkWell ครอบ UI ตัวไหนก็ได้ สามารถคลิกได้ เเล้วสามารถไปเรียกฟังชั่นอื่นได้
                    return InkWell(

                      // ontap  คลิดเข้าไปจะไปหน้า Songdetail
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetail(song: s)));
                      },
                      child: Card(child: Text(s["songname"]),),);

                  }
              );
                  
                  
            }
        )


        )
      ],),),

    );
  }
}

// คลาสใหม่
class SongDetail extends StatelessWidget {
  final dynamic song;

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    // ดึง Theme มาใช้เพื่อความสวยงาม
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดเพลง"),
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0), // เว้นขอบรอบๆ
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // จัดทุกอย่างให้อยู่กึ่งกลางจอ
            children: [
              // ตกแต่ง: ไอคอนเพลงขนาดใหญ่
              Icon(
                Icons.music_note_rounded,
                size: 150,
                color: colorScheme.primary,
              ),

              const SizedBox(height: 30), // เว้นระยะห่าง

              // 1. ชื่อเพลง (ตัวใหญ่หนา)
              Text(
                song["songname"] ?? "ไม่มีชื่อเพลง",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // 2. ชื่อศิลปิน
              Text(
                "ศิลปิน: ${song["artis"] ?? "-"}",
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 10),

              // 3. แนวเพลง (ใส่สีให้เด่นนิดนึง)
              Text(
                "แนวเพลง: ${song["songType"] ?? "-"}",
                style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}