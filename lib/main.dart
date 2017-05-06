import 'package:Organizer/models.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

final ThemeData _themeData = new ThemeData(
  primaryColor: Colors.blue,
);

typedef void OnAddTodoItem(Todo todo);

class MyApp extends StatefulWidget {

  MyApp({Key key, this.todos}) : super(key: key);

  final List<Todo> todos;

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Todo> _todos = new List<Todo>();

  @override
  void initState() {
    super.initState();

    this._todos.add(new Todo('test', 'test', false));
  }

  void _handleAddTodoItem(Todo todo) {
    setState(() {
      this._todos.add(todo);
    });
  }

  Route<Null> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');
    print(path[0]);
    if (path[0] != '')
      return null;
    if (path[1] == 'todo') {
      if (this._todos[int.parse(path[2])] != null) {
        return new MaterialPageRoute<Null>(
            settings: settings,
            builder: (BuildContext context) => new TodoItemDetail(todo: this._todos[int.parse(path[2])])
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var _routes = <String, WidgetBuilder>{
      '/todoDetail': (BuildContext context) => new TodoItemDetail(),
    };

    return new MaterialApp(
      title: 'My App',
      theme: _themeData,
      home: new TodoList(this._todos, this._handleAddTodoItem),
      routes: _routes,
      onGenerateRoute: _getRoute,
    );
  }
}

class TodoList extends StatelessWidget {

  List<Todo> todos = new List<Todo>();
  OnAddTodoItem onAddTodoItem;

  TodoList(this.todos, this.onAddTodoItem);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text('My Organizer'),
        ),
        body: new ListView(
            children: this.todos.map((Todo todo) {
              return new TodoListItem(
                  todo: todo,
                  id: this.todos.length - 1
              );
            }).toList()
        ),
        floatingActionButton: new FloatingActionButton(
            tooltip: 'Add',
            child: new Icon(Icons.add),
            onPressed: () => this.onAddTodoItem(new Todo('', '', false)),
        ),
    );
  }
}


class TodoListItem extends StatelessWidget {

  TodoListItem({Key key, Todo todo, int id})
      : todo = todo,
        id = id,
        super(key: new ObjectKey(todo));

  final int id;
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(this.todo.title),
      subtitle: new Text(this.todo.body),
      trailing: new IconButton(icon: new Icon(Icons.add), onPressed: null),
      enabled: true,
      onTap: () => Navigator.pushNamed(context, '/todo/${id}'),
    );
  }
}

class TodoItemDetail extends StatelessWidget {

  TodoItemDetail({Key key, Todo todo})
      : todo = todo,
        super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Detailpage'),
      ),
      body: new Container(
        child:
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new Text(this.todo.title),
            ),
          ],
        ),
      ),
    );
  }
}
