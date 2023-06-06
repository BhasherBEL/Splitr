import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/model/participant.dart';

import '../../../model/project.dart';
import 'refund_page_part.dart';

class BalancingPagePart extends StatefulWidget {
  const BalancingPagePart(
    this.project, {
    super.key,
  });

  final Project project;

  @override
  State<BalancingPagePart> createState() => _BalancingPagePartState();
}

class _BalancingPagePartState extends State<BalancingPagePart> {
  @override
  Widget build(BuildContext context) {
    Map<Participant, double> parts = {
      for (Participant participant in widget.project.participants)
        participant: widget.project.shareOf(participant)
    };

    List<Participant> sortedParticipants = parts.keys.toList();
    sortedParticipants.sort((a, b) => parts[b]!.compareTo(parts[a]!));

    double maxShare = parts.isNotEmpty
        ? max(parts.values.map((e) => e.abs()).reduce(max), 1)
        : 1;

    List<Widget> items = [];

    for (Participant p in sortedParticipants) {
      double w = MediaQuery.of(context).size.width / 2;
      bool isMe = widget.project.currentParticipant == p;
      items.add(
        GestureDetector(
          onTap: () async {
            widget.project.currentParticipant = p;
            widget.project.currentParticipantId = p.localId;
            widget.project.conn.save();
            setState(() {});
          },
          child: Padding(
            padding: isMe
                ? const EdgeInsets.only(top: 5, bottom: 10)
                : const EdgeInsets.symmetric(vertical: 5),
            child: CustomPaint(
              painter: SharePainter(
                participant: p,
                share: parts[p]!,
                isMe: isMe,
                maxShare: maxShare,
                screenW: w,
              ),
              child: Container(height: 30),
            ),
          ),
        ),
      );
    }

    items.addAll(
      getRefundPageTiles(
        project: widget.project,
        parts: parts,
        sortedParticipants: sortedParticipants,
        context: context,
      ),
    );
    return ListView(
      children: items,
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
        text: participant.pseudo + (isMe ? " (Me)" : ""),
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
