## Notebook canvas architecture

### Stroke engine
- Use `perfect_freehand` package for converting raw pointer events into beautiful strokes
- On iOS: prefer native PencilKit via `pencilkit` package for best Apple Pencil experience (pressure, tilt, azimuth)
- On Android: use Flutter's GestureDetector + perfect_freehand
- Platform check: `if (Platform.isIOS) → PencilKit widget; else → custom Flutter canvas`

### Data model
- Each page = list of strokes + list of text elements + list of images
- Each stroke = list of points (x, y, pressure, timestamp)
- Strokes are stored in SQLite locally, synced to Supabase when online
- Canvas uses CustomPainter for rendering

### Tools
- Pen (variable width based on pressure)
- Highlighter (semi-transparent, doesn't overlap with itself)
- Eraser (stroke eraser, not pixel eraser)
- Lasso select (freeform selection of strokes → can move, copy, or send to AI)
- Text tool (insert typed text)
- Color picker
- Undo/redo stack (keep last 50 operations)

### Performance
- Only render visible strokes (viewport culling)
- Use RepaintBoundary to isolate canvas repaints
- Batch stroke data writes to SQLite (don't write on every point)
