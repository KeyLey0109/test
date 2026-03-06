import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<void> cachePosts(List<PostModel> postsToCache);
  Future<List<PostModel>> getLastPosts();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Sử dụng key V2 để tách biệt hoàn toàn với dữ liệu cũ chưa có bình luận
  static const cachedPostsKey = 'CACHED_POSTS_STUDYHUB_V2';

  PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cachePosts(List<PostModel> postsToCache) async {
    // Chuyển đổi sang JSON String List
    final List<String> jsonPostList =
        postsToCache.map((post) => json.encode(post.toJson())).toList();

    await sharedPreferences.setStringList(cachedPostsKey, jsonPostList);
  }

  @override
  Future<List<PostModel>> getLastPosts() async {
    final jsonList = sharedPreferences.getStringList(cachedPostsKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      final List<PostModel> posts = [];
      for (final jsonString in jsonList) {
        try {
          posts.add(PostModel.fromJson(
              json.decode(jsonString) as Map<String, dynamic>));
        } catch (e) {
          debugPrint("Lỗi parse bài viết: $e");
          // Bỏ qua bài viết lỗi thay vì xóa hết
        }
      }
      return posts;
    } catch (e) {
      debugPrint("Lỗi nghiêm trọng khi tải bài viết: $e");
      return [];
    }
  }
}
