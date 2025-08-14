# Town Dashboard & District Foundation System - Future Features from Claude

## Phase 1: Town Overview Dashboard Widget

### 1.1 Core Information Cards
- **Town Header**: Name, population count, leader, guard captain
- **Featured NPCs**: Random hireling + random shop notable with reroll
- **Street Encounters**: 4-6 random encounters using existing system
- **Talk of the Town**: Rumor system with preseeded + custom rumors

## Phase 2: Simplified District Foundation System

### 2.1 Revised YAML Template Structure
**File**: `assets/district_templates/default_layout.yaml`

```yaml
# District Layout Template - Infrastructure Only
template_info:
  name: "Standard Layout"
  version: "1.0"
  
# Map Layout Configuration  
layout:
  type: "hub_and_spoke"
  district_count: 5  # how many districts to generate
  
# District Slots (no names/descriptions - will be generated)
district_slots:
  center:
    color: "#4CAF50"
    size: 1.2
    position: {x: 0.5, y: 0.5}
    max_locations: 8
    
  north:
    color: "#FF9800" 
    size: 1.0
    position: {x: 0.5, y: 0.2}
    max_locations: 6
    
  east:
    color: "#9C27B0"
    size: 1.0  
    position: {x: 0.8, y: 0.5}
    max_locations: 6
    
  south:
    color: "#607D8B"
    size: 0.9
    position: {x: 0.5, y: 0.8}
    max_locations: 5
    
  west:
    color: "#795548"
    size: 0.9
    position: {x: 0.2, y: 0.5}
    max_locations: 5

# Path Structure (names will be generated)
path_slots:
  primary_paths:
    - {from: "center", to: "north", type: "primary"}
    - {from: "center", to: "east", type: "primary"}
    - {from: "center", to: "south", type: "primary"}
    - {from: "center", to: "west", type: "primary"}
    
  secondary_paths:
    - {from: "north", to: "east", type: "secondary"}
    - {from: "south", to: "west", type: "secondary"}
```

### 2.2 District Data Models (Foundation for Travel Mode)
**File**: `lib/models/district_system.dart`

```dart
class District {
  String id;
  String generatedName;  // Generated from name templates
  Color color;
  Offset mapPosition;    // Abstract map position
  double size;
  List<String> locationIds;  // Existing locations assigned here
  List<String> connectedPathIds;
  
  // Future travel mode support
  String? generatedDescription;  // Will use description templates
  List<String> encounterTableIds;  // District-specific encounters
}

class DistrictPath {
  String id;
  String generatedName;  // Generated path names
  String fromDistrictId, toDistrictId;
  PathType type;
  
  // Future travel mode support
  List<String> travelEncounterIds;  // Encounters along this path
  List<String> landmarkIds;  // Things seen while traveling
  bool isBidirectional = true;  // A->B same as B->A
}

class DistrictLocation {
  String locationId;  // References existing Location
  String districtId;
  Offset relativePosition;  // Position within district for zoom view
  double rotation;  // Rotation for spatial geometry
}
```

### 2.3 Name Generation System
**File**: `lib/services/district_name_generator.dart`

#### District Naming Templates
```dart
// Name generation patterns
List<String> familyNames = ["Aldrich", "Blackwood", "Cromwell", "Dunstan"];
List<String> landmarkTypes = ["Hill", "Gate", "Square", "Cross", "Bridge"];
List<String> descriptors = ["Old", "New", "Upper", "Lower", "East", "West"];

// Generation patterns:
// "[Family] Quarter" -> "Aldrich Quarter"
// "[Descriptor] [Landmark]" -> "Upper Gate" 
// "[Landmark] District" -> "Hill District"
```

#### Path Naming Templates
```dart
// Path generation patterns
// "[Landmark] Way" -> "Cross Way"
// "[Family] Road" -> "Blackwood Road" 
// "[Descriptor] Path" -> "Lower Path"
```

### 2.4 District Assignment Algorithm
**File**: `lib/services/district_assignment.dart`

```dart
class DistrictAssignmentService {
  static List<District> assignLocationsToDistricts(
    List<Location> townLocations,
    DistrictTemplate template
  ) {
    // 1. Create districts from template slots
    // 2. Generate names for each district
    // 3. Randomly distribute existing locations among districts
    // 4. Respect max_locations limits
    // 5. Ensure each district gets at least 1 location
  }
}
```

