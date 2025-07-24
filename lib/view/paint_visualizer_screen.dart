import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PaintVisualizerScreen extends StatefulWidget {
  const PaintVisualizerScreen({Key? key}) : super(key: key);

  @override
  State<PaintVisualizerScreen> createState() => _PaintVisualizerScreenState();
}

class _PaintVisualizerScreenState extends State<PaintVisualizerScreen> {
  File? _imageFile;
  final List<Offset> _points = [];
  Color _selectedColor = Colors.red.withOpacity(0.5);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _points.clear();
      });
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _clearPoints() => setState(() => _points.clear());

  void _pickColor() async {
    Color tmp = _selectedColor;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tmp,
            onColorChanged: (c) => tmp = c.withOpacity(0.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Select'),
          )
        ],
      ),
    );
    setState(() => _selectedColor = tmp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Visualizer'),
        actions: [
          IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo)),
          IconButton(onPressed: _pickColor, icon: const Icon(Icons.color_lens)),
          IconButton(onPressed: _clearPoints, icon: const Icon(Icons.clear)),
        ],
      ),
      body: Center(
        child: _imageFile == null
            ? const Text('Pick an image to start')
            : LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _onTapDown,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WallPainter(points: _points, color: _selectedColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _WallPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _WallPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WallPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
