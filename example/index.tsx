import React from "react";
import { registerRootComponent } from "expo";
import { StyleSheet, View } from "react-native";
import { SelectableText } from "expo-text-selectable";

function App() {
  return (
    <View style={styles.screen}>
      <SelectableText style={styles.text}>
        Press and hold any word to select part of this sentence.
      </SelectableText>
      <SelectableText style={styles.text}>
        <SelectableText.Span style={{ fontWeight: "600" }}>Pickup</SelectableText.Span>
        {": Meet at the hotel lobby after breakfast. Bring your booking confirmation and wait near the main entrance."}
      </SelectableText>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, justifyContent: "center", padding: 24, gap: 24 },
  text: { fontSize: 17, lineHeight: 25 },
});

registerRootComponent(App);