## Phase 3: Spatial Geometry Foundation (District Zoom)

### 3.1 District Interior Layout System
**File**: `lib/models/district_interior.dart`

```dart
class DistrictInterior {
  String districtId;
  List<DistrictLocation> locations;  // Positions within district
  List<DistrictStreet> internalStreets;  // Streets within district
  DistrictLayoutType layoutType;  // grid, radial, organic, linear
}

enum DistrictLayoutType {
  grid,      // Locations arranged in rough grid
  radial,    // Locations around central point
  linear,    // Locations along main street
  organic,   // Random but aesthetically pleasing
  cluster    // Small groups of related buildings
}
```

### 3.2 District Zoom View (Future Implementation)
**File**: `lib/widgets/district_zoom_view.dart`

#### Spatial Geometry Features (Planned)
- **2D Layout**: Buildings positioned in 2D space within district
- **Street Network**: Internal paths between buildings
- **Zoom Levels**: 
  - Level 1: District overview with building icons
  - Level 2: Building details with names
  - Level 3: Building interiors (future expansion)

#### Layout Generation Algorithm (Planned)
```dart
// Generate spatial positions for locations within district
class DistrictLayoutGenerator {
  static List<DistrictLocation> generateLayout(
    List<Location> locations,
    DistrictLayoutType layoutType,
    double districtSize
  ) {
    // Create pleasing 2D arrangement of buildings
    // Consider building types and relationships
    // Generate connecting streets/paths
  }
}
```

## Phase 4: Travel Mode Foundation Infrastructure

### 4.1 Travel Route System (Foundation Only)
**File**: `lib/models/travel_system.dart`

```dart
class TravelRoute {
  String fromDistrictId, toDistrictId;
  List<String> pathIds;  // Sequence of paths to traverse
  List<String> landmarkIds;  // Things seen along the way
  List<String> encounterIds;  // Possible encounters
  bool isBidirectional;  // Same sights/encounters both ways
}

class TravelLandmark {
  String id, name, description;
  String pathId;  // Which path it's visible from
  double position;  // 0.0-1.0 along the path
}
```

### 4.2 Encounter Table Foundation
**File**: `lib/models/district_encounters.dart`

```dart
class DistrictEncounterTable {
  String districtId;
  List<String> encounterIds;  // District-specific encounters
  EncounterTableType type;  // street, building, special
}

class PathEncounterTable {
  String pathId;
  List<String> encounterIds;  // Travel encounters
  List<TravelLandmark> landmarks;  // Sights along the way
}
```

## Phase 5: Implementation Priority

### 5.1 Phase 1 (Current): Foundation Infrastructure
- **Dashboard**: Town overview with key NPCs and rumors
- **District Assignment**: Distribute existing locations to districts
- **Name Generation**: Generate district and path names
- **Abstract Map**: Simple node graph view

### 5.2 Phase 2 (Future): District Details  
- **District Zoom**: 2D spatial layout within districts
- **District Encounters**: Specific encounter tables per district
- **Interior Streets**: Path networks within districts

### 5.3 Phase 3 (Future): Travel Mode
- **Route Planning**: A to B travel planning
- **Travel Encounters**: Encounters and landmarks along paths
- **Bidirectional Consistency**: Same experience both directions
- **Journey Narratives**: "Along the way, you see..."

## Key Benefits of This Foundation Approach

### Scalability
- **Modular Design**: Each phase builds on previous without breaking changes
- **Future-Proof**: Infrastructure supports planned travel mode features
- **Incremental Value**: Each phase delivers user value independently

### Technical Architecture
- **Clean Separation**: Map structure separate from content
- **Reusable Components**: District/path system works for any setting
- **Data Integrity**: Existing locations preserved, just reorganized

### User Experience
- **Immediate Benefit**: Dashboard and abstract map provide instant value
- **Progressive Enhancement**: More features unlock over time
- **Familiar Patterns**: Builds on existing location/encounter systems

## Timeline: 2-3 weeks for Phase 1
- **Week 1**: Dashboard implementation
- **Week 2**: District assignment + name generation + basic map
- **Week 3**: Polish + integration with existing navigation