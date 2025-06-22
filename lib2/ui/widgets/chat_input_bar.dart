import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onSend;
  final String hintText;
  final bool enabled;

  const ChatInputBar({
    super.key,
    this.controller,
    this.onSend,
    this.hintText = "Habla con FITS...",
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final _controller = controller ?? TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: enabled,
                  controller: _controller,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 7),
                  ),
                  onSubmitted: (text) {
                    if (onSend != null && text.trim().isNotEmpty) {
                      onSend!(text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 21, color: Colors.black),
                splashRadius: 21,
                onPressed: enabled
                    ? () {
                        if (onSend != null && _controller.text.trim().isNotEmpty) {
                          onSend!(_controller.text.trim());
                          _controller.clear();
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}