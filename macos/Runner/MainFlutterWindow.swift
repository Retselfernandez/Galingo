import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Escritorio: abrir cun tamaño que active o layout ancho (>= 1024) e
    // impedir que se poida reducir por debaixo.
    self.minSize = NSSize(width: 1024, height: 700)
    var windowFrame = self.frame
    windowFrame.size = NSSize(width: 1280, height: 820)
    self.setFrame(windowFrame, display: true)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
