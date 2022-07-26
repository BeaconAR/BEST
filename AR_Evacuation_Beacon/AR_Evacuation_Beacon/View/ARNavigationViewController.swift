//
//  ARNavigationViewController.swift
//  AR_Evacuation_Beacon
//
//  Created by Jung peter on 7/10/22.
//

import UIKit
import ARKit
import CoreLocation

final class ARNavigationViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    var map = [[Int]](repeating: [1,1,1,1,1], count: 5)
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var map2Dview: UIView = UIView()
    private var map2DViewController = Map2DViewController()
    private let mapContentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        return scrollView
    }()
    private var arrow = SCNNode()
    private var heading: Double = 360
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initScene()
        self.initARSession()
        set2DNavigationView()
        locationManager.delegate = self
        arrow = generateArrowNode()
        NotificationCenter.default.addObserver(self, selector: #selector(movenotification(_:)), name: .movePosition, object: nil)
        self.sceneView.scene.rootNode.addChildNode(arrow)
    }
    
    @objc func movenotification(_ noti: Notification) {
        mapContentScrollView.scroll(to: map2DViewController.annotationView.currentPoint)
    }
    
    private func set2DNavigationView() {
        view.addSubview(mapContentScrollView)
        mapContentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapContentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapContentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapContentScrollView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.5).isActive = true
        setMap2dViewController()
    }
    
    private func setMap2dViewController() {
        guard let map2dView = map2DViewController.view else {return}
        map2dView.translatesAutoresizingMaskIntoConstraints = false
        self.map2Dview = map2dView
        mapContentScrollView.addSubview(self.map2Dview)
        
        // constraint
        self.map2Dview.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.map2Dview.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        self.map2Dview.leadingAnchor.constraint(equalTo: mapContentScrollView.leadingAnchor).isActive = true
        self.map2Dview.trailingAnchor.constraint(equalTo: mapContentScrollView.trailingAnchor).isActive = true
        self.map2Dview.topAnchor.constraint(equalTo: mapContentScrollView.topAnchor).isActive = true
        self.map2Dview.bottomAnchor.constraint(equalTo: mapContentScrollView.bottomAnchor).isActive = true
    }
    
    private func generateArrowNode() -> SCNNode {
        
        let vertcount = 48;
        let verts: [Float] = [ -1.4923, 1.1824, 2.5000, -6.4923, 0.000, 0.000, -1.4923, -1.1824, 2.5000, 4.6077, -0.5812, 1.6800, 4.6077, -0.5812, -1.6800, 4.6077, 0.5812, -1.6800, 4.6077, 0.5812, 1.6800, -1.4923, -1.1824, -2.5000, -1.4923, 1.1824, -2.5000, -1.4923, 0.4974, -0.9969, -1.4923, 0.4974, 0.9969, -1.4923, -0.4974, 0.9969, -1.4923, -0.4974, -0.9969 ];
        
        let facecount = 13;
        let faces: [CInt] = [  3, 4, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 0, 1, 2, 3, 4, 5, 6, 7, 1, 8, 8, 1, 0, 2, 1, 7, 9, 8, 0, 10, 10, 0, 2, 11, 11, 2, 7, 12, 12, 7, 8, 9, 9, 5, 4, 12, 10, 6, 5, 9, 11, 3, 6, 10, 12, 4, 3, 11 ];
        
        let vertsData  = NSData(
            bytes: verts,
            length: MemoryLayout<Float>.size * vertcount
        )
        
        let vertexSource = SCNGeometrySource(data: vertsData as Data,
                                             semantic: .vertex,
                                             vectorCount: vertcount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Float>.size * 3)
        
        let polyIndexCount = 61;
        let indexPolyData  = NSData( bytes: faces, length: MemoryLayout<CInt>.size * polyIndexCount )
        
        let element1 = SCNGeometryElement(data: indexPolyData as Data,
                                          primitiveType: .polygon,
                                          primitiveCount: facecount,
                                          bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry1 = SCNGeometry(sources: [vertexSource], elements: [element1])
        
        let material1 = geometry1.firstMaterial!
        
        material1.diffuse.contents = UIColor(red: 0.14, green: 0.82, blue: 0.95, alpha: 1.0)
        material1.lightingModel = .lambert
        material1.transparency = 1.00
        material1.transparencyMode = .dualLayer
        material1.fresnelExponent = 1.00
        material1.reflective.contents = UIColor(white:0.00, alpha:1.0)
        material1.specular.contents = UIColor(white:0.00, alpha:1.0)
        material1.shininess = 1.00
        
        //Assign the SCNGeometry to a SCNNode, for example:
        let aNode = SCNNode()
        aNode.geometry = geometry1
        aNode.scale = SCNVector3(0.05, 0.05, 0.05)
        aNode.eulerAngles = SCNVector3(x: 0, y: Float(90.degreesToRadians), z: 0)
        aNode.name = "arrow"
        let rotateAction = rotateWithHeading()
        aNode.runAction(rotateAction)
        aNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
        
        return aNode
    }
    
    
    private func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode()
        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
    }
    
}


