//
//  ViewController.swift
//  MetalCN
//
//  Created by 焦国辉 on 2022/2/19.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mtkView = MTKView(frame: self.view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice()
        renderer = Renderer(with: mtkView)
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
        
        self.view = mtkView
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

