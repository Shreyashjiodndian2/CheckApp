import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class GeneratePDF {
  GeneratePDF({this.projectsList});

  final List<Map> projectsList;

  writeOnPdf() async {
    final pw.Document pdf = pw.Document();
    final font = await rootBundle.load("assets/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);
    final fontBold = await rootBundle.load("assets/OpenSans-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontBold);
    final fontItalic = await rootBundle.load("assets/OpenSans-Italic.ttf");
    final ttfItalic = pw.Font.ttf(fontItalic);
    final fontBoldItalic =
        await rootBundle.load("assets/OpenSans-BoldItalic.ttf");
    final ttfBoldItalic = pw.Font.ttf(fontBoldItalic);
    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttfBold,
      italic: ttfItalic,
      boldItalic: ttfBoldItalic,
    );

    List data = projectsList.toList();

    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Text(
            "Projects",
            style: pw.TextStyle(
              fontSize: 22.0,
              decoration: pw.TextDecoration.underline,
              decorationThickness: 2.0,
            ),
          ),
//          pw.Header(
//            child: pw.Text(
//              "Projects",
//              style: pw.TextStyle(fontSize: 20.0),
//            ),
//          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Table.fromTextArray(data: <List<String>>[
            <String>['Name', 'Location'],
            ...data.map((e) => [e['name'], e['location']['country']])
          ]),
//          pw.ListView.builder(
//              itemBuilder: (context, index) {
//                Map project = projectsList[index];
//                return pw.Row(children: [
//                  pw.Text(
//                    project['name'],
//                  ),
//                  pw.Text(
//                    project['location']['city'] +
//                        ', ' +
//                        project['location']['country'],
//                  ),
//                ]);
//              },
//              itemCount: projectsList.length),
        ];
      },
    ));
    //Saving the file
    final Directory directory = await getExternalStorageDirectory();
    final String path = directory.path;
    final String filePath = '$path/test_pdf.pdf';
    final File file = File(filePath);
    file.writeAsBytesSync(pdf.save());
    print(directory);
    print(file);
  }
}
