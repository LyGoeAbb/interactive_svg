import 'package:flutter/material.dart';

import '../../interactive_svg.dart';

/// An abstract factory that computes and exposes SVG region bounds.
///
/// Implementations are expected to compute bounds for parsed SVG regions and expose:
/// - [hasData]: whether meaningful bounds are available,
/// - [data]: the computed mapping of selectors to region bounds,
/// - [state]: the current computation state.
///
/// Implementations should notify listeners when the available bounds change (via
/// ChangeNotifier). Clients can call [load] to (re)compute bounds and [reset]
/// to clear cached results or swap parser delegates.
///
/// Important notes:
/// - Bounds computation may depend on the widget size (layout). Callers that need
///   bounds after layout should call [load] from a post-frame callback or when
///   the hosting widget reports its size.
/// - [data] should be a stable (possibly empty) [BoundsList] and never return null.
abstract class BoundsFactory extends ChangeNotifier {
  /// Returns true if computed bounds exist and are non-empty.
  ///
  /// This is a convenience flag for callers to know whether calling `data`
  /// will yield meaningful bounds.
  bool get hasData;

  /// Returns the current computed bounds mapping.
  ///
  /// Implementations should return an empty [BoundsList] when no data exists
  /// rather than null. Accessing this property is expected to be cheap and
  /// synchronous.
  BoundsList get data;

  /// The current [ConnectionState] of the underlying bounds computation.
  ///
  /// Useful for driving UI state (e.g., showing a loading indicator while waiting
  /// for bounds).
  ConnectionState get state;

  /// Reset internal cached bounds and optionally replace the [parserDelegate].
  ///
  /// - When [parserDelegate] is provided, the factory should use the new delegate
  ///   for subsequent computations.
  /// - After calling `reset`, implementations MUST notify listeners (if any) that
  ///   data/state changed.
  void reset([InteractiveParserDelegate? parserDelegate]);

  /// (Re)compute bounds using the current widget size, [fit] and [alignment].
  ///
  /// Implementations should compute bounds synchronously or asynchronously, update
  /// internal state accordingly, and call [notifyListeners] once results are available.
  /// Callers that depend on layout should call this method from a post-frame callback.
  void load({
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.topLeft,
  });
}
