[![pub.dev package page](https://badgen.net/pub/v/circular_clip_route)](https://pub.dev/packages/circular_clip_route)
[![GitHub Stars](https://badgen.net/github/stars/blaugold/circular_clip_route)](https://github.com/blaugold/circular_clip_route/stargazers)

A page route, which reveals its page by expanding a circular clip from an anchor
widget.

<div align=center>
  <img src="https://raw.githubusercontent.com/blaugold/circular_clip_route/master/doc/example-screen-recording.gif" height="500">
</div>

---

If you're looking for a **database solution**, check out
[`cbl`](https://pub.dev/packages/cbl), another project of mine. It brings
Couchbase Lite to **standalone Dart** and **Flutter**, with support for:

- **Full-Text Search**,
- **Expressive Queries**,
- **Data Sync**,
- **Change Notifications**

and more.

---

# Getting started

To use the `CircularClipRoute`, provide it the context from which the animation
should expand and push it onto the navigation stack. One way to get the right
context is to use a `Builder`, which wraps the widget from which the route
should expand:

```dart
final navigationTrigger = Builder(
    builder: (context) {
      return IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(context, CircularClipRoute<void>(
              // This context will be used to determine the location and size of
              // the expanding clip. Here this will resolve to the `IconButton`.
              expandFrom: context,
              builder: (_) => MyRoute(),
            ));
          }
      );
    }
);
```

Also, take a look at the API docs for customizing the animation.

# Example

The [example] implements the demo at the top.

# References

Inspired by
[this shot](https://dribbble.com/shots/12132567-Personal-Challenge-App-Interactions).

This drawing visualizes the geometry involved in creating the route transition:

<div align=center>
  <img src="https://raw.githubusercontent.com/blaugold/circular_clip_route/master/doc/Geometry.svg" width="600" alt="Illustration of the geometry of the transition">
</div>

The
[Anchored Custom Routes](https://medium.com/flutter-community/anchored-custom-routes-b34e36121e65)
article explains how to implement routes, that are anchored to a widget,
generally.

---

**Gabriel Terwesten** &bullet; **GitHub**
**[@blaugold](https://github.com/blaugold)** &bullet; **Twitter**
**[@GTerwesten](https://twitter.com/GTerwesten)** &bullet; **Medium**
**[@gabriel.terwesten](https://medium.com/@gabriel.terwesten)**

[example]:
  https://github.com/blaugold/circular_clip_route/blob/master/example/lib/contact_list_page.dart
