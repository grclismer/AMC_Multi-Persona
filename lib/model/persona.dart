import 'package:flutter/material.dart';

class Persona {
  final String id;
  final String name;
  final String role; // e.g., "Habit Builder Expert"
  final String description; // "Personality: Encouraging..."
  final String coreInfo; // "Core Info: This bot acts as..."
  final IconData icon; // Start with IconData, later can be ImageAsset
  final Color color;
  final String systemInstruction;
  final String? assetImage;

  const Persona({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.coreInfo,
    required this.icon,
    required this.color,
    required this.systemInstruction,
    this.assetImage,
  });
}
