
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffychat/data/model/upload_file_json.dart';
import 'package:fluffychat/data/network/dio_client.dart';
import 'package:fluffychat/data/network/homeserver_endpoint.dart';
import 'package:fluffychat/data/network/upload_file/file_info.dart';
import 'package:fluffychat/di/global/get_it_initializer.dart';
import 'package:fluffychat/di/global/network_di.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:matrix/matrix.dart';

class UploadFileAPI {
  final DioClient _client = getIt.get<DioClient>(instanceName: NetworkDI.homeDioClientName);

  UploadFileAPI();

  Future<UploadFileResponse> uploadFile({required FileInfo fileInfo}) async {
    final dioHeaders = _client.getHeaders();
    dioHeaders[HttpHeaders.contentLengthHeader] = await File(fileInfo.filePath).length();
    dioHeaders[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
    final response = await _client.post(
      HomeserverEndpoint.uploadMediaServicePath.generateTwakeIdentityEndpoint(),
      data: fileInfo.readStream ?? File(fileInfo.filePath).openRead(),
      queryParameters: {
        fileName: fileInfo.fileName,
      },
      options: Options(headers: dioHeaders)
    ).onError((error, stackTrace) => throw Exception(error));

    return UploadFileResponse.fromJson(response);
  }
}