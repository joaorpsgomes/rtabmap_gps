
/**
 * Author: Mathieu Labbe
 * This file is a copy of GPSPose2Factor.h of gtsam examples for Pose3
 */

/**
 * A simple 3D 'GPS' like factor
 * The factor contains a X-Y-Z position measurement (mx, my, mz) for a Pose, but no rotation information
 * The error vector will be [x-mx, y-my, z-mz]'
 */

#pragma once

#include <gtsam/nonlinear/NonlinearFactor.h>
#include <gtsam/base/Matrix.h>
#include <gtsam/base/Vector.h>
#include <gtsam/geometry/Pose3.h>


namespace rtabmap {

class GPSPose3XYZFactor: public gtsam::NoiseModelFactor1<gtsam::Pose3> {

private:
  // measurement information
  double mx_, my_, mz_;

public:

  /**
   * Constructor
   * @param poseKey    associated pose variable key
   * @param model      noise model for GPS sensor, in X-Y
   * @param m          Point2 measurement
   */
  GPSPose3XYZFactor(gtsam::Key poseKey, const gtsam::Point3 m, gtsam::SharedNoiseModel model) :
      gtsam::NoiseModelFactor1<gtsam::Pose3>(model, poseKey), mx_(m.x()), my_(m.y()), mz_(m.z()) {}

  // error function
  // @param p    the pose in Pose
  // @param H    the optional Jacobian matrix, which use boost optional and has default null pointer
  gtsam::Vector evaluateError(const gtsam::Pose3& p, boost::optional<gtsam::Matrix&> H = boost::none) const {
    if(H)
    {
	  p.translation(H);
    }
    return (gtsam::Vector3() << p.x() - mx_, p.y() - my_, p.z() - mz_).finished();
  }
};

} // namespace gtsamexamples

