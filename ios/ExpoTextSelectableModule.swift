import ExpoModulesCore
import UIKit

struct SelectableTextRun: Record {
  @Field var text: String = ""
  @Field var fontFamily: String? = nil
  @Field var fontWeight: String? = nil
  @Field var fontSize: Double? = nil
  @Field var letterSpacing: Double? = nil
  @Field var color: UIColor? = nil
}

struct SelectableTextContent: Record {
  @Field var runs: [SelectableTextRun]? = nil
  @Field var text: String = ""
  @Field var fontFamily: String = ""
  @Field var fontSize: Double = 14
  @Field var lineHeight: Double? = nil
  @Field var letterSpacing: Double? = nil
  @Field var color: UIColor? = nil
  @Field var alignment: String = "auto"
  @Field var writingDirection: String = "auto"
  @Field var numberOfLines: Int = 0
  @Field var ellipsizeMode: String = "tail"
}

final class ExpoTextSelectableView: ExpoView {
  private let textView = UITextView(usingTextLayoutManager: false)

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    addSubview(textView)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    textView.frame = bounds
  }

  private func resolveFont(_ family: String, size: CGFloat) -> UIFont {
    let fontName = UIFont.fontNames(forFamilyName: family).first ?? family
    return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
  }

  private func resolveRunFont(_ run: SelectableTextRun, content: SelectableTextContent) -> UIFont {
    let family = run.fontFamily ?? content.fontFamily
    let size = CGFloat(run.fontSize ?? content.fontSize)
    let font = resolveFont(family, size: size)
    guard let fontWeight = run.fontWeight else { return font }

    let weights: [String: UIFont.Weight] = [
      "100": .ultraLight, "200": .thin, "300": .light, "400": .regular,
      "500": .medium, "600": .semibold, "700": .bold, "800": .heavy,
      "900": .black, "normal": .regular, "bold": .bold
    ]
    guard let weight = weights[fontWeight] else { return font }
    if family.isEmpty { return .systemFont(ofSize: size, weight: weight) }

    let descriptor = UIFontDescriptor(fontAttributes: [
      .family: font.familyName,
      .traits: [UIFontDescriptor.TraitKey.weight: weight]
    ])
    return UIFont(descriptor: descriptor, size: size)
  }

  func setContent(_ content: SelectableTextContent) {
    let font = resolveFont(content.fontFamily, size: content.fontSize)
    let paragraph = NSMutableParagraphStyle()

    switch content.alignment {
    case "left": paragraph.alignment = .left
    case "right": paragraph.alignment = .right
    case "center": paragraph.alignment = .center
    case "justify": paragraph.alignment = .justified
    default: paragraph.alignment = .natural
    }

    switch content.writingDirection {
    case "ltr": paragraph.baseWritingDirection = .leftToRight
    case "rtl": paragraph.baseWritingDirection = .rightToLeft
    default: paragraph.baseWritingDirection = .natural
    }

    var attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: content.color ?? UIColor.label,
      .paragraphStyle: paragraph
    ]
    if let lineHeight = content.lineHeight {
      paragraph.minimumLineHeight = lineHeight
      paragraph.maximumLineHeight = lineHeight
      attributes[.baselineOffset] = (CGFloat(lineHeight) - font.lineHeight) / 2
    }
    if let letterSpacing = content.letterSpacing {
      attributes[.kern] = letterSpacing
    }

    textView.textContainer.maximumNumberOfLines = max(0, content.numberOfLines)
    switch (content.numberOfLines, content.ellipsizeMode) {
    case (0, _): textView.textContainer.lineBreakMode = .byWordWrapping
    case (_, "head"): textView.textContainer.lineBreakMode = .byTruncatingHead
    case (_, "middle"): textView.textContainer.lineBreakMode = .byTruncatingMiddle
    case (_, "clip"): textView.textContainer.lineBreakMode = .byClipping
    default: textView.textContainer.lineBreakMode = .byTruncatingTail
    }

    let attributedText = NSMutableAttributedString(string: "")
    if let runs = content.runs {
      let fonts = runs.map { run in
        resolveRunFont(run, content: content)
      }
      if let lineHeight = content.lineHeight, let tallestFont = fonts.map(\.lineHeight).max() {
        attributes[.baselineOffset] = (lineHeight - tallestFont) / 2
      }
      for (run, runFont) in zip(runs, fonts) {
        var runAttributes = attributes
        runAttributes[.font] = runFont
        runAttributes[.foregroundColor] = run.color ?? content.color ?? UIColor.label
        if let spacing = run.letterSpacing {
          runAttributes[.kern] = spacing
        }
        attributedText.append(NSAttributedString(string: run.text, attributes: runAttributes))
      }
    } else {
      attributedText.append(NSAttributedString(string: content.text, attributes: attributes))
    }
    if textView.attributedText != attributedText {
      textView.attributedText = attributedText
    }
  }
}

public final class ExpoTextSelectableModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoTextSelectable")

    View(ExpoTextSelectableView.self) {
      Prop("content") { (view: ExpoTextSelectableView, content: SelectableTextContent) in
        view.setContent(content)
      }
    }
  }
}
