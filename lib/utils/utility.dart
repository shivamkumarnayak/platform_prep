import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:shimmer/shimmer.dart';

class Utility {
  //USed to show snackbar in case of errors
  static showErrorSnackBar(
    BuildContext context,
    String errorTitle,
    String error,
  ) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(0),
        backgroundColor: Colors.red,
        content: ListTile(
          leading: Container(
            margin: const EdgeInsets.only(left: 2),
            child: const Icon(Icons.error, color: Colors.white),
          ),
          title: Text(
            errorTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            error,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  //USed to show snackbar in case of success or any other specific events
  static showSnackBarMessage(
    BuildContext context,
    String messageTitle,
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(0),
        backgroundColor: color,
        content: ListTile(
          title: Text(
            messageTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  //Used to show exit popup to leave mobile app
  static exitPopup(
      BuildContext context, String? title, String? message, Function()? onTap) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Logo instead of icon
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset("assets/images/logo.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  message ?? "Are you sure you want to exit?",
                  style: GalleryThemeData.textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: GalleryThemeData.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GalleryThemeData.textTheme.bodyMedium,
                        ),
                        onPressed: onTap ?? () => exit(0),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GalleryThemeData.textTheme.bodyMedium,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "No",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget shimmerLoading({Widget? child, Color? highlightColor}) {
    return Shimmer.fromColors(
      baseColor: GalleryThemeData.lightGreyColor,
      highlightColor: highlightColor ?? Colors.white,
      period: const Duration(seconds: 2),
      child: child!,
    );
  }
}