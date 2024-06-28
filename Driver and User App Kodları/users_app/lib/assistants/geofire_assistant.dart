import '../models/active_nearby_available_drivers.dart';

class GeofireAssistant
{
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList = [];

  static void deleteOfflineDriverFromList(String driverId)
  {
    int indexNumber = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverId);
    if(indexNumber != -1)
    {
      activeNearbyAvailableDriversList.removeAt(indexNumber);
    }
  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableDrivers driver)
  {
    int index = activeNearbyAvailableDriversList.indexWhere((d) => d.driverId == driver.driverId);
    if(index != -1)
    {
      activeNearbyAvailableDriversList[index].locationLatitude = driver.locationLatitude;
      activeNearbyAvailableDriversList[index].locationLongitude = driver.locationLongitude;
    }
  }

}
