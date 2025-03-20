import 'package:mysql1/mysql1.dart';

class DatabaseService {
  late MySqlConnection _connection;

  Future<void> connect() async {
    _connection = await MySqlConnection.connect(ConnectionSettings(
      host: 'your-database-host',
      port: 3306, // Default MySQL port
      user: 'your-database-user',
      password: 'your-database-password',
      db: 'your-database-name',
    ));
  }

  Future<void> addDriver(
      String driverId, Map<String, dynamic> driverData) async {
    const query =
        'INSERT INTO drivers (id, name, phone, email) VALUES (?, ?, ?, ?)';
    await _connection.query(query, [
      driverId,
      driverData['name'],
      driverData['phone'],
      driverData['email'],
    ]);
  }

  Future<Map<String, dynamic>?> getDriver(String driverId) async {
    const query = 'SELECT * FROM drivers WHERE id = ?';
    final results = await _connection.query(query, [driverId]);

    if (results.isNotEmpty) {
      var row = results.first;
      return {
        'id': row['id'],
        'name': row['name'],
        'phone': row['phone'],
        'email': row['email'],
      };
    }
    return null;
  }

  Future<void> updateDriver(
      String driverId, Map<String, dynamic> driverData) async {
    const query =
        'UPDATE drivers SET name = ?, phone = ?, email = ? WHERE id = ?';
    await _connection.query(query, [
      driverData['name'],
      driverData['phone'],
      driverData['email'],
      driverId,
    ]);
  }

  Future<void> deleteDriver(String driverId) async {
    const query = 'DELETE FROM drivers WHERE id = ?';
    await _connection.query(query, [driverId]);
  }

  Future<List<Map<String, dynamic>>> getTripsForDriver(String driverId) async {
    const query = 'SELECT * FROM trips WHERE driver_id = ?';
    final results = await _connection.query(query, [driverId]);

    return results
        .map((row) => {
              'id': row['id'],
              'driver_id': row['driver_id'],
              'pickup_location': row['pickup_location'],
              'destination': row['destination'],
              'status': row['status'],
            })
        .toList();
  }

  Future<void> closeConnection() async {
    await _connection.close();
  }
}
