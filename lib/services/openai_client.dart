import 'package:dio/dio.dart';
import 'dart:convert';

class OpenAIClient {
  final Dio dio;

  OpenAIClient(this.dio);

  /// Standard chat completion with GPT-5 support
  Future<Completion> createChatCompletion({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
      };

      // Handle options based on model type
      if (options != null) {
        final filteredOptions = Map<String, dynamic>.from(options);

        // For GPT-5 models, remove unsupported parameters
        if (model.startsWith('gpt-5') ||
            model.startsWith('o3') ||
            model.startsWith('o4')) {
          filteredOptions.removeWhere((key, value) => [
                'temperature',
                'top_p',
                'presence_penalty',
                'frequency_penalty',
                'logit_bias'
              ].contains(key));

          // Convert max_tokens to max_completion_tokens for GPT-5
          if (filteredOptions.containsKey('max_tokens')) {
            filteredOptions['max_completion_tokens'] =
                filteredOptions.remove('max_tokens');
          }
        }

        requestData.addAll(filteredOptions);
      }

      // Add GPT-5 specific parameters
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// Streams a text response with support for new model parameters
  Stream<StreamCompletion> streamChatCompletion({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async* {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
        'stream': true,
        if (options != null) ...options,
      };

      // Add GPT-5 specific parameters
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var line
          in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;

          final json = jsonDecode(data) as Map<String, dynamic>;
          final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
          final content = delta['content'] ?? '';
          final finishReason = json['choices'][0]['finish_reason'];
          final systemFingerprint = json['system_fingerprint'];

          yield StreamCompletion(
            content: content,
            finishReason: finishReason,
            systemFingerprint: systemFingerprint,
          );

          if (finishReason != null) break;
        }
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// A more user-friendly wrapper for streaming that just yields content strings
  Stream<String> streamContentOnly({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async* {
    await for (final chunk in streamChatCompletion(
      messages: messages,
      model: model,
      options: options,
      reasoningEffort: reasoningEffort,
      verbosity: verbosity,
    )) {
      if (chunk.content.isNotEmpty) {
        yield chunk.content;
      }
    }
  }

  /// List of available OpenAI models
  Future<List<String>> listModels() async {
    try {
      final response = await dio.get('/models');
      final models = response.data['data'] as List;
      return models.map((m) => m['id'] as String).toList();
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }
}

/// Message class for OpenAI API
class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

/// Completion response class
class Completion {
  final String text;

  Completion({required this.text});
}

/// Stream completion response class
class StreamCompletion {
  final String content;
  final String? finishReason;
  final String? systemFingerprint;

  StreamCompletion({
    required this.content,
    this.finishReason,
    this.systemFingerprint,
  });
}

/// OpenAI Exception class
class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}
