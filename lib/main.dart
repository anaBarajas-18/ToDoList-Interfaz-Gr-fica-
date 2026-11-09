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
      debugShowCheckedModeBanner: false,
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

  // Agregar una nueva tarea (Evitando duplicados)
  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // Verificamos si la tarea ya existe
      if (_tasks.contains(text)) {
        // Mostramos una alerta si está duplicada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta tarea ya existe en la lista'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _tasks.add(text);
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

  // Editar una tarea
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
              final newText = editController.text.trim();
              if (newText.isNotEmpty && !_tasks.contains(newText)) {
                setState(() {
                  _tasks[index] = newText;
                });
                Navigator.pop(context);
              } else if (_tasks.contains(newText) && newText != _tasks[index]) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Esa tarea ya existe')),
                );
              } else {
                Navigator.pop(context); // Si está vacío, solo cerramos
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Reordenar las tareas (Arrastrar y soltar)
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
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
                  onPressed: _addTask, // Botón de agregar corregido
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista Reordenable con Dismissible
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _tasks.length,
              onReorder: _onReorder, // Función para mover arriba/abajo
              buildDefaultDragHandles:
                  false, // Desactivamos el arrastre por defecto
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: ValueKey(task), // Usamos el texto como clave única
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
                  // LA MAGIA PARA QUE NO SE ROMPA LA PANTALLA:
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editTask(index); // Abre el diálogo de edición
                      return false; // Evita que la tarea se borre al editar
                    }
                    return true; // Permite borrar al deslizar a la izquierda
                  },
                  onDismissed: (direction) {
                    _deleteTask(index); // Borra la tarea de la lista
                  },
                  child: ListTile(
                    title: Text(task),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      // Este es el ícono que se puede arrastrar
                      child: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
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
