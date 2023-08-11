import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String userId;
  final String feedbackText;
  final Timestamp timestamp;

  FeedbackModel({
    required this.userId,
    required this.feedbackText,
    required this.timestamp,
  });
}
