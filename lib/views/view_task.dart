//import 'package:aura_techwizard/components/app_drawer.dart';
import 'package:aura_techwizard/localization/locales.dart';
import 'package:aura_techwizard/models/task.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class ViewTask extends StatefulWidget {
  const ViewTask({super.key});

  @override
  State<ViewTask> createState() => _ViewTaskState();
}

class _ViewTaskState extends State<ViewTask> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  List<Task> _tasks2 = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _loadTasks(userProvider.getUser!.uid);
    }
  }

  Future<void> _loadTasks(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();
    final tasks = snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
        final QuerySnapshot snapshot2 = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .get();
    final tasks2 = snapshot2.docs.map((doc) => Task.fromDocument(doc)).toList();
    setState(() {
      _tasks = tasks;
      _tasks2 = tasks2;
    });
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    bool newStatus = !task.isCompleted; // Toggle completion state

    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': newStatus,
    });

  setState(() {
      if (newStatus) {
        _tasks.remove(task);
        _tasks2.add(task.copyWith(isCompleted: true));
      } else {
        _tasks2.remove(task);
        _tasks.add(task.copyWith(isCompleted: false));
        _reorganizeTasks(); // Reorganize automatically after moving back
      }
    });
  }

  void _reorganizeTasks() {
    setState(() {
      _tasks.sort((a, b) {
        int weightA = (getPriorityWeight(a.priority) * 500) - a.getTotalMinutes();
        int weightB = (getPriorityWeight(b.priority) * 500) - b.getTotalMinutes();
        return weightB.compareTo(weightA); // Sort in descending order
      });
    });
  }

    Future<void> _addTask(String title, String priority,String hours, String minutes) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newTask = Task(
      id: '',
      title: title,
      priority: priority,
      userId: userProvider.getUser!.uid,
      hours: int.parse(hours),
      minutes: int.parse(minutes),
    );
    final docRef = await _firestore.collection('tasks').add(newTask.toMap());
    setState(() {
      _tasks.add(newTask.copyWith(id: docRef.id));
    });
  }



  int getPriorityWeight(String priority) {
    switch (priority) {
      case 'High': return 3;
      case 'Medium': return 2;
      case 'Low': return 1;
      default: return 1;
    }
  }

  Widget _buildTasks() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Add Task Title at the Top
      Center(
        child: Text(
          LocaleData.yourTasks.getString(context),
          style: const TextStyle(
            color: Color(0xFF2E4052),
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 16.0),

      // Centered Buttons Row
      Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
        children: [
          ElevatedButton(
            onPressed: _reorganizeTasks,
            child: const Text('Reorganize Tasks'),
          ),
          const SizedBox(width: 10), // Space between buttons
          ElevatedButton(
            onPressed: _showAddTaskDialog,
            child: const Text('Add Task'),
          ),
        ],
      ),
      const SizedBox(height: 16.0),

      // Task List
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children:[
             ..._tasks.map((task) => _buildTaskItem(task)).toList(),
             const Divider(height: 30, thickness: 2),
                // Completed Tasks
              ..._tasks2.map((task) => _buildTaskItem(task)).toList(),
            ] 
              
          ),
          
        ),
      ),
    ],
  );
}


  Widget _buildTaskItem(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListTile(
        title: Text(task.title, style: const TextStyle(fontSize: 18.0)),
        subtitle: Text("Priority: ${task.priority} | Duration: ${task.hours}h ${task.minutes}m"),
        trailing: GestureDetector(
          onTap: () => _toggleTaskCompletion(task),
          child: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController hoursController = TextEditingController();
    final TextEditingController minutesController = TextEditingController();
    String priority = 'Low';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              DropdownButton<String>(
                value: priority,
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
                items: ['Low', 'Medium', 'High']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
              ),
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(labelText: 'Hours Required'),
              ),
              TextField(
                controller: minutesController,
                decoration: const InputDecoration(labelText: 'Minutes Required'),
              )

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addTask(titleController.text, priority,hoursController.text, minutesController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Tasks")),
      //drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTasks(),
            ),
    );
  }
}
