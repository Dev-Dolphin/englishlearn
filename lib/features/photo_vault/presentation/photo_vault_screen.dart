import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../vocabulary_srs/domain/flashcard_entity.dart';
import '../../vocabulary_srs/presentation/word_challenge_screen.dart';
import '../domain/photo_vocab_entry.dart';
import 'photo_vault_provider.dart';

class PhotoVaultScreen extends ConsumerStatefulWidget {
  const PhotoVaultScreen({super.key});

  @override
  ConsumerState<PhotoVaultScreen> createState() => _PhotoVaultScreenState();
}

class _PhotoVaultScreenState extends ConsumerState<PhotoVaultScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isFlipCardMode = false;
  int _flipIndex = 0;
  bool _flipRevealed = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      _showUploadDetailsSheet(picked);
    } catch (_) {
      // Simulator without camera falls back to manual/Live Text sheet
      if (!mounted) return;
      _showUploadDetailsSheet(null);
    }
  }

  void _showUploadDetailsSheet(XFile? pickedImage) {
    final titleCtrl = TextEditingController(
      text: pickedImage != null
          ? pickedImage.name.replaceAll(RegExp(r'\.[^.]+$'), '')
          : 'Ảnh chụp từ vựng mới',
    );
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📸 Lưu Ảnh & Bóc Tách Từ Vựng Vào Kho Riêng',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mẹo trên iPhone: Chạm vào ô văn bản bên dưới rồi chọn biểu tượng "Quét văn bản (Live Text)" trên bàn phím iOS để quét chữ trực tiếp từ sách!',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên bộ ảnh (VD: Sách Cam 18 Test 2)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText:
                        'Văn bản quét Live Text / Ghi chú (VD: ubiquitous: phổ biến)',
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Lưu vào Kho Từ Ảnh & Cập nhật ngay',
                  icon: Icons.cloud_upload_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(photoVaultProvider.notifier)
                        .addPhotoAndExtractWords(
                          title: titleCtrl.text.trim(),
                          localImagePath: pickedImage?.path,
                          manualOrLiveText: notesCtrl.text.trim(),
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWordEditorDialog(PhotoVocabEntry photo, FlashcardEntity? existing) {
    final wordCtrl = TextEditingController(text: existing?.word ?? '');
    final ipaCtrl = TextEditingController(text: existing?.ipa ?? '');
    final meaningCtrl =
        TextEditingController(text: existing?.vietnameseMeaning ?? '');
    final exampleCtrl =
        TextEditingController(text: existing?.exampleSentence ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null
              ? '+ Thêm từ vào ảnh này'
              : '✏️ Chỉnh sửa từ trong ảnh',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordCtrl,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Từ tiếng Anh *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ipaCtrl,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Phiên âm IPA'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: meaningCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nghĩa tiếng Việt *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: exampleCtrl,
                decoration: const InputDecoration(labelText: 'Câu ngữ cảnh'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordCtrl.text.trim().isEmpty ||
                  meaningCtrl.text.trim().isEmpty) {
                return;
              }
              ref.read(photoVaultProvider.notifier).addOrUpdateWordInPhoto(
                    photoId: photo.id,
                    wordId: existing?.id,
                    word: wordCtrl.text.trim(),
                    ipa: ipaCtrl.text.trim(),
                    meaning: meaningCtrl.text.trim(),
                    example: exampleCtrl.text.trim(),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showServerSyncDialog(String currentUrl) {
    final urlCtrl = TextEditingController(text: currentUrl);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔗 Đồng bộ Live với Máy Tính (Wi-Fi LAN)'),
        content: TextField(
          controller: urlCtrl,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ Server (VD: http://192.168.1.10:3000)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(photoVaultProvider.notifier)
                  .updateSyncServerUrl(urlCtrl.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Kết nối & Đồng bộ liên tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(photoVaultProvider);
    final chosen = vault.selectedWords;

    if (_isFlipCardMode && chosen.isNotEmpty) {
      return _buildSeparateFlipDeck(chosen);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gemBlue, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '📸 Kho Từ Ảnh Chụp Riêng Biệt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cấu hình địa chỉ IP đồng bộ liên tục với PC',
                    onPressed: () => _showServerSyncDialog(vault.syncServerUrl),
                    icon: const Icon(Icons.sync_rounded, color: Colors.white),
                  ),
                ],
              ),
              const Text(
                'Lưu trữ hoàn toàn tách biệt với kho từ hệ thống. Tự động cập nhật liên tục mỗi khi bạn chụp hoặc tải ảnh mới lên!',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: vault.isUploading
                        ? null
                        : () => _pickAndUploadPhoto(ImageSource.gallery),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondaryDark,
                    ),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text(
                      'Chọn Ảnh Thư Viện',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: vault.isUploading
                        ? null
                        : () => _pickAndUploadPhoto(ImageSource.camera),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Chụp Camera'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selective Study Control Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Đã chọn ${chosen.length} / ${vault.totalVaultWords} từ (${vault.photos.length} ảnh)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('☑️ Chọn tất cả'),
                      onPressed: () =>
                          ref.read(photoVaultProvider.notifier).selectAll(true),
                    ),
                    ActionChip(
                      label: const Text('⬜ Bỏ chọn hết'),
                      onPressed: () => ref
                          .read(photoVaultProvider.notifier)
                          .selectAll(false),
                    ),
                    FilterChip(
                      label: const Text('🔄 Tự chọn ảnh mới upload'),
                      selected: vault.autoSelectNewUploads,
                      onSelected: (_) => ref
                          .read(photoVaultProvider.notifier)
                          .toggleAutoSelectNewUploads(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: '⚡ Đoán Từ Ẩn (${chosen.length} từ đã chọn)',
                  onPressed: chosen.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => WordChallengeScreen(
                                initialCustomCards: chosen,
                                initialMode: WordChallengeMode.levelTest,
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: chosen.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => WordChallengeScreen(
                                      initialCustomCards: chosen,
                                      initialMode: WordChallengeMode.endless,
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(
                          Icons.local_fire_department_rounded,
                          size: 18,
                        ),
                        label: const Text('Vô tận (Từ ảnh)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: chosen.isEmpty
                            ? null
                            : () => setState(() {
                                  _isFlipCardMode = true;
                                  _flipIndex = 0;
                                  _flipRevealed = false;
                                }),
                        icon: const Icon(Icons.style_rounded, size: 18),
                        label: const Text('Lật thẻ riêng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Photo Entries List
        ...vault.photos.map((photo) => _buildPhotoCard(photo, vault)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPhotoCard(PhotoVocabEntry photo, PhotoVaultState vault) {
    final selectedCount = photo.words
        .where((w) => vault.selectedWordIds.contains(w.id))
        .length;
    final allSelected =
        photo.words.isNotEmpty && selectedCount == photo.words.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildThumbnail(photo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.title, style: AppTypography.titleMedium),
                      Text(
                        'Đã chọn $selectedCount/${photo.words.length} từ',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: allSelected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => ref
                      .read(photoVaultProvider.notifier)
                      .togglePhotoSelection(photo.id),
                ),
                IconButton(
                  tooltip: 'Thêm từ vào ảnh này',
                  onPressed: () => _showWordEditorDialog(photo, null),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Xóa bộ ảnh',
                  onPressed: () => ref
                      .read(photoVaultProvider.notifier)
                      .deletePhoto(photo.id),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            ...photo.words.map((w) {
              final isChecked = vault.selectedWordIds.contains(w.id);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                value: isChecked,
                onChanged: (_) => ref
                    .read(photoVaultProvider.notifier)
                    .toggleSingleWord(w.id),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${w.word}  ${w.ipa}',
                        style: AppTypography.titleMedium,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => ref
                          .read(speechAudioServiceProvider)
                          .speakEnglish(w.word),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showWordEditorDialog(photo, w),
                    ),
                  ],
                ),
                subtitle: Text('${w.vietnameseMeaning}\n"${w.exampleSentence}"'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(PhotoVocabEntry photo) {
    if (!kIsWeb &&
        photo.localImagePath != null &&
        photo.localImagePath!.isNotEmpty &&
        File(photo.localImagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(photo.localImagePath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_rounded, color: AppColors.secondary),
    );
  }

  Widget _buildSeparateFlipDeck(List<FlashcardEntity> chosen) {
    final card = chosen[_flipIndex % chosen.length];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📸 Thẻ Từ Ảnh (${(_flipIndex % chosen.length) + 1}/${chosen.length})',
                style: AppTypography.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => setState(() => _isFlipCardMode = false),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Quay lại Kho Ảnh'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(card.word, style: AppTypography.displayLarge),
                  const SizedBox(height: 6),
                  Text(
                    card.ipa,
                    style: AppTypography.ipaPhonetic.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconButton.filledTonal(
                    onPressed: () => ref
                        .read(speechAudioServiceProvider)
                        .speakEnglish(card.word),
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
                  const SizedBox(height: 18),
                  if (!_flipRevealed)
                    AppButton(
                      label: 'Lật xem nghĩa & câu trong ảnh',
                      isOutlined: true,
                      onPressed: () => setState(() => _flipRevealed = true),
                    )
                  else ...[
                    const Divider(),
                    Text(
                      card.vietnameseMeaning,
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${card.exampleSentence}"',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Từ tiếp theo →',
                      onPressed: () => setState(() {
                        _flipRevealed = false;
                        _flipIndex = (_flipIndex + 1) % chosen.length;
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
