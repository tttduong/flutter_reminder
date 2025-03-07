// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:postgres/postgres.dart';
// import '../model/task.dart';

// class DBHelper {
//   // PostgreSQL
//   static PostgreSQLConnection? _pgConnection;
//   static Db? _db;
//   static late DbCollection _taskCollection;
//   static final String _pgHost = "localhost"; // Thay thế bằng host của bạn
//   static final int _pgPort = 5432; // Cổng mặc định của PostgreSQL
//   static final String _pgDatabase = "flutter_todo"; // Tên database PostgreSQL
//   static final String _pgUser = "postgres"; // Tài khoản PostgreSQL
//   static final String _pgPassword = "Shinichi0"; // Mật khẩu PostgreSQL

//   static Future<void> initDb() async {
//     // await _initMongoDb();
//     await _initPostgres();
//   }

//   /// **Khởi tạo kết nối PostgreSQL**
//   static Future<void> _initPostgres() async {
//     if (_pgConnection != null) return;
//     try {
//       _pgConnection = PostgreSQLConnection(
//         _pgHost,
//         _pgPort,
//         _pgDatabase,
//         username: _pgUser,
//         password: _pgPassword,
//       );
//       await _pgConnection!.open();
//       print("✅ PostgreSQL Connected!");
//     } catch (e) {
//       print("❌ Error connecting to PostgreSQL: $e");
//     }
//   }

//   /// **Thêm Task vào PostgreSQL**
//   static Future<void> insertToPostgres(Task task) async {
//     if (_pgConnection == null) {
//       print("⚠️ PostgreSQL connection is not initialized.");
//       return;
//     }

//     await _pgConnection!.query(
//       '''
//       INSERT INTO tasks (id, user_id, category_id, title, description, status, created_at, updated_at, is_deleted)
//       VALUES (@id, @user_id, @category_id, @title, @description, @status, @created_at, @updated_at, @is_deleted)
//       ''',
//       substitutionValues: {
//         'id': task.id,
//         'user_id': task.userId,
//         'category_id': task.categoryId,
//         'title': task.title,
//         'description': task.description,
//         'status': task.status,
//         'created_at': task.createdAt?.toIso8601String(),
//         'updated_at': task.updatedAt?.toIso8601String(),
//         'is_deleted': task.isDeleted,
//       },
//     );
//     print("✅ Task inserted into PostgreSQL");
//   }

//   /// **Lấy danh sách Task từ PostgreSQL**
//   static Future<List<Task>> queryFromPostgres() async {
//     if (_pgConnection == null) {
//       print("⚠️ PostgreSQL connection is not initialized.");
//       return [];
//     }

//     final results = await _pgConnection!.query('SELECT * FROM tasks');
//     return results.map((row) {
//       return Task(
//         id: row[0] as String?,
//         userId: row[1] as String?,
//         categoryId: row[2] as String?,
//         title: row[3] as String,
//         description: row[4] as String?,
//         status: row[5] as int,
//         createdAt: row[6] != null ? DateTime.parse(row[6] as String) : null,
//         updatedAt: row[7] != null ? DateTime.parse(row[7] as String) : null,
//         isDeleted: row[8] as bool,
//       );
//     }).toList();
//   }

  // static Db? _db;
  // static late DbCollection _taskCollection;
  // static final String _dbName = "taskdb"; // Tên database
  // static final String _collectionName = "tasks"; // Tên collection
  // static final String _mongoUrl =
  //     "mongodb+srv://tttduong:Shinichi0@cluster0.wbsq0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"; // URL kết nối MongoDB

  // // Khởi tạo kết nối MongoDB
  // static Future<void> initDb() async {
  //   if (_db != null) {
  //     return;
  //   }

  //   try {
  //     _db = await Db.create(_mongoUrl);
  //     await _db!.open();
  //     _taskCollection = _db!.collection(_collectionName);
  //     print("MongoDB Connected!");
  //   } catch (e) {
  //     print("Error connecting to MongoDB: $e");
  //   }
  // }

  // // Thêm Task vào MongoDB
  // static Future<void> insert(Task task) async {
  //   print("Insert function called");
  //   await _taskCollection.insert(task.toJson());
  //   print("Task inserted successfully");
  // }

  // // Lấy danh sách Task từ MongoDB
  // static Future<List<Map<String, dynamic>>> query() async {
  //   print("Query function called");
  //   return await _taskCollection.find().toList();
  // }
// }
