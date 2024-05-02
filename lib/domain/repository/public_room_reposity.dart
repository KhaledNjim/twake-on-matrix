import 'package:fluffychat/data/model/search/public_room_response.dart';
import 'package:matrix/matrix.dart';

abstract class PublicRoomRepository {
  Future<PublicRoomResponse> search({
    PublicRoomQueryFilter? filter,
    String? server,
    int? limit,
  });
}
