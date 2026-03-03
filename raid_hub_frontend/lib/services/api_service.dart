import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import '../models/raid_video.dart';
import '../models/playlist_item.dart';
import 'package:raid_hub_frontend/services/auth_service.dart'; // Import AuthService

class ApiService {
  final String baseUrl = "http://localhost:8080/api/videos";
  final String _apiBaseUrl = "http://localhost:8080/api"; // Added base API URL
  final AuthService _authService = AuthService(); // Get the AuthService instance
  final http.Client _client = BrowserClient()..withCredentials = true;

  Future<List<RaidVideo>> getVideos() async {
    try {
      final response = await _client.get(
        Uri.parse(baseUrl),
        headers: _authService.getAuthHeaders(), // Include auth headers
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 처리 (한글 깨짐 방지)
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => RaidVideo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  Future<RaidVideo> createVideo(RaidVideo video) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: _authService.getAuthHeaders(), // Include auth headers
        body: jsonEncode(video.toJson()),
      );

      if (response.statusCode == 200) {
         // UTF-8 디코딩 처리
        return RaidVideo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        print('Video creation failed. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating video: $e');
      throw e;
    }
  }

  Future<void> deleteVideo(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _authService.getAuthHeaders(), // Include auth headers
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting video: $e');
      throw e;
    }
  }

  Future<void> blockVideo(String videoId, String reason) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiBaseUrl/blocked-videos'),
        headers: _authService.getAuthHeaders(),
        body: jsonEncode({'videoId': videoId, 'reason': reason}),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to block video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error blocking video: $e');
      throw e;
    }
  }

  Future<void> unblockVideo(String videoId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_apiBaseUrl/blocked-videos/$videoId'),
        headers: _authService.getAuthHeaders(), // Include auth headers
      );

      if (response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to unblock video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error unblocking video: $e');
      throw e;
    }
  }

  Future<List<String>> getBlockedVideoIds() async {
    try {
      final response = await _client.get(
        Uri.parse('$_apiBaseUrl/blocked-videos'),
        headers: _authService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.cast<String>();
      } else {
        throw Exception('Failed to load blocked video IDs');
      }
    } catch (e) {
      print('Error fetching blocked video IDs: $e');
      return [];
    }
  }

  Future<List<PlaylistItem>> getPlaylistItems(String playlistId) async {
    try {
      final response = await _client.get(
        Uri.parse('http://localhost:8080/api/youtube/playlist-items?playlistId=$playlistId&fetchAll=true'),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 처리 (한글 깨짐 방지)
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> items = jsonData['items'] ?? [];
        return items.map((dynamic item) => PlaylistItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load playlist items');
      }
    } catch (e) {
      throw Exception('Error fetching playlist items: $e');
    }
  }
}
