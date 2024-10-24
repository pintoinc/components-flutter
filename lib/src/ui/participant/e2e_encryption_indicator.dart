import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../context/participant_context.dart';
import '../debug/logger.dart';

class E2EEncryptionIndicator extends StatelessWidget {
  const E2EEncryptionIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(
        builder: (context, participantContext, child) {
      Debug.log(
          '====>        E2EEncryptionIndicator for ${participantContext.name}');
      return Selector<ParticipantContext, bool>(
        selector: (context, isEncrypted) => participantContext.isEncrypted,
        builder: (context, isEncrypted, child) => Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            isEncrypted ? Icons.lock : Icons.lock_open,
            color: Colors.white54,
            size: 20,
          ),
        ),
      );
    });
  }
}
