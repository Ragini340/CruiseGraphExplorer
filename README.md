# CruiseGraph Explorer

A graph-powered web application for exploring cruise lines, ships, destinations, and destination-to-destination routes using **CognoDB** as the graph database.

The application is built with **ASP.NET Core MVC and C#** and connects to CognoDB using the official **Neo4j .NET Driver** over the Bolt protocol.

---

## 1. Overview

Cruise booking data contains many relationships:

- Cruise lines operate ships
- Ships sail to multiple destinations
- Destinations are connected through cruise itineraries
- Multiple cruise lines can serve the same destination
- A destination can be reached through multiple intermediate destinations

A relational database can store this information, but relationship-oriented questions become increasingly complex as the number of relationships grows.

CruiseGraph Explorer models these relationships directly as a graph so that users can explore cruise lines and discover multi-hop routes between destinations.

---

## 2. Key Features

### Cruise Line Explorer

Users can:

- View available cruise lines
- View cruise line information
- View ships operated by a cruise line
- View destinations served by its ships

### Route Explorer

Users can:

- Select a starting destination
- Select an ending destination
- Search for routes between destinations
- Discover multi-hop paths through the graph
- View the number of hops in each route

### Graph Database

The application uses:

- CognoDB
- openCypher
- Bolt protocol
- Official Neo4j .NET Driver

### Configuration

Database credentials are read from environment variables and are never hard-coded into the application.

---

# 3. Why a Graph Database?

The most important reason for using a graph database in this application is the number of relationships between entities.

The primary relationships are:

```text
CruiseLine
    |
    | OPERATES
    v
  Ship
    |
    | SAILS_TO
    v
Destination
    |
    | CONNECTED_TO
    v
Destination
```

A cruise line can operate multiple ships.

A ship can sail to multiple destinations.

A destination can be connected to multiple other destinations.

This creates a highly connected data model.

For example:

```text
Miami
  |
  +---- Nassau
  |       |
  |       +---- St. Thomas
  |
  +---- Cozumel
  |
  +---- CocoCay
```

A graph database allows these relationships to be traversed naturally.

For example, finding a route from Miami to St. Thomas can be expressed as a graph traversal:

```cypher
MATCH path =
    (start:Destination {id: $startDestination})
    -[:CONNECTED_TO*2..4]->
    (end:Destination {id: $endDestination})
RETURN
    [node IN nodes(path) | node.name] AS path,
    length(path) AS hops
ORDER BY hops
LIMIT 10
```

This is one of the areas where a graph model is particularly useful compared with joining multiple relational tables.

---

# 4. Technology Stack

| Layer | Technology |
|---|---|
| Language | C# |
| Framework | ASP.NET Core MVC |
| Runtime | .NET 8 |
| Database | CognoDB |
| Query Language | openCypher |
| Database Protocol | Bolt |
| Database Driver | Neo4j .NET Driver |
| Frontend | HTML, CSS, JavaScript |
| Configuration | Environment Variables |
| IDE | Visual Studio |
| Source Control | Git / GitHub |

CognoDB supports openCypher over Bolt and works with the official Neo4j drivers, including the .NET driver.

---

# 5. Architecture

The application follows a simple layered architecture:

```text
+-----------------------------+
|           Browser           |
|     HTML / CSS / JS         |
+--------------+--------------+
               |
               v
+-----------------------------+
|      ASP.NET Core MVC       |
|                             |
|       Controllers           |
+--------------+--------------+
               |
               v
+-----------------------------+
|          Services           |
|                             |
|   ICruiseGraphService       |
|   CruiseGraphService        |
+--------------+--------------+
               |
               v
+-----------------------------+
|      Neo4j .NET Driver      |
+--------------+--------------+
               |
               | Bolt
               v
+-----------------------------+
|          CognoDB            |
|                             |
| CruiseLine                  |
| Ship                        |
| Destination                 |
+-----------------------------+
```

---

