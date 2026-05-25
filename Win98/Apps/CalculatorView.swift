import SwiftUI

// MARK: - Calculator
struct CalculatorView: View {
    @State private var displayText: String = "0"
    @State private var firstOperand: Double? = nil
    @State private var currentOperator: String? = nil
    @State private var waitingForSecond: Bool = false
    @State private var memory: Double = 0
    @State private var hasMemory: Bool = false
    @State private var justCalculated: Bool = false
    @State private var isError: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            // Display
            HStack {
                Spacer()
                Text(displayText)
                    .font(Font.custom("Menlo", size: 20).weight(.regular))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(Color.black)
            .win98Well()
            .padding(.horizontal, 4)
            .padding(.top, 6)

            // Memory indicator
            HStack {
                Text(hasMemory ? "M" : " ")
                    .font(Win98Font.small)
                    .foregroundColor(Win98Color.darkText)
                    .frame(width: 16)
                    .padding(.leading, 4)
                Spacer()
            }
            .frame(height: 14)

            // Buttons
            VStack(spacing: 3) {
                // Row 1: Backspace, CE, C
                HStack(spacing: 3) {
                    calcButton("Backspace", color: Win98Color.buttonFace, wide: true) { backspace() }
                    calcButton("CE", color: Win98Color.buttonFace) { displayText = "0" }
                    calcButton("C", color: Win98Color.buttonFace) { clearAll() }
                }

                // Row 2: MC, 7, 8, 9, /, sqrt
                HStack(spacing: 3) {
                    calcButton("MC", color: Win98Color.buttonFace) { memory = 0; hasMemory = false }
                    calcButton("7") { appendDigit("7") }
                    calcButton("8") { appendDigit("8") }
                    calcButton("9") { appendDigit("9") }
                    calcButton("/", color: Color(hex: "#C8C8C8")) { setOperator("/") }
                    calcButton("sqrt", color: Color(hex: "#C8C8C8")) { computeSqrt() }
                }

                // Row 3: MR, 4, 5, 6, *, %
                HStack(spacing: 3) {
                    calcButton("MR", color: Win98Color.buttonFace) { recallMemory() }
                    calcButton("4") { appendDigit("4") }
                    calcButton("5") { appendDigit("5") }
                    calcButton("6") { appendDigit("6") }
                    calcButton("*", color: Color(hex: "#C8C8C8")) { setOperator("*") }
                    calcButton("%", color: Color(hex: "#C8C8C8")) { computePercent() }
                }

                // Row 4: MS, 1, 2, 3, -, 1/x
                HStack(spacing: 3) {
                    calcButton("MS", color: Win98Color.buttonFace) { storeMemory() }
                    calcButton("1") { appendDigit("1") }
                    calcButton("2") { appendDigit("2") }
                    calcButton("3") { appendDigit("3") }
                    calcButton("-", color: Color(hex: "#C8C8C8")) { setOperator("-") }
                    calcButton("1/x", color: Color(hex: "#C8C8C8")) { computeReciprocal() }
                }

                // Row 5: M+, 0, +/-, ., +, =
                HStack(spacing: 3) {
                    calcButton("M+", color: Win98Color.buttonFace) { addToMemory() }
                    calcButton("0") { appendDigit("0") }
                    calcButton("+/-") { toggleSign() }
                    calcButton(".") { appendDecimal() }
                    calcButton("+", color: Color(hex: "#C8C8C8")) { setOperator("+") }
                    calcButton("=", color: Color(hex: "#C8C8C8")) { compute() }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .background(Win98Color.buttonFace)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    func calcButton(_ label: String, color: Color = Win98Color.buttonFace, wide: Bool = false, action: @escaping () -> Void) -> some View {
        CalcButton(label: label, color: color, wide: wide, action: action)
    }

    // MARK: - Calculator Logic
    private func appendDigit(_ d: String) {
        if isError { clearAll(); isError = false }
        if waitingForSecond || justCalculated {
            displayText = d
            waitingForSecond = false
            justCalculated = false
        } else {
            if displayText == "0" {
                displayText = d
            } else if displayText.count < 14 {
                displayText += d
            }
        }
    }

    private func appendDecimal() {
        if isError { clearAll(); isError = false }
        if waitingForSecond || justCalculated {
            displayText = "0."
            waitingForSecond = false
            justCalculated = false
        } else if !displayText.contains(".") {
            displayText += "."
        }
    }

    private func backspace() {
        if isError { clearAll(); isError = false; return }
        let result = String(displayText.dropLast())
        if result.isEmpty || result == "-" || result == "." {
            displayText = "0"
        } else {
            displayText = result
        }
    }

    private func clearAll() {
        displayText = "0"
        firstOperand = nil
        currentOperator = nil
        waitingForSecond = false
        justCalculated = false
        isError = false
    }

    private func setOperator(_ op: String) {
        if isError { clearAll(); isError = false }
        if !waitingForSecond {
            if firstOperand != nil && !justCalculated {
                compute()
                // firstOperand is already set to the result inside compute()
            } else {
                firstOperand = Double(displayText)
            }
        }
        currentOperator = op
        waitingForSecond = true
        justCalculated = false
    }

    private func compute() {
        guard let op = currentOperator, let first = firstOperand else {
            justCalculated = true
            return
        }
        let second = Double(displayText) ?? 0
        var result: Double
        switch op {
        case "+": result = first + second
        case "-": result = first - second
        case "*": result = first * second
        case "/":
            if second == 0 {
                displayText = "Cannot divide by zero"
                firstOperand = nil
                currentOperator = nil
                waitingForSecond = false
                justCalculated = true
                return
            }
            result = first / second
        default: result = second
        }
        displayText = formatResult(result)
        firstOperand = result
        currentOperator = nil
        waitingForSecond = false
        justCalculated = true
    }

    private func computeSqrt() {
        if isError { clearAll(); isError = false }
        guard let val = Double(displayText), val >= 0 else {
            displayText = "Invalid input for function"
            isError = true
            return
        }
        displayText = formatResult(sqrt(val))
        justCalculated = true
    }

    private func computePercent() {
        if isError { clearAll(); isError = false }
        guard let val = Double(displayText) else { return }
        if let first = firstOperand {
            displayText = formatResult(first * val / 100)
        } else {
            displayText = formatResult(val / 100)
        }
        justCalculated = true
    }

    private func computeReciprocal() {
        if isError { clearAll(); isError = false }
        guard let val = Double(displayText), val != 0 else {
            displayText = "Cannot divide by zero"
            isError = true
            return
        }
        displayText = formatResult(1 / val)
        justCalculated = true
    }

    private func toggleSign() {
        if isError { clearAll(); isError = false; return }
        if let val = Double(displayText) {
            displayText = formatResult(-val)
        }
    }

    private func storeMemory() {
        memory = Double(displayText) ?? 0
        hasMemory = true
    }

    private func recallMemory() {
        displayText = formatResult(memory)
    }

    private func addToMemory() {
        memory += Double(displayText) ?? 0
        hasMemory = memory != 0
    }

    private func formatResult(_ val: Double) -> String {
        if !val.isInfinite && !val.isNaN, let intVal = Int(exactly: val.rounded()) {
            return String(intVal)
        } else if !val.isInfinite && !val.isNaN && val == val.rounded() && abs(val) < 9.007199254741e15 {
            return String(Int(val))
        }
        let s = String(format: "%.10g", val)
        return s.count > 14 ? String(format: "%.6e", val) : s
    }
}

// MARK: - Calculator Button
struct CalcButton: View {
    let label: String
    let color: Color
    let wide: Bool
    let action: () -> Void
    @State private var isPressed: Bool = false

    init(label: String, color: Color = Win98Color.buttonFace, wide: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.color = color
        self.wide = wide
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Win98Font.ui)
                .foregroundColor(Win98Color.darkText)
                .frame(maxWidth: wide ? .infinity : nil)
                .frame(width: wide ? nil : 38, height: 24)
                .background(color)
                .modifier(BevelModifier(style: isPressed ? .sunken : .raised))
                .padding(isPressed ? EdgeInsets(top: 1, leading: 1, bottom: 0, trailing: 0) : EdgeInsets())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