// MARK: - AR Session Management (ARSCNViewDelegate)

extension ARNavigationViewController {
    
    func initARSession() {
        configuration.worldAlignment = .gravityAndHeading
        self.sceneView.session.run(configuration)
    }
    
    func resetARSession() {
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
    }
    
}

// MARK: - Scene Management

extension ARNavigationViewController {
    
    func initScene() {
        self.sceneView.delegate = self
        //sceneView.showsStatistics = true
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = location + orientation
        DispatchQueue.main.async { [self] in
            self.arrow.position = SCNVector3(x: currentPositionOfCamera.x, y: currentPositionOfCamera.y + 0.1, z: currentPositionOfCamera.z)
        }
        
    }
    
    func directionChange(degree: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        let quaternion = simd_quatf(angle: GLKMathDegreesToRadians(degree), axis: simd_float3(0,0,1))
        arrow.simdOrientation = quaternion * arrow.simdOrientation
        SCNTransaction.commit()
    }
    
    func rotateWithHeading() -> SCNAction {
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(Float(heading).degreesToRadians), z: 0, duration: 0)
        return rotation
    }
    
}


// MARK: - Coordinate System
extension ARNavigationViewController {
    
    private func setMap() -> [SCNVector3] {
        let path = Bundle.main.path(forResource: "final_U01 2", ofType: "csv")!
        let path2 = Bundle.main.path(forResource: "source", ofType: "csv")
        var nodes = CSVService.parseCSVAt(url: URL(fileURLWithPath: path))
        var sourceNodes = CSVService.parseCSVAt(url: URL(fileURLWithPath: path))
        var positions: [SCNVector3] = []
        for i in nodes.indices {
            if nodes[i][2].contains("\r") {
                nodes[i][2].removeLast()
                nodes[i][2].removeLast()
            }
            let x = Float(nodes[i][0])!
            let y = Float(nodes[i][1])!
            let z = Float(nodes[i][2])!
            let position = SCNVector3(x: x, y: y, z: z)
            positions.append(position)
        }
        
        return positions
    }
    
    private func setCoordinateNode(start: (x: Int, y: Int), xlimit: Int, ylimit: Int) {
        
        var visited: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: xlimit), count: ylimit)
        var queue = [start]
        var index = 0
        var dx = [0,0,1,-1] // 위(북쪽), 아래(남쪽), 오른쪽(동쪽), 왼쪽(서쪽)
        var dy = [-1,1,0,0]
        
        while queue.count > index {
            let node = queue[index]
            for i in 0..<dx.count {
                let nextX = node.x + dx[i]
                let nextY = node.y + dy[i]
                
                if nextX < 0 || nextX >= xlimit || nextY < 0 || nextY >= ylimit {
                    continue
                }
                else {
                    if map[nextX][nextY] == 1 && (visited[nextX][nextY] == 0) {
                        queue.append((nextX, nextY))
                        visited[nextX][nextY] = 1
                        
                        let coordinateNode = generateSphereNode()
                        coordinateNode.name = "\(nextX), \(nextY)"
                        
                        //                        coordinateNode.position = SCNVector3(startNode.position.x + Float(nextY) - Float(start.y), startNode.position.y, startNode.position.z + Float(nextX) - Float(start.x))
                        print(coordinateNode.position)
                        coordinateNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                        self.sceneView.scene.rootNode.addChildNode(coordinateNode)
                        
                        // 여기서 AR에 박기
                        //                        answer[nextX][nextY] += answer[node.x][node.y] + 1
                    }
                }
            }
            
            index += 1
        }
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Float {
    
    var degreesToRadians: Float { return Float(self) * .pi/180}
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

extension UIScrollView {
    func scroll(to point: CGPoint) {
        let y = point.y - (self.frame.height / 2) < 0 ? 0 : point.y - (self.frame.height / 2)
        self.setContentOffset(CGPoint(x: 0, y: y), animated: true)
    }
}
