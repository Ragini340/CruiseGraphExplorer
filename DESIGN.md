# CruiseGraph Explorer — Design Document

## 1. Purpose

This document describes the architecture, graph data model, application layers, database access strategy, security considerations, and key technical decisions for CruiseGraph Explorer.

The application is designed as a small but complete graph-backed web application using CognoDB as the database layer.

---

# 2. Problem Statement

Cruise information contains multiple connected entities.

A cruise line operates one or more ships.

Each ship can sail to multiple destinations.

Destinations are connected through itineraries and can be reached through multiple intermediate destinations.

The application provides two primary capabilities:

1. Explore cruise lines, ships, and destinations.
2. Discover multi-hop routes between destinations.

The graph model makes these relationships explicit and allows relationship-oriented queries to be expressed naturally.

---

# 3. Goals

The system should:

- Connect to CognoDB using the official Neo4j .NET Driver.
- Store cruise-related entities as graph nodes.
- Store business relationships as typed graph relationships.
- Provide realistic seed data.
- Support multi-hop graph traversal.
- Use parameterized Cypher queries.
- Provide a simple web UI.
- Keep database credentials outside source code.
- Provide clear separation between UI, controller, service, and database layers.
- Gracefully handle database errors.
- Provide an architecture that is easy to maintain and explain.

---

# 4. Non-Goals

The application is not intended to be a production cruise booking system.

The following are outside the current scope:

- Real-time cruise inventory
- Real-time pricing
- Payment processing
- User authentication
- Booking creation
- Customer management
- External cruise API integrations
- Production-scale caching

The focus is graph modeling, graph querying, application architecture, and user experience.

---

# 5. Technology Architecture

```text
+--------------------------------------------------+
|                    Browser                       |
|                                                  |
|              HTML / CSS / JavaScript             |
+-------------------------+------------------------+
                          |
                          | HTTP
                          v
+--------------------------------------------------+
|                ASP.NET Core MVC                  |
|                                                  |
|              CruiseController                   |
+-------------------------+------------------------+
                          |
                          v
+--------------------------------------------------+
|                  Service Layer                   |
|                                                  |
|           ICruiseGraphService                    |
|           CruiseGraphService                     |
+-------------------------+------------------------+
                          |
                          | Neo4j .NET Driver
                          v
+--------------------------------------------------+
|                    Bolt                          |
+-------------------------+------------------------+
                          |
                          v
+--------------------------------------------------+
|                     CognoDB                      |
|                                                  |
| CruiseLine     Ship       Destination           |
+--------------------------------------------------+
```

---

# 6. Layer Responsibilities

## 6.1 Presentation Layer

Responsible for:

- Rendering HTML
- Navigation
- User input
- Empty states
- Error states
- Displaying cruise information
- Displaying route results

Location:

```text
Views/
wwwroot/
```

---

## 6.2 Controller Layer

Location:

```text
Controllers/CruiseController.cs
```

Responsibilities:

- Receive HTTP requests
- Validate basic input
- Call the service layer
- Pass data to views
- Handle application-level errors

The controller does not contain Cypher queries.

---

## 6.3 Service Layer

Location:

```text
Services/
```

Main abstraction:

```text
ICruiseGraphService
```

Implementation:

```text
CruiseGraphService
```

Responsibilities:

- Execute Cypher queries
- Communicate with CognoDB
- Map graph records to application models
- Log database failures
- Keep database logic outside controllers

---

## 6.4 Configuration Layer

Location:

```text
Configuration/CognoDbOptions.cs
```

Responsibilities:

- Store CognoDB configuration
- Read connection information from environment variables
- Keep secrets outside application source code

---

# 7. Graph Data Model

The graph consists of three primary node types:

```text
CruiseLine
Ship
Destination
```

and three relationship types:

```text
OPERATES
SAILS_TO
CONNECTED_TO
```

---

# 8. Node Model

## 8.1 CruiseLine

```text
(:CruiseLine)
```

Properties:

```text
id
name
country
website
```

Example:

```text
{
    id: "royal-caribbean",
    name: "Royal Caribbean International",
    country: "United States",
    website: "https://www.royalcaribbean.com"
}
```

---

## 8.2 Ship

```text
(:Ship)
```

Properties:

```text
id
name
capacity
yearBuilt
```

Example:

```text
{
    id: "oasis-of-the-seas",
    name: "Oasis of the Seas",
    capacity: 6780,
    yearBuilt: 2009
}
```

