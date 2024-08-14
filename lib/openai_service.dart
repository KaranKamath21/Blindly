import 'dart:convert';
import 'package:blindly/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
              'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );
      if (res.statusCode == 200) {
        final responseJson = jsonDecode(res.body);
        String content = responseJson['choices'][0]['message']['content'].trim();

        switch (content.toLowerCase()) {
          case 'yes':
            return await dallEAPI(prompt);
          default:
            return await chatGPTAPI(prompt);
        }
      } else {
        print('Error response: ${res.body}');
        return 'An internal error occurred';
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        final responseJson = jsonDecode(res.body);
        String content = responseJson['choices'][0]['message']['content'].trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      } else {
        print('Error response: ${res.body}');
        return 'An internal error occurred';
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        final responseJson = jsonDecode(res.body);
        String imageUrl = responseJson['data'][0]['url'].trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      } else {
        print('Error response: ${res.body}');
        return 'An internal error occurred';
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
