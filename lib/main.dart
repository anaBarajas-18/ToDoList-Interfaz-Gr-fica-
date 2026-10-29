import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // Lista de tareas
  final List<String> _tasks = [
    'tarea5',
    'tarea1',
    'tarea4',
    'tarea2',
    'tarea3',
  ];
  final TextEditingController _controller = TextEditingController();

  // Agregar una nueva tarea
  void _addTask() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text.trim());
        _controller.clear();
      });
    }
  }

  // Eliminar una tarea
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  // Editar una tarea (muestra un dialogo)
  void _editTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: _tasks[index],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _tasks[index] = editController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Campo de entrada y boton "+"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa una tarea...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de tareas con Dismissible
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(
                    task + index.toString(),
                  ), // Clave unica para cada elemento
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Si se desliza a la derecha (startToEnd), editar
                    if (direction == DismissDirection.startToEnd) {
                      _editTask(index);
                      // Forzar la reconstruccion para que el elemento vuelva a su lugar
                      setState(() {});
                    } else {
                      // Si se desliza a la izquierda (endToStart), eliminar
                      _deleteTask(index);
                    }
                  },
                  child: ListTile(
                    title: Text(task),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
