import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() => runApp(MyApp());




void sendData(title, description, status) async{

  // Set up the data to be sent in the request body
  Map<String, String> data = {
    'title': '$title',
    'description': '$description',
    'status': '$status',
  };

  // Encode the data as a JSON string
  var body = json.encode(data);

  // Make the POST request
  var response = await http.post(
    Uri.parse('https://pcc.edu.pk/ws/bscs2020/services.php'),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  // Parse the JSON response
  var responseData = json.decode(response.body);

  // Access the 'message' key in the response
  print(responseData['message']);
  print("Data sent");

}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

/*class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome to my app!'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'My App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page1()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
*/



class MyHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  List<Data> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _getData();
              setState(() {});
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'My App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Add Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page1()),
                );

              },
            ),



          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_dataList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _dataList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_dataList[index].title),
            subtitle: Text(_dataList[index].description)
            ,

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [
                _dataList[index].isActive.toLowerCase() == 'active'
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),

                IconButton(
                  icon: Icon(Icons.edit),
                  // onPressed: () => _editData(context, _dataList[index]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(data: _dataList[index]),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteData(context, _dataList[index].id),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _getData() async {
    try {
      final response = await http.get(Uri.parse('https://pcc.edu.pk/ws/bscs2020/services.php'));
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _dataList = responseData.map((json) => Data.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _editData(BuildContext context, Data data) {
    // handle editing data here
  }

  void _deleteData(BuildContext context, String id)async {
    // handle deleting data here
    print("id is " + id);
    var response = await http.delete(
      Uri.parse('https://pcc.edu.pk/ws/bscs2020/services.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      if (data['message'] == 'Data deleted successfully') {

      } }
  }
}

class Data {
  final String id;
  late final String title;
  late final String description;
  late final String isActive;

  Data({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isActive: json['status']
    );
  }
}


/*
class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Data'),
      ),
      body: Center(
        child: Text('This is Page 1'),
      ),
    );
  }
}*/
class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('Status: '),
                Switch(
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                Text(_isActive ? 'Active' : 'Inactive'),
              ],
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _addData,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addData() {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final status = _isActive ? 'Active' : 'Inactive';
    sendData(title, description, status);
    // do something with the data here, such as saving it to a database

    // clear the text fields
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _isActive = true;
    });

    // show a snackbar to indicate success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data added: $title, $description, $status'),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final Data data;

  EditPage({required this.data});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _statusController;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _descriptionController =
        TextEditingController(text: widget.data.description);
    _statusController = TextEditingController(text: widget.data.isActive);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status',
              ),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: _updateData,
            ),
          ],
        ),
      ),
    );
  }

  void _updateData () async{
    String id = widget.data.id;
    String title = _titleController.text;
    String description = _descriptionController.text;
    String status = _statusController.text;
    //(widget.data.id,_titleController.text,_descriptionController.text,_statusController.text)

    print("id is"+id);
    var response = await http.put(
      Uri.parse('https://pcc.edu.pk/ws/bscs2020/services.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'title':title, 'description':description, 'status': status }),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      if (data['message'] == 'Data Updated successfully') {

      } }


  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }


}




