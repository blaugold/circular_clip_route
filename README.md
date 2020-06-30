# circular_clip_route

<a href="https://pub.dev/packages/circular_clip_route">
    <img src="https://badgen.net/pub/v/circular_clip_route">
</a>

A Flutter package which provides a page route which reveals its page by expanding a circular clip.

<img src="https://raw.githubusercontent.com/blaugold/circular_clip_route/master/doc/example-screen-recording.gif" height="600">

This drawing visualises the geometry involved in creating the route transition.

<img src="https://raw.githubusercontent.com/blaugold/circular_clip_route/master/doc/Geometry.svg" width="600" alt="Illustration of the geometry of the transition">


## Usage

The [example app] shows an example of how to use the package.

### `CircularClipRoute`

```dart
final navigationTrigger = Builder(
    builder: (context) {
      return IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(context, CircularClipRoute<void>(
              builder: (_) => MyRoute(),
              // This context will be used to determine the location and size of
              // the expanding clip. Here this will resolve to the `IconButton`.
              expandFrom: context,
            ));
          }
      );
    }
);
```

## References

Inspired by [this shot](https://dribbble.com/shots/12132567-Personal-Challenge-App-Interactions).

## License

Licensed under the MIT license.

[example app]: https://github.com/blaugold/circular_clip_route/blob/master/example/lib/contact_list_page.dart
