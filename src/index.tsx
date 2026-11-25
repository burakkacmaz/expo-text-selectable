import React, { Children, Fragment, isValidElement } from "react";
import { requireNativeView, requireOptionalNativeModule } from "expo";
import {
  Platform,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
  type StyleProp,
  type TextProps,
  type TextStyle,
  type ViewProps,
  type ViewStyle,
} from "react-native";

type InlineStyle = Pick<TextStyle, "color" | "fontFamily" | "fontSize" | "fontWeight" | "letterSpacing">;

export interface SelectableTextSpanProps {
  children?: React.ReactNode;
  style?: StyleProp<InlineStyle>;
}

type SelectableTextStyle = ViewStyle & InlineStyle & Pick<TextStyle, "lineHeight" | "textAlign" | "writingDirection">;

export type SelectableTextProps = Pick<
  TextProps,
  "accessibilityLabel" | "allowFontScaling" | "ellipsizeMode" | "maxFontSizeMultiplier" | "numberOfLines" | "testID"
> & {
  children?: React.ReactNode;
  style?: StyleProp<SelectableTextStyle>;
};

type Run = InlineStyle & { text: string };

type NativeProps = ViewProps & {
  content: {
    runs: Run[];
    fontSize?: number;
    lineHeight?: number;
    color?: TextStyle["color"];
    alignment?: TextStyle["textAlign"];
    writingDirection?: TextStyle["writingDirection"];
    numberOfLines: number;
    ellipsizeMode?: TextProps["ellipsizeMode"];
  };
};

const moduleName = "ExpoTextSelectable";
const NativeText = Platform.OS === "ios" && requireOptionalNativeModule(moduleName)
  ? requireNativeView<NativeProps>(moduleName)
  : null;

function Span({ children, style }: SelectableTextSpanProps) {
  return <Text style={style}>{children}</Text>;
}

function collectRuns(children: React.ReactNode, style: InlineStyle): Run[] | null {
  const runs: Run[] = [];
  for (const child of Children.toArray(children)) {
    if (typeof child === "string" || typeof child === "number") {
      const text = String(child);
      if (text.length) runs.push({ ...style, text });
      continue;
    }

    if (!isValidElement<SelectableTextSpanProps>(child) ||
        (child.type !== Span && child.type !== Fragment)) {
      return null;
    }

    const nestedStyle = StyleSheet.flatten(child.props.style);
    const nestedRuns = collectRuns(child.props.children, { ...style, ...nestedStyle });
    if (!nestedRuns) return null;
    runs.push(...nestedRuns);
  }
  return runs;
}

function SelectableTextRoot({
  children,
  style,
  accessibilityLabel,
  testID,
  allowFontScaling = true,
  maxFontSizeMultiplier,
  numberOfLines,
  ellipsizeMode = "tail",
}: SelectableTextProps) {
  const { fontScale } = useWindowDimensions();
  const textProps = { allowFontScaling, maxFontSizeMultiplier, numberOfLines, ellipsizeMode };
  const {
    fontFamily,
    fontSize = 14,
    fontWeight,
    letterSpacing,
    color,
    lineHeight,
    textAlign,
    writingDirection,
    ...layoutStyle
  } = StyleSheet.flatten(style) ?? {};
  const runs = NativeText
    ? collectRuns(children, { fontFamily, fontSize, fontWeight, letterSpacing, color })
    : null;

  if (!NativeText || !runs?.length) {
    return (
      <Text {...textProps} style={style} accessibilityLabel={accessibilityLabel} testID={testID} selectable>
        {children}
      </Text>
    );
  }

  const maxScale = maxFontSizeMultiplier && maxFontSizeMultiplier >= 1
    ? Math.min(fontScale, maxFontSizeMultiplier)
    : fontScale;
  const scale = allowFontScaling ? maxScale : 1;
  let offset = 0;

  return (
    <View style={layoutStyle} testID={testID}>
      <View>
        <Text
          {...textProps}
          accessible={false}
          accessibilityElementsHidden
          style={{ fontSize, fontFamily, fontWeight, letterSpacing, lineHeight, textAlign, writingDirection, color: "transparent" }}
        >
          {runs.map(({ text, color: _color, ...runStyle }) => {
            const start = offset;
            offset += text.length;
            return <Text key={start} style={runStyle}>{text}</Text>;
          })}
        </Text>
        <NativeText
          style={StyleSheet.absoluteFill}
          accessibilityLabel={accessibilityLabel}
          content={{
            runs: runs.map((run) => ({
              ...run,
              fontSize: run.fontSize === undefined ? undefined : run.fontSize * scale,
              letterSpacing: run.letterSpacing === undefined ? undefined : run.letterSpacing * scale,
            })),
            fontSize: fontSize * scale,
            lineHeight: lineHeight === undefined ? undefined : lineHeight * scale,
            color,
            alignment: textAlign,
            writingDirection,
            numberOfLines: numberOfLines ?? 0,
            ellipsizeMode,
          }}
        />
      </View>
    </View>
  );
}

export const SelectableText = Object.assign(SelectableTextRoot, { Span });
