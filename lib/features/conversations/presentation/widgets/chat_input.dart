import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatAttachment {
  final String? imageBase64;
  final String? imagePath;
  final String? imageUrl;
  final String? extractedUrl;

  const ChatAttachment({
    this.imageBase64,
    this.imagePath,
    this.imageUrl,
    this.extractedUrl,
  });

  bool get hasImage =>
      imageBase64 != null || imagePath != null || imageUrl != null;
  bool get hasUrl => extractedUrl != null;
}

class ChatInput extends StatefulWidget {
  final Function(String, {ChatAttachment? attachment}) onSend;
  final bool isLoading;
  final bool isSocratic;
  final VoidCallback? onToggleSocratic;
  final String? hintText;
  final bool enableImageAttachment;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.isSocratic = true,
    this.onToggleSocratic,
    this.hintText,
    this.enableImageAttachment = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();
  bool _hasText = false;
  bool _isFocused = false;
  File? _attachedImage;
  String? _attachedImageBase64;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  bool get _canSend =>
      (_hasText || _attachedImage != null) && !widget.isLoading;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (!_canSend) return;

    HapticFeedback.lightImpact();
    ChatAttachment? attachment;
    if (_attachedImageBase64 != null) {
      attachment = ChatAttachment(imageBase64: _attachedImageBase64);
    }

    widget.onSend(text.isEmpty ? 'Analyze this image' : text,
        attachment: attachment);
    _controller.clear();
    _clearAttachment();
    _focusNode.requestFocus();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _attachedImage = File(pickedFile.path);
          _attachedImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachedImage = null;
      _attachedImageBase64 = null;
    });
  }

  void _showAttachmentOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.camera, color: colorScheme.primary),
              title: const Text('Take a photo', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  Icon(LucideIcons.image, color: colorScheme.secondary),
              title: const Text('Choose from gallery',
                  style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withAlpha(isDark ? 220 : 240),
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withAlpha(isDark ? 30 : 50),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image preview
                  if (_attachedImage != null)
                    _AttachmentPreview(
                      image: _attachedImage!,
                      onRemove: _clearAttachment,
                    ),

                  // Input row
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest.withAlpha(180)
                          : colorScheme.surfaceContainerHighest.withAlpha(200),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isFocused
                            ? colorScheme.primary.withAlpha(100)
                            : colorScheme.outlineVariant
                                .withAlpha(isDark ? 35 : 60),
                        width: _isFocused ? 1.5 : 1,
                      ),
                      boxShadow: _isFocused
                          ? [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withAlpha(isDark ? 18 : 10),
                                blurRadius: 16,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left actions
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.enableImageAttachment)
                                _CircleAction(
                                  icon: _attachedImage != null
                                      ? LucideIcons.paperclip
                                      : LucideIcons.plus,
                                  isActive: _attachedImage != null,
                                  onTap: _showAttachmentOptions,
                                ),
                              if (widget.onToggleSocratic != null)
                                _CircleAction(
                                  icon: LucideIcons.graduationCap,
                                  isActive: widget.isSocratic,
                                  activeColor: colorScheme.tertiary,
                                  onTap: widget.onToggleSocratic!,
                                ),
                            ],
                          ),
                        ),

                        // TextField
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !widget.isLoading,
                            maxLines: 5,
                            minLines: 1,
                            textCapitalization:
                                TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: _attachedImage != null
                                  ? 'Add a message...'
                                  : (widget.hintText ??
                                      'Ask anything...'),
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: colorScheme.onSurfaceVariant
                                    .withAlpha(110),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: (widget.onToggleSocratic !=
                                            null ||
                                        widget
                                            .enableImageAttachment)
                                    ? 6
                                    : 16,
                                right: 6,
                                top: 13,
                                bottom: 13,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),

                        // Send button
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 4, bottom: 4),
                          child: _SendButton(
                            isEnabled: _canSend,
                            isLoading: widget.isLoading,
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mode label
                  if (widget.onToggleSocratic != null) ...[
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        key: ValueKey(widget.isSocratic),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isSocratic
                                ? LucideIcons.graduationCap
                                : LucideIcons.messageSquare,
                            size: 10,
                            color: widget.isSocratic
                                ? colorScheme.tertiary.withAlpha(150)
                                : colorScheme.onSurfaceVariant
                                    .withAlpha(100),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.isSocratic
                                ? 'Socratic mode · Guides with questions'
                                : 'Direct mode · Straight answers',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.onSurfaceVariant
                                  .withAlpha(110),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Circle Action Button ──────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = activeColor ?? colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isActive ? color.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isActive
                ? color
                : colorScheme.onSurfaceVariant.withAlpha(140),
          ),
        ),
      ),
    );
  }
}

// ─── Send Button ───────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : colorScheme.surfaceContainerHigh.withAlpha(120),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(isDark ? 50 : 35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: isEnabled
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    LucideIcons.arrowUp,
                    size: 17,
                    color: isEnabled
                        ? Colors.white
                        : colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
          ),
        ),
      ),
    ).animate(target: isEnabled ? 1 : 0).scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 180.ms,
          curve: Curves.easeOut,
        );
  }
}

// ─── Attachment Preview ────────────────────────────────────────

class _AttachmentPreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(image,
                    width: 52, height: 52, fit: BoxFit.cover),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: colorScheme.surface, width: 1.5),
                    ),
                    child: const Icon(LucideIcons.x,
                        size: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            'Image attached',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.15);
  }
}

// ─── Simple Chat Input ─────────────────────────────────────────

class SimpleChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final String? hintText;

  const SimpleChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<SimpleChatInput> createState() => _SimpleChatInputState();
}

class _SimpleChatInputState extends State<SimpleChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withAlpha(180)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 35 : 60),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isLoading,
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: 13.5, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Message...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: colorScheme.onSurfaceVariant.withAlpha(110),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _SendButton(
                isEnabled: _hasText && !widget.isLoading,
                isLoading: widget.isLoading,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
