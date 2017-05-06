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

typedef void OnChangeBottomNavigationItem(int index);

typedef void OnToggleDeleteView();

class MyApp extends StatefulWidget {

  MyApp({Key key, this.todos}) : super(key: key);

  final List<Todo> todos;

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Todo> _todos = new List<Todo>();

  int currentIndex;

  bool isDeleteView;

  @override
  void initState() {
    super.initState();

    this._todos.add(new Todo('test', 'test', false));
    currentIndex = 0;
    isDeleteView = false;
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

  void _handleChangeButtomNavigationItem(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _handleToggleDeleteView() {
    print('Test');
    setState(() {
      print('Altering delete view state');
      isDeleteView = !isDeleteView;
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
      home: new TodoList(
          this._todos,
          this._handleAddTodoItem,
          this._handleChangeTodoStatus,
          this.currentIndex,
          this._handleChangeButtomNavigationItem,
          this.isDeleteView,
          this._handleToggleDeleteView),
      routes: _routes,
      onGenerateRoute: _getRoute,
    );
  }
}

class TodoList extends StatelessWidget {

  List<Todo> todos = new List<Todo>();
  OnAddTodoItem onAddTodoItem;
  OnChangeTodoStatus onChangeTodoStatus;
  OnChangeBottomNavigationItem onChangeBottomNavigationItem;
  OnToggleDeleteView onToggleDeleteView;
  bool isDeleteView;
  int currentIndex;

  TodoList(this.todos, this.onAddTodoItem, this.onChangeTodoStatus,
      this.currentIndex, this.onChangeBottomNavigationItem, this.isDeleteView,
      this.onToggleDeleteView);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('My Organizer'),
      ),
      body: new TodoListBody(
          this.todos, this.currentIndex, this.onChangeTodoStatus,
          this.isDeleteView,
          this.onToggleDeleteView),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          this.onChangeBottomNavigationItem(index);
        },
        items: [
          new BottomNavigationBarItem(
            title: new Text('All'),
            icon: new Icon(Icons.list),
          ),
          new BottomNavigationBarItem(
            title: new Text('Active'),
            icon: new Icon(Icons.alarm_on),
          ),
          new BottomNavigationBarItem(
            title: new Text('Completed'),
            icon: new Icon(Icons.archive),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add',
        child: new Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/todo/new'),
      ),
    );
  }
}

class TodoListBody extends StatelessWidget {

  List<Todo> todos;
  int currentIndex;
  OnChangeTodoStatus onChangeTodoStatus;
  OnToggleDeleteView onToggleDeleteView;
  bool isDeleteView;

  TodoListBody(this.todos, this.currentIndex, this.onChangeTodoStatus,
      this.isDeleteView,
      this.onToggleDeleteView);

  @override
  Widget build(BuildContext context) {
    if (this.currentIndex == 1) {
      todos = todos.where((todo) => todo.isFinished == false).toList();
    } else if (this.currentIndex == 2) {
      todos = todos.where((todo) => todo.isFinished).toList();
    }

    return new ListView(
        children: this.todos.map((Todo todo) {
          return new TodoListItem(
            todo: todo,
            id: this.todos.length - 1,
            isDeleteView: isDeleteView,
            onChangeTodoStatus: onChangeTodoStatus,
            onToggleDeleteView: onToggleDeleteView,
          );
        }).toList()
    );
  }
}


class TodoListItem extends StatelessWidget {

  TodoListItem(
      {Key key, Todo todo, int id, OnChangeTodoStatus onChangeTodoStatus, bool isDeleteView, OnToggleDeleteView onToggleDeleteView})
      : todo = todo,
        id = id,
        onChangeTodoStatus = onChangeTodoStatus,
        isDeleteView = isDeleteView,
        onToggleDeleteView = onToggleDeleteView,
        super(key: new ObjectKey(todo));

  final int id;
  final Todo todo;
  OnChangeTodoStatus onChangeTodoStatus;
  OnToggleDeleteView onToggleDeleteView;
  bool isDeleteView;

  @override
  Widget build(BuildContext context) {
    Widget view;

    if(isDeleteView == false) {
      view = new ListTile(
          title: new Text(this.todo.title),
          subtitle: new Text(this.todo.body),
          trailing: new Checkbox(
              value: this.todo.isFinished,
              onChanged: (bool value) {
                this.onChangeTodoStatus(this.todo);
              },
          ),
          onLongPress: this.onToggleDeleteView,
          enabled: true,
          dense: true,
          onTap: () => Navigator.pushNamed(context, '/todo/${id}'),
      );
    } else {
      view = new ListTile(
          title: new Text(this.todo.title),
          subtitle: new Text(this.todo.body),
          leading: new Checkbox(onChanged: null, value: false),
          onLongPress: this.onToggleDeleteView,
          enabled: true,
          dense: true,
          //onTap: () => Navigator.pushNamed(context, '/todo/${id}'),
      );
    }

    return view;
  }
}

class TodoItemDetail extends StatelessWidget {

  TodoItemDetail({Key key, Todo todo})
      : todo = todo,
        super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Detailpage'),
      ),
      body:
      new Container(
        padding: const EdgeInsets.all(32.0),
        child: new Row(
          children: [
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: new Text(todo.title, style: new TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  new Container(
                    child: new Text(
                      todo.body,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
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
                hintText: 'Enter a meaningful title for your todo',
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
