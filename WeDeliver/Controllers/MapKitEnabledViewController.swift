//
//  MapKitEnabledViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-23.
//

import UIKit
import MapKit

class MapKitEnabledViewController: UIViewController, MKMapViewDelegate {
  // MARK: - Vars
  var locationMgr = CLLocationManager()
  var driverLocationCoordinate: CLLocationCoordinate2D!
  var sourceMKPlacemark: MKPlacemark?
  var destinationMKPlacemark: MKPlacemark?
  var driverDropPinAnnotation: MKPointAnnotation!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .black
    renderer.lineWidth = 5
    return renderer
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let annotationIdentifier = "Default"
    var annotationView: MKAnnotationView

    if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
      dequeuedAnnotationView.annotation = annotation
      annotationView = dequeuedAnnotationView
    } else {
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
    }

    switch annotation.title {
    case CharacterType.Recipient.rawValue:
      annotationView.canShowCallout = true
      annotationView.image = UIImage(named: AnnotationPin.Recipient.rawValue)
    case CharacterType.Driver.rawValue:
      annotationView.canShowCallout = true
      annotationView.image = UIImage(named: AnnotationPin.Driver.rawValue)
    case CharacterType.Restaurant.rawValue:
      annotationView.canShowCallout = true
      annotationView.image = UIImage(named: AnnotationPin.Restaurant.rawValue)
    default:
      annotationView.canShowCallout = true
    }

    return annotationView
  }

  internal func convertAddressToCLPlacemark(_ address: String, completion: @escaping (CLPlacemark) -> Void) {
    CLGeocoder().geocodeAddressString(address) { cLPlacemarks, error in
      guard error == nil else { return }

      if let cLPlacemark = cLPlacemarks?.first {
        completion(cLPlacemark)
      }
    }
  }

  internal func setDropPinAnnotation(on mapView: inout MKMapView, at location: CLLocation, titled title: String = "") {
    let dropPinAnnotation = MKPointAnnotation()
    dropPinAnnotation.coordinate = location.coordinate
    dropPinAnnotation.title = title
    mapView.addAnnotation(dropPinAnnotation)
  }

  internal func drawRoutes(on mapView: inout MKMapView) {
    var _mapView = mapView

    let request = requestForRoutes()
    MKDirections(request: request).calculate { response, error in
      guard error == nil else { return }
      self.renderRoutes(response!.routes, on: &_mapView)
    }
  }

  private func requestForRoutes() -> MKDirections.Request {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: sourceMKPlacemark!)
    request.destination = MKMapItem(placemark: destinationMKPlacemark!)
    request.requestsAlternateRoutes = false
    return request
  }

  private func renderRoutes(_ routes: [MKRoute], on mapView: inout MKMapView) {
    for route in routes {
      mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
    }
    mapView.layoutMargins = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 80.0, right: 20.0)
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
}
