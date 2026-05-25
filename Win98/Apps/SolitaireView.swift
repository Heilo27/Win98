import SwiftUI

// MARK: - Playing Card
struct PlayingCard: Identifiable, Equatable {
    let id: UUID = UUID()
    let rank: Int  // 1=Ace, 11=Jack, 12=Queen, 13=King
    let suit: Suit
    var isFaceUp: Bool = false

    enum Suit: Int, CaseIterable {
        case spades, hearts, diamonds, clubs

        var symbol: String {
            switch self {
            case .spades: return "♠"
            case .hearts: return "♥"
            case .diamonds: return "♦"
            case .clubs: return "♣"
            }
        }
        var isRed: Bool { self == .hearts || self == .diamonds }
    }

    var rankString: String {
        switch rank {
        case 1: return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "\(rank)"
        }
    }

    var color: Color { suit.isRed ? Color.red : Color.black }
    var displayString: String { rankString + suit.symbol }

    static func == (lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Solitaire Game
class SolitaireGame: ObservableObject {
    @Published var tableau: [[PlayingCard]] = Array(repeating: [], count: 7)
    @Published var foundations: [[PlayingCard]] = Array(repeating: [], count: 4)
    @Published var stock: [PlayingCard] = []
    @Published var waste: [PlayingCard] = []
    @Published var won: Bool = false
    @Published var score: Int = 0
    @Published var winAnimationCards: [(PlayingCard, CGPoint, CGSize)] = []
    @Published var isAnimatingWin: Bool = false

    init() { newGame() }

    func newGame() {
        won = false
        isAnimatingWin = false
        winAnimationCards = []
        score = 0
        var deck = [PlayingCard]()
        for suit in PlayingCard.Suit.allCases {
            for rank in 1...13 {
                deck.append(PlayingCard(rank: rank, suit: suit))
            }
        }
        deck.shuffle()

        tableau = Array(repeating: [], count: 7)
        foundations = Array(repeating: [], count: 4)
        stock = []
        waste = []

        var idx = 0
        for col in 0..<7 {
            for row in 0...col {
                var card = deck[idx]
                card.isFaceUp = (row == col)
                tableau[col].append(card)
                idx += 1
            }
        }
        stock = Array(deck[idx...]).map { var c = $0; c.isFaceUp = false; return c }
    }

    func drawFromStock() {
        if stock.isEmpty {
            // Recycle waste back to stock
            stock = waste.reversed().map { var c = $0; c.isFaceUp = false; return c }
            waste = []
        } else {
            var card = stock.removeLast()
            card.isFaceUp = true
            waste.append(card)
        }
    }

    // Try to move top of waste to foundation or tableau
    func autoMoveWaste() {
        guard !waste.isEmpty else { return }
        let card = waste.last!
        if tryMoveToFoundation(card: card, from: .waste, fromIndex: 0) { return }
        for col in 0..<7 {
            if tryMoveToTableau(card: card, from: .waste, fromIndex: 0, toCol: col) { return }
        }
    }

    enum CardSource { case waste, tableau(Int), foundation(Int) }

    func tryMoveToFoundation(card: PlayingCard, from: CardSource, fromIndex: Int) -> Bool {
        for i in 0..<4 {
            if canPlaceOnFoundation(card, pile: i) {
                foundations[i].append(card)
                removeCard(card, from: from)
                score += 10
                checkWin()
                return true
            }
        }
        return false
    }

    func tryMoveToTableau(card: PlayingCard, from: CardSource, fromIndex: Int, toCol: Int) -> Bool {
        if canPlaceOnTableau(card, col: toCol) {
            tableau[toCol].append(card)
            removeCard(card, from: from)
            return true
        }
        return false
    }

    func moveCards(_ cards: [PlayingCard], fromCol: Int, toCol: Int) -> Bool {
        guard let firstCard = cards.first else { return false }
        guard canPlaceOnTableau(firstCard, col: toCol) else { return false }
        tableau[toCol].append(contentsOf: cards)
        tableau[fromCol].removeLast(cards.count)
        flipTopCard(col: fromCol)
        return true
    }

    func moveWasteToTableau(toCol: Int) -> Bool {
        guard !waste.isEmpty else { return false }
        let card = waste.last!
        guard canPlaceOnTableau(card, col: toCol) else { return false }
        tableau[toCol].append(card)
        waste.removeLast()
        return true
    }

    func moveWasteToFoundation() -> Bool {
        guard !waste.isEmpty else { return false }
        let card = waste.last!
        for i in 0..<4 {
            if canPlaceOnFoundation(card, pile: i) {
                foundations[i].append(card)
                waste.removeLast()
                score += 10
                checkWin()
                return true
            }
        }
        return false
    }

    func moveTableauToFoundation(col: Int) -> Bool {
        guard !tableau[col].isEmpty, let card = tableau[col].last, card.isFaceUp else { return false }
        for i in 0..<4 {
            if canPlaceOnFoundation(card, pile: i) {
                foundations[i].append(card)
                tableau[col].removeLast()
                flipTopCard(col: col)
                score += 10
                checkWin()
                return true
            }
        }
        return false
    }

    private func canPlaceOnFoundation(_ card: PlayingCard, pile: Int) -> Bool {
        let f = foundations[pile]
        if f.isEmpty { return card.rank == 1 }
        guard let top = f.last else { return false }
        return top.suit == card.suit && top.rank + 1 == card.rank
    }

    private func canPlaceOnTableau(_ card: PlayingCard, col: Int) -> Bool {
        let t = tableau[col]
        if t.isEmpty { return card.rank == 13 }
        guard let top = t.last, top.isFaceUp else { return false }
        return top.suit.isRed != card.suit.isRed && top.rank - 1 == card.rank
    }

    private func removeCard(_ card: PlayingCard, from: CardSource) {
        switch from {
        case .waste:
            waste.removeAll { $0.id == card.id }
        case .tableau(let col):
            tableau[col].removeAll { $0.id == card.id }
            flipTopCard(col: col)
        case .foundation(let pile):
            foundations[pile].removeAll { $0.id == card.id }
        }
    }

    private func flipTopCard(col: Int) {
        guard !tableau[col].isEmpty else { return }
        let lastIdx = tableau[col].count - 1
        if !tableau[col][lastIdx].isFaceUp {
            tableau[col][lastIdx].isFaceUp = true
            score += 5
        }
    }

    private func checkWin() {
        let total = foundations.reduce(0) { $0 + $1.count }
        if total == 52 {
            won = true
            isAnimatingWin = true
        }
    }
}

// MARK: - Solitaire View
struct SolitaireView: View {
    @StateObject private var game = SolitaireGame()
    @State private var draggedCards: [PlayingCard] = []
    @State private var dragSource: DragSource? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartPosition: CGPoint = .zero
    @State private var winBalls: [WinBall] = []
    @State private var winTimer: Timer? = nil

    enum DragSource {
        case waste
        case tableau(Int, Int) // col, startIndex
    }

    var body: some View {
        ZStack {
            Win98Color.greenFelt

            VStack(spacing: 8) {
                // Top row: stock, waste, spacers, 4 foundations
                HStack(alignment: .top, spacing: 6) {
                    // Stock
                    CardPileView(isEmpty: game.stock.isEmpty, faceDown: true)
                        .onTapGesture { game.drawFromStock() }

                    // Waste
                    ZStack {
                        CardSlotView()
                        if !game.waste.isEmpty {
                            CardView(card: game.waste.last!, small: false)
                                .onTapGesture(count: 2) { _ = game.moveWasteToFoundation() }
                                .gesture(
                                    DragGesture()
                                        .onChanged { val in
                                            if draggedCards.isEmpty {
                                                draggedCards = [game.waste.last!]
                                                dragSource = .waste
                                                dragStartPosition = CGPoint(x: val.startLocation.x, y: val.startLocation.y)
                                            }
                                            dragOffset = val.translation
                                        }
                                        .onEnded { val in
                                            handleDrop(at: val.predictedEndLocation)
                                            draggedCards = []
                                            dragSource = nil
                                            dragOffset = .zero
                                        }
                                )
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)

                    Spacer()

                    // Foundations
                    ForEach(0..<4, id: \.self) { i in
                        ZStack {
                            CardSlotView(suit: foundationSuit(i))
                            if let top = game.foundations[i].last {
                                CardView(card: top, small: false)
                            }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal, 8)

                // Tableau
                HStack(alignment: .top, spacing: 6) {
                    ForEach(0..<7, id: \.self) { col in
                        TableauColumn(
                            cards: game.tableau[col],
                            col: col,
                            game: game,
                            draggedCards: $draggedCards,
                            dragSource: $dragSource,
                            dragOffset: $dragOffset
                        )
                        .frame(width: cardWidth)
                    }
                }
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(.top, 8)

            // Dragged cards overlay
            if !draggedCards.isEmpty {
                VStack(spacing: -50) {
                    ForEach(draggedCards) { card in
                        CardView(card: card, small: false)
                            .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .offset(dragOffset)
                .position(dragStartPosition)
                .allowsHitTesting(false)
            }

            // Win animation
            if game.isAnimatingWin {
                ForEach(winBalls) { ball in
                    CardView(card: ball.card, small: true)
                        .frame(width: 30, height: 42)
                        .position(ball.position)
                }
                VStack {
                    Text("You Win!")
                        .font(.custom("Menlo", size: 28).weight(.bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                    Win98Button(title: "Play Again") {
                        stopWinAnimation()
                        game.newGame()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: game.isAnimatingWin) { _, newVal in
            if newVal { startWinAnimation() }
        }
    }

    var cardWidth: CGFloat { 60 }
    var cardHeight: CGFloat { 84 }

    func foundationSuit(_ i: Int) -> PlayingCard.Suit {
        PlayingCard.Suit.allCases[i]
    }

    func handleDrop(at location: CGPoint) {
        // Simplified drop detection - try to move to any tableau or foundation
        guard let source = dragSource, !draggedCards.isEmpty else { return }

        switch source {
        case .waste:
            _ = game.moveWasteToFoundation() || {
                for col in 0..<7 { if game.moveWasteToTableau(toCol: col) { return true } }
                return false
            }()
        case .tableau(let fromCol, let startIdx):
            // Try to find target column from location
            let headerHeight: CGFloat = 100
            let padding: CGFloat = 8
            let spacing: CGFloat = 6
            for toCol in 0..<7 {
                let colX = padding + CGFloat(toCol) * (cardWidth + spacing) + cardWidth / 2
                if abs(location.x - colX) < cardWidth / 2 {
                    let cardsToMove = Array(game.tableau[fromCol].suffix(from: startIdx))
                    if !cardsToMove.isEmpty {
                        _ = game.moveCards(cardsToMove, fromCol: fromCol, toCol: toCol)
                    }
                    return
                }
            }
            // Try foundation
            if draggedCards.count == 1 {
                _ = game.moveTableauToFoundation(col: fromCol)
            }
        }
    }

    // MARK: - Win Animation
    struct WinBall: Identifiable {
        let id = UUID()
        var card: PlayingCard
        var position: CGPoint
        var velocity: CGSize
    }

    func startWinAnimation() {
        // Create bouncing cards
        winBalls = game.foundations.flatMap { $0 }.prefix(20).map { card in
            WinBall(
                card: card,
                position: CGPoint(x: CGFloat.random(in: 50...550), y: CGFloat.random(in: 50...200)),
                velocity: CGSize(
                    width: CGFloat.random(in: -6...6),
                    height: CGFloat.random(in: -8 ... -3)
                )
            )
        }
        winTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [self] _ in
            DispatchQueue.main.async {
                updateWinAnimation()
            }
        }
    }

    func updateWinAnimation() {
        for i in winBalls.indices {
            winBalls[i].position.x += winBalls[i].velocity.width
            winBalls[i].position.y += winBalls[i].velocity.height
            winBalls[i].velocity.height += 0.4 // gravity

            // Bounce off edges
            if winBalls[i].position.x < 15 || winBalls[i].position.x > 625 {
                winBalls[i].velocity.width *= -1
            }
            if winBalls[i].position.y > 400 {
                winBalls[i].velocity.height *= -0.8
                winBalls[i].position.y = 400
            }
            if winBalls[i].position.y < 0 {
                winBalls[i].velocity.height *= -1
                winBalls[i].position.y = 0
            }
        }
    }

    func stopWinAnimation() {
        winTimer?.invalidate()
        winTimer = nil
        winBalls = []
    }
}

// MARK: - Tableau Column
struct TableauColumn: View {
    let cards: [PlayingCard]
    let col: Int
    @ObservedObject var game: SolitaireGame
    @Binding var draggedCards: [PlayingCard]
    @Binding var dragSource: SolitaireView.DragSource?
    @Binding var dragOffset: CGSize

    var body: some View {
        ZStack(alignment: .top) {
            CardSlotView()
                .frame(width: 60, height: 84)

            VStack(spacing: 0) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { idx, card in
                    if card.isFaceUp {
                        CardView(card: card, small: false)
                            .frame(width: 60, height: idx == cards.count - 1 ? 84 : 20)
                            .zIndex(Double(idx))
                            .onTapGesture(count: 2) {
                                _ = game.moveTableauToFoundation(col: col)
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged { val in
                                        if draggedCards.isEmpty {
                                            let cardsToMove = Array(cards.suffix(from: idx))
                                            draggedCards = cardsToMove
                                            dragSource = .tableau(col, idx)
                                        }
                                        dragOffset = val.translation
                                    }
                                    .onEnded { _ in
                                        draggedCards = []
                                        dragSource = nil
                                        dragOffset = .zero
                                    }
                            )
                    } else {
                        FaceDownCardView()
                            .frame(width: 60, height: idx == cards.count - 1 ? 84 : 16)
                            .zIndex(Double(idx))
                    }
                }
            }
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: PlayingCard
    var small: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.white)
                .win98Raised()
            VStack(alignment: .leading, spacing: 0) {
                Text(card.rankString)
                    .font(Font.custom("Menlo", size: small ? 8 : 11).weight(.bold))
                    .foregroundColor(card.color)
                Text(card.suit.symbol)
                    .font(Font.system(size: small ? 8 : 10))
                    .foregroundColor(card.color)
            }
            .padding(.top, 2)
            .padding(.leading, 2)
        }
    }
}

// MARK: - Face Down Card
struct FaceDownCardView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#0000AA"))
                .win98Raised()
            Canvas { ctx, size in
                let step: CGFloat = 6
                for x in stride(from: 0, to: size.width, by: step) {
                    for y in stride(from: 0, to: size.height, by: step) {
                        let rect = CGRect(x: x, y: y, width: step/2, height: step/2)
                        ctx.fill(Path(rect), with: .color(Color(hex: "#4444CC")))
                    }
                }
            }
        }
    }
}

// MARK: - Card Slot View
struct CardSlotView: View {
    var suit: PlayingCard.Suit? = nil

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#006600"))
                .win98Sunken()
            if let suit = suit {
                Text(suit.symbol)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#009900"))
            }
        }
        .frame(width: 60, height: 84)
    }
}

// MARK: - Card Pile View (Stock)
struct CardPileView: View {
    let isEmpty: Bool
    let faceDown: Bool

    var body: some View {
        ZStack {
            if isEmpty {
                CardSlotView()
                Text("↺")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#009900"))
            } else {
                FaceDownCardView()
            }
        }
        .frame(width: 60, height: 84)
    }
}