# 6. Project Structure

```text
CruiseGraphExplorer/
│
├── Configuration/
│   └── CognoDbOptions.cs
│
├── Controllers/
│   └── CruiseController.cs
│
├── Data/
│   ├── schema.cypher
│   └── seed.cypher
│
├── Models/
│   ├── CruiseLine.cs
│   ├── CruiseLineDetails.cs
│   ├── Destination.cs
│   ├── RouteResult.cs
│   └── Ship.cs
│
├── Services/
│   ├── ICruiseGraphService.cs
│   └── CruiseGraphService.cs
│
├── Views/
│   ├── Cruise/
│   │   ├── Index.cshtml
│   │   ├── Details.cshtml
│   │   └── Routes.cshtml
│   │
│   └── Shared/
│       ├── _Layout.cshtml
│       └── _ValidationScriptsPartial.cshtml
│
├── wwwroot/
│   ├── css/
│   │   └── site.css
│   └── js/
│       └── site.js
│
├── Properties/
│   └── launchSettings.json
│
├── Program.cs
├── appsettings.json
├── .gitignore
└── README.md
```

---

# 7. Graph Data Model

## Nodes

### CruiseLine

Properties:

```text
id
name
country
website
```

Example:

```text
CruiseLine
{
    id: "royal-caribbean",
    name: "Royal Caribbean International",
    country: "United States",
    website: "https://www.royalcaribbean.com"
}
```

### Ship

Properties:

```text
id
name
capacity
yearBuilt
```

### Destination

Properties:

```text
id
name
country
region
```

---

## Relationships

### OPERATES

```text
(CruiseLine)-[:OPERATES]->(Ship)
```

Represents a cruise line operating a ship.

### SAILS_TO

```text
(Ship)-[:SAILS_TO]->(Destination)
```

Represents a ship sailing to a destination.

### CONNECTED_TO

```text
(Destination)-[:CONNECTED_TO]->(Destination)
```

Represents a navigable connection between destinations.

---

# 8. Graph Diagram

```text
                         +----------------+
                         |   CruiseLine   |
                         +-------+--------+
                                 |
                              OPERATES
                                 |
                                 v
                         +----------------+
                         |      Ship      |
                         +-------+--------+
                                 |
                              SAILS_TO
                                 |
                                 v
                         +----------------+
                         |  Destination   |
                         +-------+--------+
                                 |
                           CONNECTED_TO
                                 |
                                 v
                         +----------------+
                         |  Destination   |
                         +----------------+
```

Example:

```text
+---------------------------+
| Royal Caribbean           |
+-------------+-------------+
              |
           OPERATES
              |
              v
+---------------------------+
| Oasis of the Seas         |
+-------------+-------------+
              |
           SAILS_TO
              |
      +-------+-------+
      |       |       |
      v       v       v
   Miami   Nassau   CocoCay
      |       |
      |       |
      +---+---+
          |
     CONNECTED_TO
          |
          v
      St. Thomas
```

---

# 9. CognoDB Setup

## 9.1 Create a CognoDB Account

Open:

https://console.cognodb.com/signup

Create an account.

The assignment provides a free C0 tier and does not require a credit card.

---

## 9.2 Create a C0 Instance

After logging in:

1. Open the CognoDB Cloud console.
2. Create a new instance.
3. Select the free `C0` tier.
4. Select an available region.
5. Create the instance.
6. Wait for the instance to become available.

---

## 9.3 Save Connection Details

The instance provides:

```text
URI:
bolt+s://<instance-id>.databases.cognodb.cloud

Username:
cognodb

Password:
<generated-password>
```

The generated password should be saved immediately because it is displayed only once.

---

# 10. Environment Variables

The application does not store database credentials in source code.

Configure:

```text
COGNODB_URI
COGNODB_USER
COGNODB_PASSWORD
```

Example:

