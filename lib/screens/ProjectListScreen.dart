import 'package:flutter/material.dart';
import 'package:softezi_flutter/screens/AddProjectScreen.dart';
import 'package:softezi_flutter/utils/globals.dart';
import 'package:softezi_flutter/utils/generate_pdf.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Map> projectsList = [];
  bool loading = true;

  @override
  initState() {
    super.initState();
    _getProjectList();
  }

  Future<void> _getProjectList() async {
    setState(() {
      loading = true;
    });

    String companyId = await getCompanyId();
    projectsList = await firebaseFirestore
        .collection('projects')
        .where('company_id', isEqualTo: companyId)
        .get()
        .then((value) =>
            value.docs.map((e) => {'id': e.id, ...e.data()}).toList());

    print(projectsList);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Projects'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProjectScreen()),
              );
            },
          ),
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'downloadPDF') {
                final generatePdf = GeneratePDF(projectsList: projectsList);
                await generatePdf.writeOnPdf();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Download as PDF'),
                  value: 'downloadPDF',
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (loading)
            LinearProgressIndicator()
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _getProjectList(),
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 10),
                  itemCount: projectsList.length,
                  itemBuilder: (context, index) {
                    Map project = projectsList[index];

                    return ListTile(
                      title: Text(
                        project['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        project['location']['city'] +
                            ', ' +
                            project['location']['country'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '0 Employee working',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RowHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white24),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Project Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class TableRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Text(
            'Nivesh',
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
