import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/cloud_sync_service.dart';

class CloudSyncScreen
    extends StatefulWidget {
  const CloudSyncScreen({
    super.key,
  });

  @override
  State<CloudSyncScreen> createState() =>
      _CloudSyncScreenState();
}

class _CloudSyncScreenState
    extends State<CloudSyncScreen> {
  bool _loading = true;
  bool _working = false;

  CloudBackupInfo? _cloud;
  DateTime? _lastLocalSync;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final cloud =
      await CloudSyncService.instance
          .getBackupInfo();

      final local =
      await CloudSyncService.instance
          .getLastLocalSync();

      if (!mounted) return;

      setState(() {
        _cloud = cloud;
        _lastLocalSync = local;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _message(
        'Could not check cloud backup: $error',
      );
    }
  }

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'Never';
    }

    final local =
    date.toLocal();

    String two(int value) =>
        value
            .toString()
            .padLeft(2, '0');

    return '${local.month}/${local.day}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  void _message(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _backup() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      final result =
      await CloudSyncService.instance
          .backup();

      if (!mounted) return;

      _message(
        '${result.workoutCount} workouts backed up.',
      );

      await _load();
    } catch (error) {
      _message(
        'Backup failed: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _restore() async {
    if (_cloud == null ||
        _working) {
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          ShubXColors.card,
          title: const Text(
            'Restore cloud backup?',
            style: TextStyle(
              color:
              ShubXColors.white,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          content: Text(
            'This will replace the workout data currently stored on this device with the cloud backup containing ${_cloud!.workoutCount} workouts.',
            style: const TextStyle(
              color:
              ShubXColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'RESTORE',
                style: TextStyle(
                  color:
                  ShubXColors.gold,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _working = true;
    });

    try {
      final result =
      await CloudSyncService.instance
          .restore();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor:
            ShubXColors.card,
            title: const Text(
              'Restore complete',
              style: TextStyle(
                color:
                ShubXColors.white,
                fontWeight:
                FontWeight.w800,
              ),
            ),
            content: Text(
              '${result.workoutCount} workouts were restored. Restart SHUBX so every screen reloads the restored data.',
              style: const TextStyle(
                color:
                ShubXColors.grey,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      await _load();
    } catch (error) {
      _message(
        'Restore failed: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      appBar: AppBar(
        backgroundColor:
        ShubXColors.black,
        title: const Text(
          'CLOUD BACKUP',
          style: TextStyle(
            color:
            ShubXColors.white,
            fontWeight:
            FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          ShubXColors.gold,
        ),
      )
          : ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          Container(
            padding:
            const EdgeInsets.all(
              20,
            ),
            decoration:
            BoxDecoration(
              color:
              ShubXColors.card,
              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  color:
                  ShubXColors.gold,
                  size: 34,
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  'SHUBX CLOUD',
                  style: TextStyle(
                    color:
                    ShubXColors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                const Text(
                  'Back up your X, preferences and workout history to your Firebase account.',
                  style: TextStyle(
                    color:
                    ShubXColors.grey,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                _InfoRow(
                  label:
                  'Cloud workouts',
                  value:
                  _cloud == null
                      ? 'No backup'
                      : '${_cloud!.workoutCount}',
                ),

                const SizedBox(
                  height: 12,
                ),

                _InfoRow(
                  label:
                  'Cloud updated',
                  value:
                  _cloud == null
                      ? 'Never'
                      : _formatDate(
                    _cloud!.updatedAt,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                _InfoRow(
                  label:
                  'Last sync on device',
                  value:
                  _formatDate(
                    _lastLocalSync,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            height: 54,
            child:
            ElevatedButton.icon(
              onPressed:
              _working
                  ? null
                  : _backup,
              icon:
              const Icon(
                Icons.cloud_upload_outlined,
              ),
              label:
              const Text(
                'BACK UP NOW',
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          SizedBox(
            height: 54,
            child:
            OutlinedButton.icon(
              onPressed:
              _cloud == null ||
                  _working
                  ? null
                  : _restore,
              icon:
              const Icon(
                Icons.cloud_download_outlined,
              ),
              label:
              const Text(
                'RESTORE FROM CLOUD',
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          const Text(
            'Restoring replaces the workout data currently stored on this device. Back up first if you want to preserve the current local version.',
            style: TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 10,
              height: 1.45,
            ),
          ),

          if (_working) ...[
            const SizedBox(
              height: 28,
            ),
            const Center(
              child:
              CircularProgressIndicator(
                color:
                ShubXColors.gold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            style: const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}