```text
COGNODB_URI=bolt+s://your-instance-id.databases.cognodb.cloud
COGNODB_USER=cognodb
COGNODB_PASSWORD=your-generated-password
```

For local Visual Studio development these can be configured in `launchSettings.json`.

Example:

```json
{
  "environmentVariables": {
    "ASPNETCORE_ENVIRONMENT": "Development",
    "COGNODB_URI": "bolt+s://your-instance-id.databases.cognodb.cloud",
    "COGNODB_USER": "cognodb",
    "COGNODB_PASSWORD": "your-generated-password"
  }
}
```

Never commit real credentials to GitHub.

---

# 11. Install the Neo4j Driver

Install the official Neo4j .NET Driver package:

```bash
dotnet add package Neo4j.Driver
```

The application uses the official Neo4j driver to connect to CognoDB.

---

# 12. Database Schema

The schema is stored in:

```text
Data/schema.cypher
```

The schema creates uniqueness constraints for:

```text
CruiseLine.id
Ship.id
Destination.id
```

Run the schema script against the CognoDB instance before loading the seed data.

---

# 13. Seed Data

Seed data is stored in:

```text
Data/seed.cypher
```

The seed script creates realistic cruise-related data including:

- Cruise lines
- Ships
- Destinations
- Cruise line → ship relationships
- Ship → destination relationships
- Destination → destination relationships

The script is intentionally small enough for the CognoDB free tier while providing enough relationships to demonstrate graph traversal.

---

# 14. Running Cypher Queries

Open the CognoDB Cloud query/console interface.

First test the connection:

```cypher
RETURN 1 AS connected;
```

Then verify the database:

```cypher
MATCH (n)
RETURN count(n) AS totalNodes;
```

Verify cruise lines:

```cypher
MATCH (c:CruiseLine)
RETURN
    c.id AS id,
    c.name AS name,
    c.country AS country,
    c.website AS website
ORDER BY c.name;
```

---

# 15. Main Application Queries

## 15.1 Get Cruise Lines

```cypher
MATCH (c:CruiseLine)
RETURN
    c.id AS id,
    c.name AS name,
    c.country AS country,
    c.website AS website
ORDER BY c.name
```

This query retrieves the cruise lines displayed on the home page.

---

## 15.2 Get Cruise Line Details

```cypher
MATCH (c:CruiseLine {id: $cruiseLineId})
OPTIONAL MATCH (c)-[:OPERATES]->(s:Ship)
OPTIONAL MATCH (s)-[:SAILS_TO]->(d:Destination)
RETURN
    c,
    collect(DISTINCT s) AS ships,
    collect(DISTINCT d) AS destinations
```

This query demonstrates how related graph data can be retrieved in a single traversal.

---

## 15.3 Multi-Hop Route Search

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

This is the key graph traversal query.

It searches for paths containing 2 to 4 relationships.

---

# 16. Parameterized Queries

The application does not concatenate user input into Cypher.

For example:

```csharp
var result = await session.RunAsync(
    query,
    new
    {
        startDestination,
        endDestination
    });
```

This allows the values to be supplied as query parameters.

Benefits:

- Avoids string-concatenated Cypher
- Improves security
- Keeps queries readable
- Separates query structure from user input

---

# 17. User Interface

The application provides two main areas.

## Cruise Lines

URL:

```text
/Cruise
```

Users can view cruise lines and select a cruise line to explore its ships and destinations.

## Route Explorer

URL:

```text
/Cruise/Routes
```

Users can select:

```text
Start Destination
End Destination
```

and search for routes.

---

# 18. Empty State

If no cruise line data exists, the application displays:

```text
No cruise lines found

No cruise line data is currently available.
Please make sure CognoDB is connected and seeded.
```

This helps users understand that the application is functioning but the database contains no relevant data.

---

# 19. Error Handling

Database operations are wrapped in exception handling.

Example:

```csharp
try
{
    // database operation
}
catch (Exception ex)
{
    _logger.LogError(
        ex,
        "Error retrieving cruise lines from CognoDB.");

    throw;
}
```

