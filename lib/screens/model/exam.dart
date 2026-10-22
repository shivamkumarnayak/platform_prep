import 'package:flutter/material.dart';

class Exam {
  const Exam({
    required this.id,
    required this.key,
    required this.name,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.negative,
    required this.negativeLabel,
    required this.note,
  });

  final int id;
  final String key; // folder name inside assets/data/
  final String name;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double negative;
  final String negativeLabel;
  final String note;

  /// Test ids of this exam are base + localId. Quick practice uses base itself.
  int get base => id * 100;

  bool get hasNegative => negative > 0;

  static const _icons = <String, IconData>{
    'train': Icons.train,
    'engineering': Icons.engineering,
    'school': Icons.school,
    'quiz': Icons.quiz,
    'work': Icons.work,
  };

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] as int,
        key: j['key'] as String,
        name: j['name'] as String,
        title: j['title'] as String,
        subtitle: (j['subtitle'] ?? '') as String,
        icon: _icons[j['icon']] ?? Icons.school,
        color: Color(int.parse(j['color'] as String, radix: 16)),
        negative: ((j['negative'] ?? 0) as num).toDouble(),
        negativeLabel: (j['negativeLabel'] ?? '') as String,
        note: (j['note'] ?? '') as String,
      );
}

/// Which exam a test/attempt belongs to.
int examIdOfTest(int testId) => testId ~/ 100;