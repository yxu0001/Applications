1. What does this project do?
The EarthquakeMonitor project gets quake json data from USGS services and displays them in a list with chronological order. Selecting a quake 
will show the quake on a map. It is designed for all types of iOS devices.

2. Features
2.1 Pull down sync
2.2 UISearchController (with fixed searchbar even when NOT in search mode); filter by scope
2.3 UISplitController for master and detail layout => fits all types of iOS devices
2.3 MKMap

3. Challenges
3.1 It needs some research to add annotation on the map
3.2 Fixing search bar when NOT in search mode
3.3 UI layout when rotating the device. Somehow for the search bar with scope auto-layout seems to come short.
3.4 Better understanding data from USGS needs some special knowledge. So far only used location and megnitude.

3. TODO
3.1 There is performance issue as the app loads full month data and user filter by scope.
3.2 Interactive map annotation.
