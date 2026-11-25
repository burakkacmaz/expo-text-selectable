# expo-text-selectable

Read-only text with native selection handles on iOS. Inline spans share a single selection range, so a copy operation can cross formatting boundaries. Android uses React Native's selectable text.

![Dragging iOS selection handles across a plain sentence and across both styled spans.](https://raw.githubusercontent.com/burakkacmaz/expo-text-selectable/main/docs/ios-selection.gif?v=2)

## Installation

```sh
npm install expo-text-selectable
```

The custom iOS selection view requires a native build that includes the module. Rebuild your app after installing it. A development build or a production build works. Expo Go on iOS and Android use React Native's selectable text.

## Usage

```tsx
import { SelectableText } from "expo-text-selectable";
import { StyleSheet, View } from "react-native";

export default function SelectionExample() {
  return (
    <View style={styles.screen}>
      <View style={styles.examples}>
        <SelectableText style={styles.text}>
          Press and hold this text to select it.
        </SelectableText>
        <SelectableText style={styles.text}>
          <SelectableText.Span style={styles.accent}>Pickup</SelectableText.Span>
          {" at the hotel lobby at "}
          <SelectableText.Span style={styles.accent}>9:30</SelectableText.Span>
          {"."}
        </SelectableText>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 24,
    backgroundColor: "#fff",
  },
  examples: { width: "100%", maxWidth: 360, gap: 16 },
  text: { textAlign: "center", fontSize: 17, lineHeight: 25, color: "#202328" },
  accent: { fontWeight: "700", color: "#244b9d" },
});
```

Plain strings, numbers, fragments, and nested spans are supported. Inline styling covers color, font family, font size, font weight, and letter spacing. The root also supports line height, alignment, writing direction, line limits, and font scaling. Custom fonts are loaded by the host application.

On iOS, tap outside the text to clear the selection.

Arbitrary React elements inside the text use the React Native fallback.

## Expo SDK compatibility

Selection was verified on iOS and Android with Expo SDK 52, 53, 55, and 58. Version `0.1.1` declares Expo SDK 58 and React Native 0.88 in its npm peer dependencies. The older SDK checks used `--legacy-peer-deps` in separate test projects. The native iOS module requires iOS 16.4 or later.

## License

MIT
