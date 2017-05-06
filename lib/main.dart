import 'package:Organizer/models.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

final ThemeData _themeData = new ThemeData(
  primaryColor: Colors.blue,
);

typedef void OnAddTodoItem(Todo todo);
typedef void OnChangeTodoStatus(Todo todo);

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

  void _handleChangeTodoStatus(Todo todo) {
    setState(() {
      todo.isFinished = !todo.isFinished;
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
            builder: (BuildContext context) =>
            new TodoItemDetail(todo: this._todos[int.parse(path[2])])
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var _routes = <String, WidgetBuilder>{
      '/todo/new': (BuildContext context) =>
      new TodoCreatePage(this._handleAddTodoItem),
    };

    return new MaterialApp(
      title: 'My App',
      theme: _themeData,
      home: new TodoList(this._todos, this._handleAddTodoItem, this._handleChangeTodoStatus),
      routes: _routes,
      onGenerateRoute: _getRoute,
    );
  }
}

class TodoList extends StatelessWidget {

  List<Todo> todos = new List<Todo>();
  OnAddTodoItem onAddTodoItem;
  OnChangeTodoStatus onChangeTodoStatus;

  TodoList(this.todos, this.onAddTodoItem, this.onChangeTodoStatus);

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
                id: this.todos.length - 1,
                onChangeTodoStatus: onChangeTodoStatus,
            );
          }).toList()
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add',
        child: new Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/todo/new'),
      ),
    );
  }
}


class TodoListItem extends StatelessWidget {

  TodoListItem({Key key, Todo todo, int id, OnChangeTodoStatus onChangeTodoStatus})
      : todo = todo,
        id = id,
        onChangeTodoStatus = onChangeTodoStatus,
        super(key: new ObjectKey(todo));

  final int id;
  final Todo todo;
  OnChangeTodoStatus onChangeTodoStatus;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(this.todo.title),
      subtitle: new Text(this.todo.body),
      trailing: new Checkbox(
        value: this.todo.isFinished,
        onChanged: (bool value) {
          this.onChangeTodoStatus(this.todo);
        },
      ),
      enabled: true,
      dense: true,
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

class TodoCreatePage extends StatefulWidget {

  OnAddTodoItem onAddTodoItem;

  TodoCreatePage(this.onAddTodoItem);

  @override
  _TodoCreatePageState createState() =>
      new _TodoCreatePageState(this.onAddTodoItem);
}

class _TodoCreatePageState extends State<TodoCreatePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  OnAddTodoItem onAddTodoItem;

  Todo todo = new Todo('', '', false);

  _TodoCreatePageState(this.onAddTodoItem);

  void createTodo(BuildContext context) {
    final FormState form = _formKey.currentState;
    form.save();
    this.onAddTodoItem(todo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('New Todo'),
      ),
      body: new Form(
        key: _formKey,
        autovalidate: false,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new TextFormField(
              decoration: new InputDecoration(
                labelText: 'Title',
                hintText: 'Give a meaningful title for your todo',
              ),
              onSaved: (String value) {
                todo.title = value;
              },
            ),
            new TextFormField(
              decoration: new InputDecoration(
                labelText: 'Todo body',
                hintText: 'Describe your todo',
              ),
              onSaved: (String value) {
                todo.body = value;
              },
            ),
            new RaisedButton(
              onPressed: () =>
                  this.createTodo(context),
              child: new Text('Save todo'),
            ),
          ],
        ),
      ),
    );
  }
}
