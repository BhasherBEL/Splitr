import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/model/participant.dart';

import '../../model/project.dart';

class BalancingPagePart extends StatelessWidget {
  const BalancingPagePart(
    this.project, {
    super.key,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    Map<Participant, double> parts = {
      for (Participant participant in project.participants)
        participant: project.shareOf(participant)
    };

    List<Participant> sortedParticipants = parts.keys.toList(growable: false);
    sortedParticipants.sort((a, b) => parts[b]!.compareTo(parts[a]!));

    double maxShare = parts.isNotEmpty ? max(parts.values.reduce(max), 1) : 1;

    return ListView.builder(
      itemBuilder: (context, index) {
        Participant p = sortedParticipants.elementAt(index);
        double w = MediaQuery.of(context).size.width / 2;
        bool last = index == sortedParticipants.length - 1;
        return GestureDetector(
          onTap: () {
            print("yes");
            // project.currentParticipant = p;
            // project.currentParticipantId = p.localId;
          },
          child: Padding(
            padding: last
                ? const EdgeInsets.only(bottom: 50, top: 20)
                : const EdgeInsets.symmetric(vertical: 20),
            child: CustomPaint(
              painter: SharePainter(
                participant: p,
                share: parts[p]!,
                isMe: project.currentParticipant == p,
                maxShare: maxShare,
                screenW: w,
              ),
            ),
          ),
        );
      },
      itemCount: sortedParticipants.length,
    );
  }
}

class SharePainter extends CustomPainter {
  const SharePainter({
    required this.participant,
    required this.share,
    required this.isMe,
    required this.maxShare,
    required this.screenW,
  });

  final Participant participant;
  final double share;
  final bool isMe;
  final double maxShare;
  final double screenW;

  @override
  void paint(Canvas canvas, Size size) {
    double w = share / maxShare * screenW * 0.95;
    double h = 30;
    double centerW = w / 2 + screenW;

    var paint1 = Paint()
      ..color = w > 0 ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    RRect fullRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(centerW, h / 2), width: w, height: h),
      topLeft: w < 0 ? const Radius.circular(5) : Radius.zero,
      bottomLeft: w < 0 ? const Radius.circular(5) : Radius.zero,
      topRight: w > 0 ? const Radius.circular(5) : Radius.zero,
      bottomRight: w > 0 ? const Radius.circular(5) : Radius.zero,
    );
    canvas.drawRRect(fullRect, paint1);

    var pseudoPainter = TextPainter(
      text: TextSpan(
        text: participant.pseudo,
        style: TextStyle(
          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    var valuePainter = TextPainter(
      text: TextSpan(
        text: "${share.toStringAsFixed(2)}€",
        style: TextStyle(
          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    pseudoPainter.layout();
    valuePainter.layout();

    if (w >= 0) {
      pseudoPainter.paint(
        canvas,
        Offset(
          screenW - pseudoPainter.width - 10,
          (h - pseudoPainter.height) / 2,
        ),
      );
      valuePainter.paint(
        canvas,
        Offset(
          screenW + 10,
          (h - valuePainter.height) / 2,
        ),
      );
    } else {
      pseudoPainter.paint(
        canvas,
        Offset(
          screenW + 10,
          (h - pseudoPainter.height) / 2,
        ),
      );
      valuePainter.paint(
        canvas,
        Offset(
          screenW - valuePainter.width - 10,
          (h - valuePainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
