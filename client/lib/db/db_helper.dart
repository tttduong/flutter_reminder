import 'package:mongo_dart/mongo_dart.dart';
import '../model/task.dart';

class DBHelper {
  static Db? _db;
  static late DbCollection _taskCollection;
  static final String _dbName = "taskdb"; // Tên database
  static final String _collectionName = "tasks"; // Tên collection
  static final String _mongoUrl =
      "mongodb+srv://tttduong:Shinichi0@cluster0.wbsq0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"; // URL kết nối MongoDB

  // Khởi tạo kết nối MongoDB
  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }

    try {
      _db = await Db.create(_mongoUrl);
      await _db!.open();
      _taskCollection = _db!.collection(_collectionName);
      print("MongoDB Connected!");
    } catch (e) {
      print("Error connecting to MongoDB: $e");
    }
  }

  // Thêm Task vào MongoDB
  static Future<void> insert(Task task) async {
    print("Insert function called");
    await _taskCollection.insert(task.toJson());
    print("Task inserted successfully");
  }

  // Lấy danh sách Task từ MongoDB
  static Future<List<Map<String, dynamic>>> query() async {
    print("Query function called");
    return await _taskCollection.find().toList();
  }
}
