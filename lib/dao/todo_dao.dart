import 'dart:async';
import 'package:todolist/database/database.dart';
import 'package:todolist/model/todo.dart';

/// Contains the set of methods that interact with the database
class TodoDao {
  final dbProvider = DatabaseProvider.dbProvider;

  /// Adds new T0do records
  Future<int> createTodo(Todo todo) async {
    final db = await dbProvider.database;
    return db!.insert(
      todoTABLE,
      todo.toDatabaseJson(),
    );
  }

  /// Get the next row on the database
  Future<int> getNext() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>>? result =
        await db?.rawQuery('SELECT last_insert_rowid() from $todoTABLE');
    dynamic returnValue;
    // If the app was just installed, [result?.first] will throw an exception
    try {
      returnValue = result?.first['last_insert_rowid()'];
    } catch (e) {
      returnValue = 0;
    }
    return returnValue;
  }

  /// Get All T0do items and search if query string was passed
  Future<List<Todo>?> getTodos({
    required List<String> columns,
    String? query,
  }) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>>? result;
    if (query != null && query.isNotEmpty) {
      result = await db?.query(
        todoTABLE,
        columns: columns,
        where: '$columnTask LIKE ?',
        whereArgs: ["%$query%"],
        orderBy: '$columnId desc',
      );
    } else {
      result = await db?.query(
        todoTABLE,
        columns: columns,
        orderBy: '$columnId desc',
      );
    }

    List<Todo>? todos = result?.isNotEmpty == true
        ? result?.map((item) => Todo.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  // Get the search suggestions
  // .
  // .
  // Depending on the state of showAllTasks, it can be used to get suggestions
  // for all tasks or for just tasks within a group
  Future<List<Todo>?> getSuggestions({
    required List<String> columns,
    String? query,
    required bool showAllTasks,
    String category = '',
  }) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>>? result;

    if (query != null && query.isNotEmpty) {
      if (showAllTasks) {
        result = await db?.query(
          todoTABLE,
          columns: columns,
          where: '$columnTask LIKE ?',
          whereArgs: ["%$query%"],
          orderBy: '$columnId desc',
        );
      } else {
        result = await db?.rawQuery(
          'select * from $todoTABLE where $columnCategory is \'$category\' AND $columnTask like \'%$query%\'',
        );
      }
    }

    List<Todo>? todos = result?.isNotEmpty == true
        ? result?.map((item) => Todo.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  /// Get the recent searches
  Future<List<Todo>?> getRecent() async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>>? result;
    result = await db?.query(
      todoTABLE,
      where: '$columnRecent = ?',
      whereArgs: [1],
      orderBy: '$columnLastSearched desc',
    );

    List<Todo>? todos = result?.isNotEmpty == true
        ? result?.map((item) => Todo.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  /// Clears search history
  Future<int?> clearHistory() async {
    final db = await dbProvider.database;

    return await db?.rawUpdate(
      'update $todoTABLE set $columnRecent = 0 where $columnRecent = 1',
    );
  }

  /// The function that provides data that will be displayed on the category screen
  Future<List<Todo>?> fetchGroup({
    required String category,
    String? query,
    int selected = 2,
  }) async {
    final db = await dbProvider.database;

    final search = query != null && query.isNotEmpty
        ? 'AND $columnTask like \'%$query%\''
        : '';

    String demand = '';
    if (selected == 1) {
      demand = 'and is_done = 1';
    } else if (selected == 0) {
      demand = 'and is_done = 0';
    }

    List<Map<String, dynamic>>? result;
    result = await db?.rawQuery(
      'select * from $todoTABLE where $columnCategory is \'$category\' $demand $search',
    );
    List<Todo>? group =
        result?.map((item) => Todo.fromDatabaseJson(item)).toList();
    return group;
  }

  /// The function that provides the categoryList data to display
  Future<List<Map<String, dynamic>>> getCategories({String? query}) async {
    final db = await dbProvider.database;

    final text = query != null && query.isNotEmpty
        ? 'AND $columnCategory like \'%$query%\''
        : '';
    Future<List<Map<String, dynamic>>> result;

    result = db!.rawQuery(
      'select $columnCategory, COUNT(*) FROM $todoTABLE WHERE $columnCategory is not null $text GROUP BY $columnCategory ORDER BY COUNT(*) DESC',
    );

    return result;
  }

  /// Update T0do record
  Future<int?> updateTodo(Todo todo) async {
    final db = await dbProvider.database;

    return await db?.update(
      todoTABLE,
      todo.toDatabaseJson(),
      where: "id = ?",
      whereArgs: [todo.id],
    );
  }

  /// Change the name of the category
  renameCategory({required String from, required String to}) async {
    final db = await dbProvider.database;

    return db!.rawQuery(
      'Update $todoTABLE set $columnCategory = \'$to\' where $columnCategory = \'$from\'',
    );
  }

  /// Delete T0do records
  Future<int?> deleteTodo(int id) async {
    final db = await dbProvider.database;
    return await db?.delete(
      todoTABLE,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ///  Delete a category
  Future<int?> deleteCategory(String category) async {
    final db = await dbProvider.database;
    return await db?.delete(
      todoTABLE,
      where: '$columnCategory = ?',
      whereArgs: [category],
    );
  }

  //This will be useful when I want to delete all the rows in the database
  Future deleteAllTodos() async {
    final db = await dbProvider.database;
    return await db?.delete(
      todoTABLE,
    );
  }
}
