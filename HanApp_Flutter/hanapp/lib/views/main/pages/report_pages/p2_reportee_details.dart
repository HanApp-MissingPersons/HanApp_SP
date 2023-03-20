import 'package:flutter/material.dart';

class Page2ReporteeDetails extends StatefulWidget {
  const Page2ReporteeDetails({super.key});

  @override
  State<Page2ReporteeDetails> createState() => _Page2ReporteeDetailsState();
}

// padding variable for the rows
const _padding = SizedBox(height: 10);

class _Page2ReporteeDetailsState extends State<Page2ReporteeDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

// error message: empty field
  static const String _emptyFieldError = 'Field cannot be empty';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Checkboxes for classifiers
      Positioned(
        top: 100,
        left: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Page 2 of 6: Reportee Details',
              style: optionStyle,
            ), // Page 1 Text
            // add padding between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info),
                SizedBox(width: 5),
                Text(
                  '''Fields with * are required.''',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            _padding,
            // Section: Reportee Name
            const Text(
              "Reportee Name",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              // center the row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // last name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                ),
                _padding,
                // first name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                ),
                _padding,
                // middle name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Middle Name',
                    ),
                  ),
                ),
                _padding,
                // qualifier (Jr, Sr, III, etc)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Qualifier',
                    ),
                  ),
                ),
                _padding,
                // Nickname / Known Aliases
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nickname / Known Aliases',
                    ),
                  ),
                ),
              ],
            ),
            _padding,

            // Section: Reportee Citizenship
            const Text(
              "Citizenship",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Citizenship*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            _padding,
            // Section: Sex
            const Text(
              "Sex",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              // center the row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // radio for sex selection:
                Radio(
                  value: 1,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width - 50,
                //   // radio for sex selection
                //   // child: TextFormField(
                //   //   decoration: const InputDecoration(
                //   //     border: OutlineInputBorder(),
                //   //     labelText: 'Sex*',
                //   //   ),
                //   //   // add validator:
                //   //   validator: (value) {
                //   //     if (value == null || value.isEmpty) {
                //   //       return _emptyFieldError;
                //   //     }
                //   //     return null;
                //   //   },
                //   // ),
                // )
              ],
            ),
            _padding,
          ],
        ),
      ),
    ]);
  } // end of build
}
