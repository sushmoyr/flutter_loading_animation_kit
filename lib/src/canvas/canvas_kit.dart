import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class CanvasKitDelegate {
  late CanvasKitContext _context;

  CanvasKitContext get context => _context;

  Canvas get canvas => context.canvas;
  Size get size => context.size;

  void update(double t);

  void save() => canvas.save();

  /// Saves a copy of the current transform and clip on the save stack, and then
  /// creates a new group which subsequent calls will become a part of. When the
  /// save stack is later popped, the group will be flattened into a layer and
  /// have the given `paint`'s [Paint.colorFilter] and [Paint.blendMode]
  /// applied.
  ///
  /// This lets you create composite effects, for example making a group of
  /// drawing commands semi-transparent. Without using [saveLayer], each part of
  /// the group would be painted individually, so where they overlap would be
  /// darker than where they do not. By using [saveLayer] to group them
  /// together, they can be drawn with an opaque color at first, and then the
  /// entire group can be made transparent using the [saveLayer]'s paint.
  ///
  /// Call [restore] to pop the save stack and apply the paint to the group.
  ///
  /// ## Using saveLayer with clips
  ///
  /// When a rectangular clip operation (from [clipRect]) is not axis-aligned
  /// with the raster buffer, or when the clip operation is not rectilinear
  /// (e.g. because it is a rounded rectangle clip created by [clipRRect] or an
  /// arbitrarily complicated path clip created by [clipPath]), the edge of the
  /// clip needs to be anti-aliased.
  ///
  /// If two draw calls overlap at the edge of such a clipped region, without
  /// using [saveLayer], the first drawing will be anti-aliased with the
  /// background first, and then the second will be anti-aliased with the result
  /// of blending the first drawing and the background. On the other hand, if
  /// [saveLayer] is used immediately after establishing the clip, the second
  /// drawing will cover the first in the layer, and thus the second alone will
  /// be anti-aliased with the background when the layer is clipped and
  /// composited (when [restore] is called).
  ///
  /// For example, this [CustomPainter.paint] method paints a clean white
  /// rounded rectangle:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   Rect rect = Offset.zero & size;
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(rect, 100.0, 100.0));
  ///   canvas.saveLayer(rect, Paint());
  ///   canvas.drawPaint(Paint()..color = Colors.red);
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// On the other hand, this one renders a red outline, the result of the red
  /// paint being anti-aliased with the background at the clip edge, then the
  /// white paint being similarly anti-aliased with the background _including
  /// the clipped red paint_:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   // (this example renders poorly, prefer the example above)
  ///   Rect rect = Offset.zero & size;
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(rect, 100.0, 100.0));
  ///   canvas.drawPaint(Paint()..color = Colors.red);
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// This point is moot if the clip only clips one draw operation. For example,
  /// the following paint method paints a pair of clean white rounded
  /// rectangles, even though the clips are not done on a separate layer:
  ///
  /// ```dart
  /// void paint(Canvas canvas, Size size) {
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(Offset.zero & (size / 2.0), 50.0, 50.0));
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  ///   canvas.save();
  ///   canvas.clipRRect(RRect.fromRectXY(size.center(Offset.zero) & (size / 2.0), 50.0, 50.0));
  ///   canvas.drawPaint(Paint()..color = Colors.white);
  ///   canvas.restore();
  /// }
  /// ```
  ///
  /// (Incidentally, rather than using [clipRRect] and [drawPaint] to draw
  /// rounded rectangles like this, prefer the [drawRRect] method. These
  /// examples are using [drawPaint] as a proxy for "complicated draw operations
  /// that will get clipped", to illustrate the point.)
  ///
  /// ## Performance considerations
  ///
  /// Generally speaking, [saveLayer] is relatively expensive.
  ///
  /// There are a several different hardware architectures for GPUs (graphics
  /// processing units, the hardware that handles graphics), but most of them
  /// involve batching commands and reordering them for performance. When layers
  /// are used, they cause the rendering pipeline to have to switch render
  /// target (from one layer to another). Render target switches can flush the
  /// GPU's command buffer, which typically means that optimizations that one
  /// could get with larger batching are lost. Render target switches also
  /// generate a lot of memory churn because the GPU needs to copy out the
  /// current frame buffer contents from the part of memory that's optimized for
  /// writing, and then needs to copy it back in once the previous render target
  /// (layer) is restored.
  ///
  /// See also:
  ///
  ///  * [save], which saves the current state, but does not create a new layer
  ///    for subsequent commands.
  ///  * [BlendMode], which discusses the use of [Paint.blendMode] with
  ///    [saveLayer].
  void saveLayer(Rect? bounds, Paint paint) => canvas.saveLayer(bounds, paint);

  /// Pops the current save stack, if there is anything to pop.
  /// Otherwise, does nothing.
  ///
  /// Use [save] and [saveLayer] to push state onto the stack.
  ///
  /// If the state was pushed with with [saveLayer], then this call will also
  /// cause the new layer to be composited into the previous layer.
  void restore() => canvas.restore();

  /// Returns the number of items on the save stack, including the
  /// initial state. This means it returns 1 for a clean canvas, and
  /// that each call to [save] and [saveLayer] increments it, and that
  /// each matching call to [restore] decrements it.
  ///
  /// This number cannot go below 1.
  int getSaveCount() => canvas.getSaveCount();

  /// Add a translation to the current transform, shifting the coordinate space
  /// horizontally by the first argument and vertically by the second argument.
  void translate(double dx, double dy) => canvas.translate(dx, dy);

  /// Add an axis-aligned scale to the current transform, scaling by the first
  /// argument in the horizontal direction and the second in the vertical
  /// direction.
  ///
  /// If [sy] is unspecified, [sx] will be used for the scale in both
  /// directions.
  void scale(double sx, [double? sy]) => canvas.scale(sx);

  /// Add a rotation to the current transform. The argument is in radians clockwise.
  void rotate(double radians) => canvas.rotate(radians);

  /// Add an axis-aligned skew to the current transform, with the first argument
  /// being the horizontal skew in rise over run units clockwise around the
  /// origin, and the second argument being the vertical skew in rise over run
  /// units clockwise around the origin.
  void skew(double sx, double sy) => canvas.skew(sx, sy);

  /// Multiply the current transform by the specified 4⨉4 transformation matrix
  /// specified as a list of values in column-major order.
  void transform(Float64List matrix4) => canvas.transform(matrix4);

  /// Returns the current transform including the combined result of all transform
  /// methods executed since the creation of this [Canvas] object, and respecting the
  /// save/restore history.
  ///
  /// Methods that can change the current transform include [translate], [scale],
  /// [rotate], [skew], and [transform]. The [restore] method can also modify
  /// the current transform by restoring it to the same value it had before its
  /// associated [save] or [saveLayer] call.
  Float64List getTransform() => canvas.getTransform();

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rectangle.
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that.
  ///
  /// Use [ClipOp.difference] to subtract the provided rectangle from the
  /// current clip.
  void clipRect(Rect rect,
          {ui.ClipOp clipOp = ui.ClipOp.intersect, bool doAntiAlias = true}) =>
      canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rounded rectangle.
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that and some examples of using [clipRRect].
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) =>
      canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);

  /// Reduces the clip region to the intersection of the current clip and the
  /// given [Path].
  ///
  /// If [doAntiAlias] is true, then the clip will be anti-aliased.
  ///
  /// If multiple draw commands intersect with the clip boundary, this can result
  /// in incorrect blending at the clip boundary. See [saveLayer] for a
  /// discussion of how to address that.
  void clipPath(Path path, {bool doAntiAlias = true}) =>
      canvas.clipPath(path, doAntiAlias: doAntiAlias);

  /// Returns the conservative bounds of the combined result of all clip methods
  /// executed within the current save stack of this [Canvas] object, as measured
  /// in the local coordinate space under which rendering operations are curretnly
  /// performed.
  ///
  /// The combined clip results are rounded out to an integer pixel boundary before
  /// they are transformed back into the local coordinate space which accounts for
  /// the pixel roundoff in rendering operations, particularly when antialiasing.
  /// Because the [Picture] may eventually be rendered into a scene within the
  /// context of transforming widgets or layers, the result may thus be overly
  /// conservative due to premature rounding. Using the [getDestinationClipBounds]
  /// method combined with the external transforms and rounding in the true device
  /// coordinate system will produce more accurate results, but this value may
  /// provide a more convenient approximation to compare rendering operations to
  /// the established clip.
  ///
  /// {@template dart.ui.canvas.conservativeClipBounds}
  /// The conservative estimate of the bounds is based on intersecting the bounds
  /// of each clip method that was executed with [ClipOp.intersect] and potentially
  /// ignoring any clip method that was executed with [ClipOp.difference]. The
  /// [ClipOp] argument is only present on the [clipRect] method.
  ///
  /// To understand how the bounds estimate can be conservative, consider the
  /// following two clip method calls:
  ///
  /// ```dart
  ///    clipPath(Path()
  ///      ..addRect(const Rect.fromLTRB(10, 10, 20, 20))
  ///      ..addRect(const Rect.fromLTRB(80, 80, 100, 100)));
  ///    clipPath(Path()
  ///      ..addRect(const Rect.fromLTRB(80, 10, 100, 20))
  ///      ..addRect(const Rect.fromLTRB(10, 80, 20, 100)));
  /// ```
  ///
  /// After executing both of those calls there is no area left in which to draw
  /// because the two paths have no overlapping regions. But, in this case,
  /// [getClipBounds] would return a rectangle from `10, 10` to `100, 100` because it
  /// only intersects the bounds of the two path objects to obtain its conservative
  /// estimate.
  ///
  /// The clip bounds are not affected by the bounds of any enclosing
  /// [saveLayer] call as the engine does not currently guarantee the strict
  /// enforcement of those bounds during rendering.
  ///
  /// Methods that can change the current clip include [clipRect], [clipRRect],
  /// and [clipPath]. The [restore] method can also modify the current clip by
  /// restoring it to the same value it had before its associated [save] or
  /// [saveLayer] call.
  /// {@endtemplate}
  Rect getLocalClipBounds() => canvas.getLocalClipBounds();

  /// Returns the conservative bounds of the combined result of all clip methods
  /// executed within the current save stack of this [Canvas] object, as measured
  /// in the destination coordinate space in which the [Picture] will be rendered.
  ///
  /// Unlike [getLocalClipBounds], the bounds are not rounded out to an integer
  /// pixel boundary as the Destination coordinate space may not represent pixels
  /// if the [Picture] being constructed will be further transformed when it is
  /// rendered or added to a scene. In order to determine the true pixels being
  /// affected, those external transforms should be applied first before rounding
  /// out the result to integer pixel boundaries. Most typically, [Picture] objects
  /// are rendered in a scene with a scale transform representing the Device Pixel
  /// Ratio.
  ///
  /// {@macro dart.ui.canvas.conservativeClipBounds}
  Rect getDestinationClipBounds() => canvas.getDestinationClipBounds();

  /// Paints the given [Color] onto the canvas, applying the given
  /// [BlendMode], with the given color being the source and the background
  /// being the destination.
  void drawColor(Color color, BlendMode blendMode) =>
      canvas.drawColor(color, blendMode);

  /// Draws a line between the given points using the given paint. The line is
  /// stroked, the value of the [Paint.style] is ignored for this call.
  ///
  /// The `p1` and `p2` arguments are interpreted as offsets from the origin.
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      canvas.drawLine(p1, p2, paint);

  /// Fills the canvas with the given [Paint].
  ///
  /// To fill the canvas with a solid color and blend mode, consider
  /// [drawColor] instead.
  void drawPaint(Paint paint) => canvas.drawPaint(paint);

  /// Draws a rectangle with the given [Paint]. Whether the rectangle is filled
  /// or stroked (or both) is controlled by [Paint.style].
  void drawRect(Rect rect, Paint paint) => canvas.drawRect(rect, paint);

  /// Draws a rounded rectangle with the given [Paint]. Whether the rectangle is
  /// filled or stroked (or both) is controlled by [Paint.style].
  void drawRRect(RRect rrect, Paint paint) => canvas.drawRRect(rrect, paint);

  /// Draws a shape consisting of the difference between two rounded rectangles
  /// with the given [Paint]. Whether this shape is filled or stroked (or both)
  /// is controlled by [Paint.style].
  ///
  /// This shape is almost but not quite entirely unlike an annulus.
  void drawDRRect(RRect outer, RRect inner, Paint paint) =>
      canvas.drawDRRect(outer, inner, paint);

  /// Draws an axis-aligned oval that fills the given axis-aligned rectangle
  /// with the given [Paint]. Whether the oval is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawOval(Rect rect, Paint paint) => canvas.drawOval(rect, paint);

  /// Draws a circle centered at the point given by the first argument and
  /// that has the radius given by the second argument, with the [Paint] given in
  /// the third argument. Whether the circle is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawCircle(Offset c, double radius, Paint paint) =>
      canvas.drawCircle(c, radius, paint);

  /// Draw an arc scaled to fit inside the given rectangle.
  ///
  /// It starts from `startAngle` radians around the oval up to
  /// `startAngle` + `sweepAngle` radians around the oval, with zero radians
  /// being the point on the right hand side of the oval that crosses the
  /// horizontal line that intersects the center of the rectangle and with positive
  /// angles going clockwise around the oval. If `useCenter` is true, the arc is
  /// closed back to the center, forming a circle sector. Otherwise, the arc is
  /// not closed, forming a circle segment.
  ///
  /// This method is optimized for drawing arcs and should be faster than [Path.arcTo].
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
          Paint paint) =>
      canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);

  /// Draws the given [Path] with the given [Paint].
  ///
  /// Whether this shape is filled or stroked (or both) is controlled by
  /// [Paint.style]. If the path is filled, then sub-paths within it are
  /// implicitly closed (see [Path.close]).
  void drawPath(Path path, Paint paint) => canvas.drawPath(path, paint);

  /// Draws the given [Image] into the canvas with its top-left corner at the
  /// given [Offset]. The image is composited into the canvas using the given [Paint].
  void drawImage(ui.Image image, Offset offset, Paint paint) =>
      canvas.drawImage(image, offset, paint);

  /// Draws the subset of the given image described by the `src` argument into
  /// the canvas in the axis-aligned rectangle given by the `dst` argument.
  ///
  /// This might sample from outside the `src` rect by up to half the width of
  /// an applied filter.
  ///
  /// Multiple calls to this method with different arguments (from the same
  /// image) can be batched into a single call to [drawAtlas] to improve
  /// performance.
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) =>
      canvas.drawImageRect(image, src, dst, paint);

  /// Draws the given [Image] into the canvas using the given [Paint].
  ///
  /// The image is drawn in nine portions described by splitting the image by
  /// drawing two horizontal lines and two vertical lines, where the `center`
  /// argument describes the rectangle formed by the four points where these
  /// four lines intersect each other. (This forms a 3-by-3 grid of regions,
  /// the center region being described by the `center` argument.)
  ///
  /// The four regions in the corners are drawn, without scaling, in the four
  /// corners of the destination rectangle described by `dst`. The remaining
  /// five regions are drawn by stretching them to fit such that they exactly
  /// cover the destination rectangle while maintaining their relative
  /// positions.
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) =>
      canvas.drawImageNine(image, center, dst, paint);

  /// Draw the given picture onto the canvas. To create a picture, see
  /// [PictureRecorder].
  void drawPicture(ui.Picture picture) => canvas.drawPicture(picture);

  /// Draws the text in the given [Paragraph] into this canvas at the given
  /// [Offset].
  ///
  /// The [Paragraph] object must have had [Paragraph.layout] called on it
  /// first.
  ///
  /// To align the text, set the `textAlign` on the [ParagraphStyle] object
  /// passed to the [ParagraphBuilder] constructor. For more details see
  /// [TextAlign] and the discussion at [ParagraphStyle].
  ///
  /// If the text is left aligned or justified, the left margin will be at the
  /// position specified by the `offset` argument's [Offset.dx] coordinate.
  ///
  /// If the text is right aligned or justified, the right margin will be at the
  /// position described by adding the [ParagraphConstraints.width] given to
  /// [Paragraph.layout], to the `offset` argument's [Offset.dx] coordinate.
  ///
  /// If the text is centered, the centering axis will be at the position
  /// described by adding half of the [ParagraphConstraints.width] given to
  /// [Paragraph.layout], to the `offset` argument's [Offset.dx] coordinate.
  void drawParagraph(ui.Paragraph paragraph, Offset offset) =>
      canvas.drawParagraph(paragraph, offset);

  /// Draws a sequence of points according to the given [PointMode].
  ///
  /// The `points` argument is interpreted as offsets from the origin.
  ///
  /// See also:
  ///
  ///  * [drawRawPoints], which takes `points` as a [Float32List] rather than a
  ///    [List<Offset>].
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) =>
      canvas.drawPoints(pointMode, points, paint);

  /// Draws a sequence of points according to the given [PointMode].
  ///
  /// The `points` argument is interpreted as a list of pairs of floating point
  /// numbers, where each pair represents an x and y offset from the origin.
  ///
  /// See also:
  ///
  ///  * [drawPoints], which takes `points` as a [List<Offset>] rather than a
  ///    [List<Float32List>].
  void drawRawPoints(ui.PointMode pointMode, Float32List points, Paint paint) =>
      canvas.drawRawPoints(pointMode, points, paint);

  /// Draws the set of [Vertices] onto the canvas.
  ///
  /// The [blendMode] parameter is used to control how the colors in
  /// the [vertices] are combined with the colors in the [paint].
  /// If there are no colors specified in [vertices] then the [blendMode] has
  /// no effect. If there are colors in the [vertices],
  /// then the color taken from the [Shader] or [Color] in the [paint] is
  /// blended with the colors specified in the [vertices] using
  /// the [blendMode] parameter.
  /// For purposes of this blending,
  /// the colors from the [paint] are considered the source and the colors from
  /// the [vertices] are considered the destination.
  ///
  /// All parameters must not be null.
  ///
  /// See also:
  ///   * [Vertices], which creates a set of vertices to draw on the canvas.
  ///   * [Vertices.raw], which creates the vertices using typed data lists
  ///     rather than unencoded lists.
  ///   * [paint], Image shaders can be used to draw images on a triangular mesh.
  void drawVertices(ui.Vertices vertices, BlendMode blendMode, Paint paint) =>
      canvas.drawVertices(vertices, blendMode, paint);

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  ///
  /// This method allows for optimization when you want to draw many parts of an
  /// image onto the canvas, such as when using sprites or zooming. It is more efficient
  /// than using multiple calls to [drawImageRect] and provides more functionality
  /// to individually transform each image part by a separate rotation or scale and
  /// blend or modulate those parts with a solid color.
  ///
  /// The method takes a list of [Rect] objects that each define a piece of the
  /// [atlas] image to be drawn independently. Each [Rect] is associated with an
  /// [RSTransform] entry in the [transforms] list which defines the location,
  /// rotation, and (uniform) scale with which to draw that portion of the image.
  /// Each [Rect] can also be associated with an optional [Color] which will be
  /// composed with the associated image part using the [blendMode] before blending
  /// the result onto the canvas. The full operation can be broken down as:
  ///
  /// - Blend each rectangular portion of the image specified by an entry in the
  /// [rects] argument with its associated entry in the [colors] list using the
  /// [blendMode] argument (if a color is specified). In this part of the operation,
  /// the image part will be considered the source of the operation and the associated
  /// color will be considered the destination.
  /// - Blend the result from the first step onto the canvas using the translation,
  /// rotation, and scale properties expressed in the associated entry in the
  /// [transforms] list using the properties of the [Paint] object.
  ///
  /// If the first stage of the operation which blends each part of the image with
  /// a color is needed, then both the [colors] and [blendMode] arguments must
  /// not be null and there must be an entry in the [colors] list for each
  /// image part. If that stage is not needed, then the [colors] argument can
  /// be either null or an empty list and the [blendMode] argument may also be null.
  ///
  /// The optional [cullRect] argument can provide an estimate of the bounds of the
  /// coordinates rendered by all components of the atlas to be compared against
  /// the clip to quickly reject the operation if it does not intersect.
  ///
  /// An example usage to render many sprites from a single sprite atlas with no
  /// rotations or scales:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, <RSTransform>[
  ///       for (Sprite sprite in allSprites)
  ///         RSTransform.fromComponents(
  ///           rotation: 0.0,
  ///           scale: 1.0,
  ///           // Center of the sprite relative to its rect
  ///           anchorX: 5.0,
  ///           anchorY: 5.0,
  ///           // Location at which to draw the center of the sprite
  ///           translateX: sprite.centerX,
  ///           translateY: sprite.centerY,
  ///         ),
  ///     ], <Rect>[
  ///       for (Sprite sprite in allSprites)
  ///         Rect.fromLTWH(sprite.index * 10.0, 0.0, 10.0, 10.0),
  ///     ], null, null, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// Another example usage which renders sprites with an optional opacity and rotation:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  ///   int alpha;
  ///   double rotation;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, <RSTransform>[
  ///       for (Sprite sprite in allSprites)
  ///         RSTransform.fromComponents(
  ///           rotation: sprite.rotation,
  ///           scale: 1.0,
  ///           // Center of the sprite relative to its rect
  ///           anchorX: 5.0,
  ///           anchorY: 5.0,
  ///           // Location at which to draw the center of the sprite
  ///           translateX: sprite.centerX,
  ///           translateY: sprite.centerY,
  ///         ),
  ///     ], <Rect>[
  ///       for (Sprite sprite in allSprites)
  ///         Rect.fromLTWH(sprite.index * 10.0, 0.0, 10.0, 10.0),
  ///     ], <Color>[
  ///       for (Sprite sprite in allSprites)
  ///         Colors.white.withAlpha(sprite.alpha),
  ///     ], BlendMode.srcIn, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// The length of the [transforms] and [rects] lists must be equal and
  /// if the [colors] argument is not null then it must either be empty or
  /// have the same length as the other two lists.
  ///
  /// See also:
  ///
  ///  * [drawRawAtlas], which takes its arguments as typed data lists rather
  ///    than objects.
  void drawAtlas(
          ui.Image atlas,
          List<RSTransform> transforms,
          List<Rect> rects,
          List<Color>? colors,
          BlendMode? blendMode,
          Rect? cullRect,
          Paint paint) =>
      canvas.drawAtlas(
          atlas, transforms, rects, colors, blendMode, cullRect, paint);

  /// Draws many parts of an image - the [atlas] - onto the canvas.
  ///
  /// This method allows for optimization when you want to draw many parts of an
  /// image onto the canvas, such as when using sprites or zooming. It is more efficient
  /// than using multiple calls to [drawImageRect] and provides more functionality
  /// to individually transform each image part by a separate rotation or scale and
  /// blend or modulate those parts with a solid color. It is also more efficient
  /// than [drawAtlas] as the data in the arguments is already packed in a format
  /// that can be directly used by the rendering code.
  ///
  /// A full description of how this method uses its arguments to draw onto the
  /// canvas can be found in the description of the [drawAtlas] method.
  ///
  /// The [rstTransforms] argument is interpreted as a list of four-tuples, with
  /// each tuple being ([RSTransform.scos], [RSTransform.ssin],
  /// [RSTransform.tx], [RSTransform.ty]).
  ///
  /// The [rects] argument is interpreted as a list of four-tuples, with each
  /// tuple being ([Rect.left], [Rect.top], [Rect.right], [Rect.bottom]).
  ///
  /// The [colors] argument, which can be null, is interpreted as a list of
  /// 32-bit colors, with the same packing as [Color.value]. If the [colors]
  /// argument is not null then the [blendMode] argument must also not be null.
  ///
  /// An example usage to render many sprites from a single sprite atlas with no rotations
  /// or scales:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     // For best advantage, these lists should be cached and only specific
  ///     // entries updated when the sprite information changes. This code is
  ///     // illustrative of how to set up the data and not a recommendation for
  ///     // optimal usage.
  ///     Float32List rectList = Float32List(allSprites.length * 4);
  ///     Float32List transformList = Float32List(allSprites.length * 4);
  ///     for (int i = 0; i < allSprites.length; i++) {
  ///       final double rectX = sprite.spriteIndex * 10.0;
  ///       rectList[i * 4 + 0] = rectX;
  ///       rectList[i * 4 + 1] = 0.0;
  ///       rectList[i * 4 + 2] = rectX + 10.0;
  ///       rectList[i * 4 + 3] = 10.0;
  ///
  ///       // This example sets the RSTransform values directly for a common case of no
  ///       // rotations or scales and just a translation to position the atlas entry. For
  ///       // more complicated transforms one could use the RSTransform class to compute
  ///       // the necessary values or do the same math directly.
  ///       transformList[i * 4 + 0] = 1.0;
  ///       transformList[i * 4 + 1] = 0.0;
  ///       transformList[i * 4 + 2] = sprite.centerX - 5.0;
  ///       transformList[i * 4 + 3] = sprite.centerY - 5.0;
  ///     }
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, transformList, rectList, null, null, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// Another example usage which renders sprites with an optional opacity and rotation:
  ///
  /// ```dart
  /// class Sprite {
  ///   int index;
  ///   double centerX;
  ///   double centerY;
  ///   int alpha;
  ///   double rotation;
  /// }
  ///
  /// class MyPainter extends CustomPainter {
  ///   // assume spriteAtlas contains N 10x10 sprites side by side in a (N*10)x10 image
  ///   ui.Image spriteAtlas;
  ///   List<Sprite> allSprites;
  ///
  ///   @override
  ///   void paint(Canvas canvas, Size size) {
  ///     // For best advantage, these lists should be cached and only specific
  ///     // entries updated when the sprite information changes. This code is
  ///     // illustrative of how to set up the data and not a recommendation for
  ///     // optimal usage.
  ///     Float32List rectList = Float32List(allSprites.length * 4);
  ///     Float32List transformList = Float32List(allSprites.length * 4);
  ///     Int32List colorList = Int32List(allSprites.length);
  ///     for (int i = 0; i < allSprites.length; i++) {
  ///       final double rectX = sprite.spriteIndex * 10.0;
  ///       rectList[i * 4 + 0] = rectX;
  ///       rectList[i * 4 + 1] = 0.0;
  ///       rectList[i * 4 + 2] = rectX + 10.0;
  ///       rectList[i * 4 + 3] = 10.0;
  ///
  ///       // This example uses an RSTransform object to compute the necessary values for
  ///       // the transform using a factory helper method because the sprites contain
  ///       // rotation values which are not trivial to work with. But if the math for the
  ///       // values falls out from other calculations on the sprites then the values could
  ///       // possibly be generated directly from the sprite update code.
  ///       final RSTransform transform = RSTransform.fromComponents(
  ///         rotation: sprite.rotation,
  ///         scale: 1.0,
  ///         // Center of the sprite relative to its rect
  ///         anchorX: 5.0,
  ///         anchorY: 5.0,
  ///         // Location at which to draw the center of the sprite
  ///         translateX: sprite.centerX,
  ///         translateY: sprite.centerY,
  ///       );
  ///       transformList[i * 4 + 0] = transform.scos;
  ///       transformList[i * 4 + 1] = transform.ssin;
  ///       transformList[i * 4 + 2] = transform.tx;
  ///       transformList[i * 4 + 3] = transform.ty;
  ///
  ///       // This example computes the color value directly, but one could also compute
  ///       // an actual Color object and use its Color.value getter for the same result.
  ///       // Since we are using BlendMode.srcIn, only the alpha component matters for
  ///       // these colors which makes this a simple shift operation.
  ///       colorList[i] = sprite.alpha << 24;
  ///     }
  ///     Paint paint = Paint();
  ///     canvas.drawAtlas(spriteAtlas, transformList, rectList, colorList, BlendMode.srcIn, null, paint);
  ///   }
  ///
  ///   ...
  /// }
  /// ```
  ///
  /// See also:
  ///
  ///  * [drawAtlas], which takes its arguments as objects rather than typed
  ///    data lists.
  void drawRawAtlas(
          ui.Image atlas,
          Float32List rstTransforms,
          Float32List rects,
          Int32List? colors,
          BlendMode? blendMode,
          Rect? cullRect,
          Paint paint) =>
      canvas.drawRawAtlas(
          atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);

  /// Draws a shadow for a [Path] representing the given material elevation.
  ///
  /// The `transparentOccluder` argument should be true if the occluding object
  /// is not opaque.
  ///
  /// The arguments must not be null.
  void drawShadow(
          Path path, Color color, double elevation, bool transparentOccluder) =>
      canvas.drawShadow(path, color, elevation, transparentOccluder);
}

@immutable
class CanvasKitContext {
  final Size size;
  final Canvas canvas;

  const CanvasKitContext({required this.size, required this.canvas});

  double get width => size.width;
  double get height => size.height;
}

class CanvasPainter extends CustomPainter {
  final CanvasKitDelegate delegate;
  final ValueListenable<double> time;

  CanvasPainter({required this.delegate, required this.time})
      : super(repaint: time);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    CanvasKitContext context = CanvasKitContext(size: size, canvas: canvas);
    delegate._context = context;
    delegate.update(time.value);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.delegate != delegate;
  }
}
