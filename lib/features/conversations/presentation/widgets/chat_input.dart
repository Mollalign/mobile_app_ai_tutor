import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Attachment data for images or URLs.
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

  bool get hasImage => imageBase64 != null || imagePath != null || imageUrl != null;
  bool get hasUrl => extractedUrl != null;
}

/// Modern chat input widget with beautiful glass-morphic design.
/// Premium feel with smooth animations and glowing accents.
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
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  bool get _canSend => (_hasText || _attachedImage != null) && !widget.isLoading;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (!_canSend) return;

    ChatAttachment? attachment;
    if (_attachedImageBase64 != null) {
      attachment = ChatAttachment(imageBase64: _attachedImageBase64);
    }

    widget.onSend(text.isEmpty ? 'Analyze this image' : text, attachment: attachment);
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
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: colorScheme.secondary),
              title: const Text('Choose from gallery'),
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
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Subtle gradient background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withAlpha(0),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image attachment preview
              if (_attachedImage != null)
                _AttachmentPreview(
                  image: _attachedImage!,
                  onRemove: _clearAttachment,
                ),

              // Main input container with glass effect
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _isFocused
                        ? colorScheme.primary.withAlpha(128)
                        : colorScheme.outlineVariant.withAlpha(isDark ? 51 : 77),
                    width: _isFocused ? 1.5 : 1,
                  ),
                  // Subtle glow when focused
                  boxShadow: _isFocused && isDark
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withAlpha(26),
                            blurRadius: 20,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Attachment button
                    if (widget.enableImageAttachment)
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 6),
                        child: _AttachmentButton(
                          onTap: _showAttachmentOptions,
                          hasAttachment: _attachedImage != null,
                        ),
                      ),

                    // Socratic mode toggle
                    if (widget.onToggleSocratic != null)
                      Padding(
                        padding: EdgeInsets.only(
                          left: widget.enableImageAttachment ? 0 : 6,
                          bottom: 6,
                        ),
                        child: _ModeToggleButton(
                          isSocratic: widget.isSocratic,
                          onToggle: widget.onToggleSocratic!,
                        ),
                      ),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isLoading,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: _attachedImage != null
                              ? 'Add a message (optional)...'
                              : (widget.hintText ?? 'Ask anything...'),
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withAlpha(128),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: (widget.onToggleSocratic != null || widget.enableImageAttachment) ? 8 : 20,
                            right: 8,
                            top: 16,
                            bottom: 16,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

                    // Send button
                    Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 6),
                      child: _SendButton(
                        isEnabled: _canSend,
                        isLoading: widget.isLoading,
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),

              // Mode indicator
              if (widget.onToggleSocratic != null) ...[
                const SizedBox(height: 8),
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
                        size: 12,
                        color: widget.isSocratic
                            ? colorScheme.tertiary.withAlpha(179)
                            : colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isSocratic
                            ? 'Socratic mode • Guides with questions'
                            : 'Direct mode • Straight answers',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                          letterSpacing: 0.2,
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
    );
  }
}

/// Attachment button with plus icon.
class _AttachmentButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasAttachment;

  const _AttachmentButton({
    required this.onTap,
    required this.hasAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasAttachment
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            hasAttachment ? LucideIcons.paperclip : LucideIcons.plus,
            size: 20,
            color: hasAttachment
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withAlpha(179),
          ),
        ),
      ),
    );
  }
}

/// Attachment preview with remove button.
class _AttachmentPreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _AttachmentPreview({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Material(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.x,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Image attached',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}

/// Mode toggle button with beautiful animation.
class _ModeToggleButton extends StatelessWidget {
  final bool isSocratic;
  final VoidCallback onToggle;

  const _ModeToggleButton({
    required this.isSocratic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSocratic
                ? colorScheme.tertiaryContainer.withAlpha(isDark ? 77 : 128)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            LucideIcons.graduationCap,
            size: 20,
            color: isSocratic
                ? colorScheme.tertiary
                : colorScheme.onSurfaceVariant.withAlpha(128),
          ),
        ),
      ),
    );
  }
}

/// Beautiful animated send button with glow effect.
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  Color.fromRGBO(
                    (colorScheme.primary.r * 255.0).round().clamp(0, 255),
                    (colorScheme.primary.g * 255.0).round().clamp(0, 255),
                    ((colorScheme.primary.b * 255) * 0.85).round().clamp(0, 255),
                    1,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isEnabled && isDark
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isEnabled
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    LucideIcons.arrowUp,
                    size: 20,
                    color: isEnabled
                        ? Colors.white
                        : colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
          ),
        ),
      ),
    ).animate(target: isEnabled ? 1 : 0).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

/// Simplified chat input for quick use.
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
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(77),
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
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Message...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
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
