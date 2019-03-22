import Foundation
import ScreenSaver

class Main: ScreenSaverView {
    var currQuote: Quote?
    
    let THEME_MODE = "DARK"
    
    let COLOUR = [
        "LIGHT": [
            "BACKGROUND": NSColor(red:1.00,green:0.97,blue:0.89,alpha:1.00),
            "QUOTE": NSColor(red:0.58,green:0.59,blue:0.62,alpha:1.00),
            "METADATA": NSColor(red:0.31,green:0.31,blue:0.33,alpha:1.00)
        ],
        "DARK": [
            "BACKGROUND": NSColor(red:0.31,green:0.31,blue:0.33,alpha:1.00),
            "QUOTE": NSColor(red:0.94,green:0.95,blue:0.94,alpha:1.00),
            "METADATA": NSColor(red:1.00,green:1.00,blue:1.00,alpha:1.00)
        ]
    ]
    
    let FONT_QUOTE = NSFont(name: "Baskerville", size: 48)
    let FONT_METADATA = NSFont(name: "Baskerville-BoldItalic", size: 24)
    
    let WISDOM_API = URL(string: "http://ron-swanson-quotes.herokuapp.com/v2/quotes")
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        // Only update the frame every 10 seconds.
        animationTimeInterval = 10
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    /**
     Loads wizdom from the excellent http://ron-swanson-quotes.herokuapp.com API.
     */
    func loadQuote() {
        
        let task = URLSession.shared.dataTask(with: WISDOM_API!) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String]
            let wisdom = json?[0]
            self.currQuote = Quote(subquote: "", quote: wisdom!, author: "Ron Swanson")
        }
        
        task.resume()
    }
    
    /**
     animateOneFrame is called every time the screen saver frame is to be updated, and
     is used to pull the appropriate quote.
     */
    override func animateOneFrame() {
        loadQuote()
        
        // Tell Swift we want to use the draw(_:) method to handle rendering.
        self.setNeedsDisplay(self.frame)
    }
    
    /**
     getTime returns the current time as a formatted string.
     
     - Returns: A new string showing the current time, formatted as HH:mm
     */
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: date)
    }
    
    /**
     drawQuote draws the provided quote to the stage.
     
     - Parameter quote: The quote to draw onto the stage.
     - Parameter subquote: The subquote to highlight.
     */
    func drawQuote(_ quote: String, subquote: String) {
        
        let styledQuote = NSMutableAttributedString(string: quote)
        styledQuote.addAttribute(NSForegroundColorAttributeName, value: COLOUR[self.THEME_MODE]!["QUOTE"]!, range: NSMakeRange(0, styledQuote.length))
        styledQuote.addAttribute(NSFontAttributeName, value: FONT_QUOTE, range: NSMakeRange(0, quote.count))
        
        let QUOTE_PADDING_LEFT = 100;
        let QUOTE_PADDING_RIGHT = 100;
        let QUOTE_PADDING_TOP = 100;
        
        // Where frame.size is the resolution of the current screen (works for multi-monitor display)
        let QUOTE_BOX_WIDTH = Int(frame.size.width) - (QUOTE_PADDING_LEFT + QUOTE_PADDING_RIGHT);
        let QUOTE_BOX_HEIGHT = Int(frame.size.height) - QUOTE_PADDING_TOP;
        
        styledQuote.draw(in: CGRect(x: QUOTE_PADDING_LEFT, y: 0, width: QUOTE_BOX_WIDTH, height: QUOTE_BOX_HEIGHT))
    }
    
    /**
     drawMetadata draws the provided title and author onto the stage.
     
     - Parameter title: The title of the book.
     - Parameter author: The author of the book.
     */
    func drawMetadata(author: String) {
        let styledMetadata = NSMutableAttributedString(string: "— \(author)")
        styledMetadata.addAttribute(NSForegroundColorAttributeName, value: COLOUR[self.THEME_MODE]!["METADATA"]!, range: NSMakeRange(0, styledMetadata.length))
        styledMetadata.addAttribute(NSFontAttributeName, value: FONT_METADATA, range: NSMakeRange(0, styledMetadata.length))
        
        styledMetadata.draw(in: CGRect(x: 100.0, y: 50, width: 1400, height: 50))
    }
    
    /**
     clearStage clears the stage, by filling it with a solid colour.
     */
    func clearStage() {
        COLOUR[self.THEME_MODE]!["BACKGROUND"]!.setFill()
        NSRectFill(self.bounds)
    }
    
    /**
     draw is called each time the screensaver should be re-rendered.
     */
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        // Provide a default quote if one was not pulled for the current time.
        let quote = self.currQuote ?? Quote(subquote: "", quote: "When I eat, it is the food that is scared.", author: "Ron Swanson")
        
        clearStage()
        drawQuote(quote.quote, subquote: quote.subquote)
        drawMetadata(author: quote.author)
    }
}
