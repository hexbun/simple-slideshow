import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideShow extends StatefulWidget {
  final List<String> images;
  final Duration timePerImage;

  const SlideShow({required this.images, required this.timePerImage, Key? key})
      : super(key: key);

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  int _index = 0;
  var paused = false;
  late Timer _timer;
  String _folderName = "";

  @override
  void initState() {
    super.initState();
    widget.images.shuffle(Random());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.timePerImage, (Timer timer) {
      if (widget.images.length - 1 == _index) {
        _reset();
      } else {
        setState(() {
          _index += 1;
        });
      }
    }); //widget.images[_index].bytes!,
  }

  void _updateIndex(int value) {
    setState(() {
      if (paused) {
        _index += value;
      } else {
        _timer.cancel();
        _index += value;
        _startTimer();
      }
    });
  }

  void _reset() {
    setState(() {
      _index = 0;
    });
  }

  void _goToLast() {
    setState(() {
      _index = widget.images.length - 1;
    });
  }

  String _getFolderName() {
    var splitted = widget.images[_index].split('\\');
    return splitted[splitted.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent e) {
        if (e.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          if (_index < widget.images.length - 1) {
            _updateIndex(1);
          } else {
            _reset();
          }
        } else if (e.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          if (_index > 0) {
            _updateIndex(-1);
          } else {
            _goToLast();
          }
        } else if (e.isKeyPressed(LogicalKeyboardKey.space)) {
          if (paused) {
            _startTimer();
          } else {
            _timer.cancel();
          }
          setState(() {
            paused = !paused;
          });
        } else if (e.isKeyPressed(LogicalKeyboardKey.escape)) {
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: <Widget>[
          Image.file(
            File(widget.images[_index]),
            fit: BoxFit.fitHeight,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          if (paused)
            const Positioned(
              bottom: 20,
              left: 5,
              child: Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 5,
            child: Text(
              _getFolderName(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
