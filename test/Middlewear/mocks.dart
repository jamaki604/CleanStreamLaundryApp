import 'package:clean_stream_laundry_app/Middleware/machine_communicator.dart';
import 'package:clean_stream_laundry_app/Middleware/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MachineCommunicatorMock extends Mock implements MachineCommunicator {}
class StorageServiceMock extends Mock implements StorageService{}