---

## 8.3 Destination

```text
(:Destination)
```

Properties:

```text
id
name
country
region
```

Example:

```text
{
    id: "miami",
    name: "Miami",
    country: "United States",
    region: "Caribbean"
}
```

---

# 9. Relationship Model

## 9.1 OPERATES

```text
(CruiseLine)-[:OPERATES]->(Ship)
```

Meaning:

A cruise line operates a ship.

Example:

```text
Royal Caribbean
        |
     OPERATES
        |
        v
Oasis of the Seas
```

---

## 9.2 SAILS_TO

```text
(Ship)-[:SAILS_TO]->(Destination)
```

Meaning:

A ship sails to a destination.

Example:

```text
Oasis of the Seas
        |
     SAILS_TO
        |
        v
      Miami
```

---

## 9.3 CONNECTED_TO

```text
(Destination)-[:CONNECTED_TO]->(Destination)
```

Meaning:

A destination is connected to another destination in the route graph.

Example:

```text
Miami
  |
  | CONNECTED_TO
  v
Nassau
```

---

# 10. Complete Graph

```text
                       +----------------------+
                       |      CruiseLine      |
                       +----------+-----------+
                                  |
                               OPERATES
                                  |
                                  v
                       +----------------------+
                       |         Ship         |
                       +----------+-----------+
                                  |
                               SAILS_TO
                                  |
                                  v
                       +----------------------+
                       |     Destination      |
                       +----------+-----------+
                                  |
                            CONNECTED_TO
                                  |
                                  v
                       +----------------------+
                       |     Destination      |
                       +----------------------+
```

Example:

```text
                Royal Caribbean
                       |
                    OPERATES
                       |
                       v
                Oasis of the Seas
                       |
                    SAILS_TO
                       |
       +---------------+----------------+
       |               |                |
       v               v                v
     Miami           Nassau           CocoCay
       |               |
       |               |
       +---------------+
               |
          CONNECTED_TO
               |
               v
          St. Thomas
```

---

# 11. Why Graph Instead of Relational Database?

The primary use case is relationship traversal.

In a relational model, the equivalent structure would normally require multiple tables:

```text
CruiseLines
Ships
Destinations
CruiseLineShips
ShipDestinations
DestinationConnections
```

A route query would then require multiple joins and recursive logic.

The graph model stores relationships directly:

```text
(CruiseLine)-[:OPERATES]->(Ship)
(Ship)-[:SAILS_TO]->(Destination)
(Destination)-[:CONNECTED_TO]->(Destination)
```

This makes multi-hop traversal a natural graph operation.

---

# 12. Multi-Hop Traversal

The route explorer uses:

```cypher
MATCH path =
    (start:Destination {id: $startDestination})
    -[:CONNECTED_TO*2..4]->
    (end:Destination {id: $endDestination})
RETURN
    start.id AS startId,
    end.id AS endId,
    [node IN nodes(path) | node.name] AS path,
    length(path) AS hops
ORDER BY hops
LIMIT 10
```

The important part is:

```text
[:CONNECTED_TO*2..4]
```

This means the query searches paths containing between 2 and 4 relationships.

This directly demonstrates the graph database requirement for multi-hop traversal.

---

# 13. Query Design

## Get Cruise Lines

```cypher
MATCH (c:CruiseLine)
RETURN
    c.id AS id,
    c.name AS name,
    c.country AS country,
    c.website AS website
ORDER BY c.name
```

Purpose:

Retrieve cruise lines for the main page.

---

## Get Cruise Line Details

```cypher
MATCH (c:CruiseLine {id: $cruiseLineId})
OPTIONAL MATCH (c)-[:OPERATES]->(s:Ship)
OPTIONAL MATCH (s)-[:SAILS_TO]->(d:Destination)
RETURN
    c,
    collect(DISTINCT s) AS ships,
    collect(DISTINCT d) AS destinations
```

Purpose:

Retrieve a cruise line and its related ships and destinations.

---

## Find Routes

```cypher
MATCH path =
    (start:Destination {id: $startDestination})
    -[:CONNECTED_TO*2..4]->
    (end:Destination {id: $endDestination})
RETURN
    start.id AS startId,
    end.id AS endId,
    [node IN nodes(path) | node.name] AS path,
    length(path) AS hops
ORDER BY hops
LIMIT 10
```

Purpose:

Find multiple possible routes between destinations.

