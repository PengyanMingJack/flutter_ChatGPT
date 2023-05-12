import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_urls.dart';
import '../models/exports.dart';

class APIRepository {
  // fetch OpenAIModels
  Future<List<OpenAIModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse(APIUrls.modelUrl), headers: {
        'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
      });

      Map jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] != null) {
        throw http.ClientException(jsonResponse['error']['message']);
      }
      List models = [];
      for (var value in jsonResponse['data']) {
        models.add(value);
      }
      print(models);
      return OpenAIModel.toModelList(models);
    } on CustomError catch (e) {
      throw CustomError(errorMsg: e.errorMsg, code: e.code, plugin: e.plugin);
    }
  }

  // fetch OpenAICompletion
  static Future<List<OpenAICompletion>> getCompletion({
    required String text,
    required String model,
  }) async {
    print('text:$text, model: $model');
    try {
      var response = await http.post(
        Uri.parse(APIUrls.completionUrl),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": model,
          "prompt": text,
          "max_tokens": 1000,
        }),
      );
      Map jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] != null) {
        throw http.ClientException(jsonResponse['error']['message']);
      }
      List<OpenAICompletion> completions = [];

      if (jsonResponse['choices'].length > 0) {
        completions = List.generate(
          jsonResponse['choices'].length,
          (index) => OpenAICompletion(
            id: jsonResponse['id'],
            text: jsonResponse['choices'][index]['text'],
          ),
        ).toList();

        print('RESPONSE: ${jsonResponse['choices'][0]['text']}');
      }
      return completions;
    } on CustomError catch (e) {
      print(e.errorMsg);
      throw CustomError(errorMsg: e.errorMsg, code: e.code, plugin: e.plugin);
    }
  }

  // fetch OpenAIChat
  static Future<List<OpenAICompletion>> getChat({
    required String text,
    required String model,
  }) async {
    print('text:$text, model: $model');
    try {
      var response = await http.post(
        Uri.parse(APIUrls.chatUrl),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "user", "content": text}
          ],
          "max_tokens": 1000,
        }),
      );
      Map jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] != null) {
        throw http.ClientException(jsonResponse['error']['message']);
      }
      List<OpenAICompletion> completions = [];

      if (jsonResponse['choices'].length > 0) {
        completions = List.generate(
          jsonResponse['choices'].length,
          (index) => OpenAICompletion(
            id: jsonResponse['id'],
            text: jsonResponse['choices'][index]['message']['content'],
          ),
        ).toList();

        print('RESPONSE: ${jsonResponse['choices'][0]['message']['content']}');
      }
      return completions;
    } on CustomError catch (e) {
      print(e.errorMsg);
      throw CustomError(errorMsg: e.errorMsg, code: e.code, plugin: e.plugin);
    }
  }
}
