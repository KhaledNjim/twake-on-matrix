import 'package:fluffychat/utils/task_queue/worker_queue.dart';

class DownloadWorkerQueue extends WorkerQueue {
  @override
  String get workerName => 'downloading_queue';
}