This provides useful server-side diagnostics while allowing the controller/UI to handle failures.

---

# 20. Running the Application

From Visual Studio:

```text
1. Open CruiseGraphExplorer.sln
2. Restore NuGet packages
3. Configure CognoDB environment variables
4. Ensure CognoDB instance is running
5. Execute schema.cypher
6. Execute seed.cypher
7. Build the solution
8. Run the application
```

Or from the command line:

```bash
dotnet restore
dotnet build
dotnet run
```

Open:

```text
https://localhost:7043
```

---

# 21. Verification

After seeding the database, run:

```cypher
MATCH (c:CruiseLine)
RETURN count(c) AS CruiseLines;
```

Then:

```cypher
MATCH (s:Ship)
RETURN count(s) AS Ships;
```

Then:

```cypher
MATCH (d:Destination)
RETURN count(d) AS Destinations;
```

Verify relationships:

```cypher
MATCH (c:CruiseLine)-[:OPERATES]->(s:Ship)
RETURN c.name, s.name;
```

Verify routes:

```cypher
MATCH path =
    (start:Destination {id: 'miami'})
    -[:CONNECTED_TO*2..4]->
    (end:Destination {id: 'st-thomas'})
RETURN
    [node IN nodes(path) | node.name] AS path,
    length(path) AS hops
ORDER BY hops;
```

---

# 22. Security

The following information must never be committed to GitHub:

```text
COGNODB_URI
COGNODB_PASSWORD
```

The repository should contain only configuration placeholders.

Example:

```text
COGNODB_URI=<your-uri>
COGNODB_USER=cognodb
COGNODB_PASSWORD=<your-password>
```

---

# 23. Git Ignore

The following should be excluded from source control:

```gitignore
.vs/
bin/
obj/
*.user
*.suo
.env
.env.*
Properties/launchSettings.json
```

If `launchSettings.json` is used only for local development and contains real credentials, it should not be committed.

---

# 24. Design Decisions

### Why ASP.NET Core MVC?

ASP.NET Core MVC provides a clean separation between:

- Controllers
- Services
- Models
- Views

It also fits naturally with the application's C# implementation.

### Why a Service Layer?

Database access is isolated inside:

```text
ICruiseGraphService
CruiseGraphService
```

Controllers therefore do not contain database-specific Cypher logic.

### Why the Neo4j Driver?

CognoDB supports the Bolt protocol and works with the official Neo4j drivers. Using the official .NET driver keeps the application aligned with the standard graph database access model.

### Why Environment Variables?

Credentials should not be embedded in source code.

Environment variables allow the same application to run against different CognoDB instances without changing source code.

---

# 25. Future Improvements

Potential future enhancements include:

- Pagination for cruise lines and ships
- Route visualization
- Graph visualization using JavaScript
- Additional cruise lines and ships
- Search/filter functionality
- Caching frequently accessed graph data
- Automated integration tests
- Health-check endpoint for CognoDB
- Structured application logging
- Hosted deployment
- Authentication and authorization

---

# 26. Conclusion

CruiseGraph Explorer demonstrates how a graph database can be used to model and explore highly connected cruise data.

The application combines:

- ASP.NET Core MVC
- C#
- CognoDB
- openCypher
- Bolt
- Neo4j .NET Driver
- HTML/CSS/JavaScript

The key graph capability is multi-hop destination traversal, which allows the application to answer relationship-oriented questions naturally.

---

# 27. Assignment Deliverables

The repository contains:

- Full application source code
- CognoDB schema script
- Realistic seed data
- Cypher queries
- Graph data model
- README documentation
- Setup instructions
- Environment-variable configuration
- Cruise Line Explorer
- Route Explorer

A hosted demo and short screen recording can be added before final submission.

---

## Author

**Ragini**

Full Stack Software Engineer

GitHub:

https://github.com/Ragini340