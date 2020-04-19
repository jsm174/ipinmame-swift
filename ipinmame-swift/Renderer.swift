//
//  Renderer.swift
//  ipinmame-swift
//
//  Created by Jason Millard on 3/23/20.
//  Copyright © 2020 Jason Millard. All rights reserved.
//

import UIKit
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    struct Vertex {
         var position: float3
         var color: float4
         var textureCoordinate: float2
     }
    
    struct Material {
        var color = float4(0.8, 0.8, 0.8, 1.0)
        var useMaterialColor: Bool = false
        var useTexture: Bool = false
    }
     
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    var vertices: [Vertex]!
      
    let device: MTLDevice
    let mtkView: MTKView
    var texture: MTLTexture?
    var vertexBuffer: MTLBuffer!
    var viewportSize: vector_uint2 = vector_uint2()
    var samplerState: MTLSamplerState!
    
    init(view: MTKView) {        
        vertices = [
            Vertex(position: float3( 1, 1,0), color: float4(1,0,0,1), textureCoordinate: float2(1,0)), //Top Right
            Vertex(position: float3(-1, 1,0), color: float4(0,1,0,1), textureCoordinate: float2(0,0)), //Top Left
            Vertex(position: float3(-1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(0,1)), //Bottom Left
                 
            Vertex(position: float3( 1, 1,0), color: float4(1,0,0,1), textureCoordinate: float2(1,0)), //Top Right
            Vertex(position: float3(-1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(0,1)), //Bottom Left
            Vertex(position: float3( 1,-1,0), color: float4(1,0,1,1), textureCoordinate: float2(1,1)), //Bottom Right
        ]
        
        mtkView = view
        device = mtkView.device!
        
        super.init()
             
        commandQueue = device.makeCommandQueue()
        
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [.storageModeShared])
        
       createRenderPipelineState()
    }
    
    func createRenderPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "basic_vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_shader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        //Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        //Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.size
        
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.size + MemoryLayout<float4>.size
        
        vertexDescriptor.layouts[0].stride =  MemoryLayout<Vertex>.stride
            
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
        
        do{
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }catch let error as NSError{
            print(error)
        }
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.setRenderPipelineState(renderPipelineState)

        
        renderCommandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        var material = Material()
        
        if texture != nil {
            material.useTexture = true
        }
         
        renderCommandEncoder?.setFragmentBytes(&material,
                                               length: MemoryLayout<Material>.stride,
                                               index: 1)
        
        renderCommandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        renderCommandEncoder?.setFragmentTexture(texture, index: 0)
        
        renderCommandEncoder?.drawPrimitives(type: .triangle,
                                             vertexStart: 0,
                                             vertexCount: vertices.count)
            
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}
