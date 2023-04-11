import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/main.dart';

class reportsPNP extends StatefulWidget {
  const reportsPNP({Key? key}) : super(key: key);

  @override
  State<reportsPNP> createState() => _reportsPNPState();
}

class _reportsPNPState extends State<reportsPNP> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');
  List<Map> reportList = [];

  Widget listItem({required Map report}) {
    print('[report] $report');
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: GestureDetector(
        onTap: () {
          print('Tapped');
        },
        child: Row(
          children: [
            SizedBox(
              width: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    color: Colors.indigo,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Report Key: ${report['key']}',
                        //JUST change the font size to 18 when Name is applied
                        style: GoogleFonts.inter(fontSize: 6, fontWeight: FontWeight.w700),
                      ),
                      Text('Minor, Victim of Calamity',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TIME REPORTED
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('11:55', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Time Reported',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                ],
              ),
            ),

            // DATE REPORTED
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('April 11, 2023', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Date Reported',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                ],
              ),
            ),

            // LAST SEEN LOCATION
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Brgy. Maty, Miagao', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Last Tracked Location',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                ],
              ),
            ),

          SizedBox(
            width: 180,
            height: 50,
            child: DropdownButtonFormField<String>(
              // text to display when no value is selected
              hint: Text('Select Report Status'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              value: null,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black54),
              onChanged: null,
              items: <String>[
                'Received',
                'Verified',
                'Already Found',
                'Incomplete Details',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

            // ICONS
            SizedBox(
                width: 150,
                child: Row(
                  children: const [
                    // IconButton(
                    //   icon: isClicked
                    //       ? Icon(Icons.star_outline_rounded)
                    //       : Icon(Icons.star_rounded)
                    //   onPressed: () {
                    //     setState(() {
                    //       isClicked = !isClicked
                    //     });
                    //   })
                    IconButton(icon: Icon(Icons.star_outline_rounded), onPressed: null),
                    IconButton(icon: Icon(Icons.outlined_flag_rounded), onPressed: null),
                  ],

                )
            ),
            const IconButton(
                icon: Icon(Icons.chevron_right_rounded, size: 40, color: Colors.black54,),
                onPressed: null)

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: StreamBuilder(
        stream: dbRef.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SpinKitCubeGrid(color: Palette.indigo, size: 40.0,);
          }
          reportList.clear();
          dynamic values = snapshot.data?.snapshot.value;
          if (values != null) {
            Map<dynamic, dynamic> reports = values;
            // users
            reports.forEach((key, value) {
              dynamic uid = key;
              // reports of each user
              value.forEach((key, value) {
                value['key'] = '${key}__$uid';
                value['uid'] = uid;
                print('[key] $key');
                print('[value] $value');
                reportList.add(value);
              });
            });
            // print('[reports] ${reports.values}');
            // dynamic whoa = Map.fromIterable(reports.values);
            Map<dynamic, dynamic> map = {
              for (var item in reports.values) item: item
            };
            // print(map.keys.length);
            // print('[keys] ${whoa.values}');
          }
          return ListView.builder(
            itemCount: reportList.length,
            itemBuilder: (BuildContext context, int index) {
              return listItem(report: reportList[index]);
            },
          );
        },
      ),
    );
  }
}