---

# 14. Parameterization

All user-provided values are passed as parameters.

Example:

```csharp
var result = await session.RunAsync(
    query,
    new
    {
        startDestination,
        endDestination
    });
```

The application never constructs Cypher like:

```csharp
var query =
    "MATCH (d:Destination {id: '" +
    destinationId +
    "'})";
```

Parameterized queries provide:

- Better security
- Cleaner query structure
- Separation between query and data
- Protection against query injection
- Better maintainability

---

# 15. Database Connection

The application uses:

```text
Neo4j.Driver
```

to connect to CognoDB.

Connection configuration:

```text
COGNODB_URI
COGNODB_USER
COGNODB_PASSWORD
```

Example:

```text
COGNODB_URI=bolt+s://instance-id.databases.cognodb.cloud
COGNODB_USER=cognodb
COGNODB_PASSWORD=<generated-password>
```

---

# 16. Connection Flow

```text
Environment Variables
        |
        v
CognoDbOptions
        |
        v
CruiseGraphService
        |
        v
GraphDatabase.Driver()
        |
        v
Neo4j .NET Driver
        |
        | Bolt
        v
CognoDB
```

---

# 17. Security Design

Database credentials are not stored in:

```text
Program.cs
appsettings.json
CruiseGraphService.cs
```

The application reads them from environment variables.

Example:

```text
COGNODB_URI
COGNODB_USER
COGNODB_PASSWORD
```

Local development configuration should not expose real credentials in Git.

---

# 18. Error Handling

Database operations use exception handling and logging.

Example:

```csharp
try
{
    var result = await session.RunAsync(query);
}
catch (Exception ex)
{
    _logger.LogError(
        ex,
        "Error retrieving cruise lines from CognoDB.");

    throw;
}
```

The application also provides user-friendly empty/error states.

Example empty state:

```text
No cruise lines found

No cruise line data is currently available.
Please make sure CognoDB is connected and seeded.
```

---

# 19. Dependency Injection

The service is registered through ASP.NET Core dependency injection.

```csharp
builder.Services.AddSingleton<
    ICruiseGraphService,
    CruiseGraphService>();
```

The controller depends on the abstraction:

```text
ICruiseGraphService
```

rather than directly depending on the concrete implementation.

This improves:

- Testability
- Maintainability
- Separation of concerns
- Dependency inversion

---

# 20. Interface Design

The service exposes:

```csharp
public interface ICruiseGraphService
{
    Task<List<CruiseLine>> GetCruiseLinesAsync();

    Task<CruiseLineDetails?>
        GetCruiseLineDetailsAsync(
            string cruiseLineId);

    Task<List<RouteResult>>
        FindRoutesAsync(
            string startDestination,
            string endDestination);
}
```

The interface represents the application's graph operations without exposing database implementation details to controllers.

---

# 21. Data Seeding

The database setup is divided into two scripts:

```text
Data/
├── schema.cypher
└── seed.cypher
```

### schema.cypher

Creates:

- Constraints
- Graph structure requirements

### seed.cypher

Creates:

- Cruise lines
- Ships
- Destinations
- Relationships

Separating schema and data makes database initialization easier to understand and repeat.

---

# 22. UI Design

The application provides a simple navigation structure:

```text
+----------------------------------------------+
| CruiseGraph                                  |
|                                              |
| Cruise Lines       Route Explorer             |
+----------------------------------------------+
```

Main pages:

```text
/
```

Cruise Lines.

```text
/Cruise/Routes
```

Route Explorer.

---

# 23. Cruise Line Page

The cruise line page displays:

```text
Cruise Line
Country
Website
```

and provides access to details.

The details page displays:

```text
Cruise Line
    |
    +-- Ships
    |
    +-- Destinations
```

---

# 24. Route Explorer

The route explorer provides:

```text
Start Destination
        |
        v
End Destination
        |
        v
Search Routes
```

Results include:

```text
Route
Hops
```

Example:

```text
Miami → Nassau → St. Thomas

Hops: 2
```

---

# 25. Empty and Error States

The UI explicitly handles empty states.

Example:

```text
No cruise lines found
```

The application also logs server-side exceptions to support troubleshooting.

This follows the assignment requirement for graceful error handling when the database is unavailable.

---

# 26. Performance Considerations

The initial application is intentionally small and optimized for the CognoDB free C0 tier.

Performance considerations include:

