// ============================================================
// CruiseGraph Explorer - Schema
// ============================================================

// Cruise lines
CREATE CONSTRAINT cruise_line_id_unique IF NOT EXISTS
FOR (c:CruiseLine)
REQUIRE c.id IS UNIQUE;

// Ships
CREATE CONSTRAINT ship_id_unique IF NOT EXISTS
FOR (s:Ship)
REQUIRE s.id IS UNIQUE;

// Destinations
CREATE CONSTRAINT destination_id_unique IF NOT EXISTS
FOR (d:Destination)
REQUIRE d.id IS UNIQUE;