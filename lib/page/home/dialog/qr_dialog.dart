import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

class QrDialog extends StatefulWidget {
  const QrDialog({super.key});

  @override
  State<QrDialog> createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {

  @override
  Widget build(BuildContext context) {
    return DialogBase(
        child: Center(
          child: QrImageView(
              data: "hello QR code",
            version: QrVersions.auto,
            size: 320,
          ),
        )
    );
  }
}