- Returning only required properties
- Limiting route results to 10
- Restricting route traversal to 2–4 hops
- Using uniqueness constraints
- Avoiding unnecessary database calls
- Keeping the initial dataset small

Future versions could introduce:

- Caching
- Pagination
- Query profiling
- More targeted indexes/constraints
- Asynchronous background loading

---

# 27. Scalability

The service layer allows the application to evolve without changing the controller layer.

Future graph entities could include:

```text
Port
Itinerary
Cruise
Cabin
Region
Country
CruiseOperator
```

Additional relationships could include:

```text
HAS_ITINERARY
STARTS_AT
ENDS_AT
VISITS
LOCATED_IN
OFFERS
```

The graph model can therefore grow naturally as the domain becomes richer.

---

# 28. Testing Strategy

Potential unit-test targets include:

```text
CruiseController
CruiseGraphService
Route validation
Model mapping
Error handling
```

Integration tests can verify:

```text
Application
    |
    v
CognoDB
```

against a test graph dataset.

Tests can verify:

- Cruise lines are returned
- Cruise line details are returned
- Route traversal works
- Empty results are handled
- Invalid destination IDs are handled

---

# 29. Maintainability

The project follows separation of concerns:

```text
Controller
    ↓
Service
    ↓
Driver
    ↓
CognoDB
```

This prevents:

- Cypher queries inside views
- Database access inside controllers
- UI logic inside services
- Credentials inside source code

The result is a codebase that can be reviewed and maintained independently by different layers.

---

# 30. Deployment Considerations

For deployment:

1. Deploy the ASP.NET Core application.
2. Configure the CognoDB environment variables in the hosting platform.
3. Keep the CognoDB instance running.
4. Run the schema and seed scripts.
5. Verify database connectivity.
6. Verify the application URL.
7. Test Cruise Lines.
8. Test Route Explorer.

The hosted environment must never expose the CognoDB password publicly.

---

# 31. Future Enhancements

Possible improvements:

### Graph Visualization

Display:

```text
CruiseLine → Ship → Destination → Destination
```

visually using a JavaScript graph library.

### Advanced Route Search

Allow users to specify:

```text
Maximum hops
Preferred region
Cruise line
```

### Search

Add:

```text
Cruise Line Search
Ship Search
Destination Search
```

### More Data

Add:

- More cruise lines
- More ships
- More destinations
- More connections
- Additional regions

### Automated Tests

Add:

- Unit tests
- Integration tests
- Controller tests
- Service tests

---

# 32. Key Design Decisions Summary

| Decision | Reason |
|---|---|
| CognoDB | Natural fit for connected cruise data |
| Neo4j .NET Driver | Official driver supported by CognoDB |
| ASP.NET Core MVC | Clean MVC architecture |
| Service layer | Separates database logic from controllers |
| Cypher | Natural graph query language |
| Parameterized queries | Security and maintainability |
| Environment variables | Protect database credentials |
| Multi-hop traversal | Demonstrates graph-specific capability |
| Seed script | Reproducible database setup |
| Empty/error states | Better user experience |

---

# 33. Final Architecture

```text
                         USER
                          |
                          v
                 +----------------+
                 |     Browser    |
                 +-------+--------+
                         |
                        HTTP
                         |
                         v
              +----------------------+
              | ASP.NET Core MVC      |
              |                      |
              | CruiseController     |
              +----------+-----------+
                         |
                         |
                         v
              +----------------------+
              | Service Layer        |
              |                      |
              | ICruiseGraphService  |
              | CruiseGraphService   |
              +----------+-----------+
                         |
                         |
                         v
              +----------------------+
              | Neo4j .NET Driver    |
              +----------+-----------+
                         |
                       Bolt
                         |
                         v
              +----------------------+
              |       CognoDB        |
              |                      |
              | CruiseLine           |
              | Ship                 |
              | Destination          |
              +----------------------+
```

---

# 34. Conclusion

CruiseGraph Explorer uses a graph-first architecture because the core problem is about relationships rather than isolated records.

The graph model allows:

```text
CruiseLine
    ↓
Ship
    ↓
Destination
    ↓
Destination
```

to be represented directly and queried using graph traversal.

The architecture keeps:

- UI concerns in Views
- Request handling in Controllers
- Business/data-access operations in Services
- Configuration in Configuration
- Data initialization in Cypher scripts
- Credentials in environment variables

This provides a clean foundation for extending the application into a richer cruise graph platform.