import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JobTrackerHomePage(),
    );
  }
}

class JobTrackerHomePage extends StatefulWidget {
  @override
  _JobTrackerHomePageState createState() => _JobTrackerHomePageState();
}

class _JobTrackerHomePageState extends State<JobTrackerHomePage> {
  int _selectedIndex = 0;
  List<Map<String, String>> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jobsData = prefs.getString('jobs');
    if (jobsData != null) {
      setState(() {
        _jobs = List<Map<String, String>>.from(json.decode(jobsData));
      });
    }
  }

  Future<void> _saveJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jobs', json.encode(_jobs));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addJob(Map<String, String> job) {
    setState(() {
      _jobs.add(job);
      _saveJobs();
      _selectedIndex = 0;
    });
  }

  void _updateJob(int index, Map<String, String> job) {
    setState(() {
      _jobs[index] = job;
      _saveJobs();
    });
  }

  void _deleteJob(int index) {
    setState(() {
      _jobs.removeAt(index);
      _saveJobs();
    });
  }

  int _getStatusCount(String status) {
    return _jobs.where((job) => job['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildHomeScreen() : _buildAddScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 17.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Job Tracker',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Application Insight',
              style: TextStyle(color: Colors.white60, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusCard('Applied', _getStatusCount('Applied'), Colors.blue),
                    _buildStatusCard('Rejected', _getStatusCount('Rejected'), Colors.red),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusCard('Pending', _getStatusCount('Pending'), Colors.orange),
                    _buildStatusCard('Successful', _getStatusCount('Successful'), Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'My Applications',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      _jobs[index]['jobName'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 16.5),
                    ),
                    subtitle: Text(
                      'Applied on: ${_jobs[index]['dateApplied']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_jobs[index]['status']),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _jobs[index]['status'] ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(
                            job: _jobs[index],
                            index: index,
                            onUpdate: (index, job) {
                              _updateJob(index, job);
                              setState(() {});
                            },
                            onDelete: (index) {
                              _deleteJob(index);
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobListByStatusScreen(
                status: title,
                jobs: _jobs,
                onUpdate: (index, job) {
                  _updateJob(index, job);
                  setState(() {});
                },
                onDelete: (index) {
                  _deleteJob(index);
                  setState(() {});
                },
              ),
            ),
          );
        },
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                SizedBox(height: 12),
                Text(
                  count.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Applied':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Successful':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAddScreen() {
    return AddJobForm(onSave: _addJob);
  }
}

class AddJobForm extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  AddJobForm({required this.onSave});

  @override
  _AddJobFormState createState() => _AddJobFormState();
}

class _AddJobFormState extends State<AddJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _jobNameController = TextEditingController();
  final _dateAppliedController = TextEditingController();
  String _status = 'Applied';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _jobNameController,
              decoration: InputDecoration(
                labelText: 'Job Name',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the job name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _dateAppliedController,
              decoration: InputDecoration(
                labelText: 'Date Applied',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the date applied';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _status,
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: <String>['Applied', 'Rejected', 'Pending', 'Successful']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave({
                      'jobName': _jobNameController.text,
                      'dateApplied': _dateAppliedController.text,
                      'status': _status,
                    });
                  }
                },
                child: Text('Save Job',
                style: TextStyle(color: Colors.black)),

              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  final Map<String, String> job;
  final int index;
  final Function(int, Map<String, String>) onUpdate;
  final Function(int) onDelete;

  JobDetailScreen({required this.job, required this.index, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(job['jobName'] ?? 'Job Detail',
        style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Name: ${job['jobName']}', style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 8),
            Text('Date Applied: ${job['dateApplied']}', style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 8),
            Text('Status: ${job['status']}', style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditJobForm(
                      job: job,
                      index: index,
                      onSave: onUpdate,
                    ),
                  ),
                );
              },
              child: Text('Edit Job', style: TextStyle(color: Colors.black),),

            ),
          ],
        ),
      ),
    );
  }
}

class EditJobForm extends StatefulWidget {
  final Map<String, String> job;
  final int index;
  final Function(int, Map<String, String>) onSave;

  EditJobForm({required this.job, required this.index, required this.onSave});

  @override
  _EditJobFormState createState() => _EditJobFormState();
}

class _EditJobFormState extends State<EditJobForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jobNameController;
  late TextEditingController _dateAppliedController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _jobNameController = TextEditingController(text: widget.job['jobName']);
    _dateAppliedController = TextEditingController(text: widget.job['dateApplied']);
    _status = widget.job['status'] ?? 'Applied';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _jobNameController,
                decoration: InputDecoration(
                  labelText: 'Job Name',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the job name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _dateAppliedController,
                decoration: InputDecoration(
                  labelText: 'Date Applied',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the date applied';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                items: <String>['Applied', 'Rejected', 'Pending', 'Successful']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.grey)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(widget.index, {
                        'jobName': _jobNameController.text,
                        'dateApplied': _dateAppliedController.text,
                        'status': _status,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobListByStatusScreen extends StatelessWidget {
  final String status;
  final List<Map<String, String>> jobs;
  final Function(int, Map<String, String>) onUpdate;
  final Function(int) onDelete;

  JobListByStatusScreen({required this.status, required this.jobs, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredJobs = jobs.where((job) => job['status'] == status).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('$status Jobs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: filteredJobs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            color: Colors.grey[900],
            child: ListTile(
              title: Text(filteredJobs[index]['jobName'] ?? '', style: TextStyle(fontSize: 18.5, color: Colors.white)),
              subtitle: Text('Applied on: ${filteredJobs[index]['dateApplied']}', style: TextStyle(color: Colors.grey)),
              trailing: Text(filteredJobs[index]['status'] ?? '', style: TextStyle(fontSize: 12)),
              onTap: () {
                int originalIndex = jobs.indexOf(filteredJobs[index]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(
                      job: filteredJobs[index],
                      index: originalIndex,
                      onUpdate: onUpdate,
                      onDelete: onDelete,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}