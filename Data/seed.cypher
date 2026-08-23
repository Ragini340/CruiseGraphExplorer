// ============================================================
// CruiseGraph Explorer - Seed Data
// ============================================================


// ============================================================
// CRUISE LINES
// ============================================================

MERGE (royal:CruiseLine {id: 'royal-caribbean'})
SET
    royal.name = 'Royal Caribbean International',
    royal.country = 'United States',
    royal.website = 'https://www.royalcaribbean.com';


MERGE (carnival:CruiseLine {id: 'carnival'})
SET
    carnival.name = 'Carnival Cruise Line',
    carnival.country = 'United States',
    carnival.website = 'https://www.carnival.com';


MERGE (msc:CruiseLine {id: 'msc-cruises'})
SET
    msc.name = 'MSC Cruises',
    msc.country = 'Switzerland',
    msc.website = 'https://www.msccruises.com';


MERGE (ncl:CruiseLine {id: 'norwegian-cruise-line'})
SET
    ncl.name = 'Norwegian Cruise Line',
    ncl.country = 'United States',
    ncl.website = 'https://www.ncl.com';


MERGE (princess:CruiseLine {id: 'princess-cruises'})
SET
    princess.name = 'Princess Cruises',
    princess.country = 'United States',
    princess.website = 'https://www.princess.com';


// ============================================================
// SHIPS
// ============================================================

MERGE (oasis:Ship {id: 'oasis-of-the-seas'})
SET
    oasis.name = 'Oasis of the Seas',
    oasis.capacity = 6780,
    oasis.yearBuilt = 2009;


MERGE (wonder:Ship {id: 'wonder-of-the-seas'})
SET
    wonder.name = 'Wonder of the Seas',
    wonder.capacity = 6988,
    wonder.yearBuilt = 2022;


MERGE (mardi:Ship {id: 'mardi-gras'})
SET
    mardi.name = 'Mardi Gras',
    mardi.capacity = 5282,
    mardi.yearBuilt = 2021;


MERGE (seascape:Ship {id: 'msc-seascape'})
SET
    seascape.name = 'MSC Seascape',
    seascape.capacity = 5877,
    seascape.yearBuilt = 2022;


MERGE (prima:Ship {id: 'norwegian-prima'})
SET
    prima.name = 'Norwegian Prima',
    prima.capacity = 3215,
    prima.yearBuilt = 2022;


MERGE (discovery:Ship {id: 'discovery-princess'})
SET
    discovery.name = 'Discovery Princess',
    discovery.capacity = 3660,
    discovery.yearBuilt = 2022;


// ============================================================
// CRUISE LINE -> SHIP
// ============================================================

MERGE (royal:CruiseLine {id: 'royal-caribbean'})
MERGE (oasis:Ship {id: 'oasis-of-the-seas'})
MERGE (royal)-[:OPERATES]->(oasis);


MERGE (royal:CruiseLine {id: 'royal-caribbean'})
MERGE (wonder:Ship {id: 'wonder-of-the-seas'})
MERGE (royal)-[:OPERATES]->(wonder);


MERGE (carnival:CruiseLine {id: 'carnival'})
MERGE (mardi:Ship {id: 'mardi-gras'})
MERGE (carnival)-[:OPERATES]->(mardi);


MERGE (msc:CruiseLine {id: 'msc-cruises'})
MERGE (seascape:Ship {id: 'msc-seascape'})
MERGE (msc)-[:OPERATES]->(seascape);


MERGE (ncl:CruiseLine {id: 'norwegian-cruise-line'})
MERGE (prima:Ship {id: 'norwegian-prima'})
MERGE (ncl)-[:OPERATES]->(prima);


MERGE (princess:CruiseLine {id: 'princess-cruises'})
MERGE (discovery:Ship {id: 'discovery-princess'})
MERGE (princess)-[:OPERATES]->(discovery);


// ============================================================
// DESTINATIONS
// ============================================================

MERGE (miami:Destination {id: 'miami'})
SET
    miami.name = 'Miami',
    miami.country = 'United States',
    miami.region = 'Caribbean';


MERGE (nassau:Destination {id: 'nassau'})
SET
    nassau.name = 'Nassau',
    nassau.country = 'Bahamas',
    nassau.region = 'Caribbean';


MERGE (cozumel:Destination {id: 'cozumel'})
SET
    cozumel.name = 'Cozumel',
    cozumel.country = 'Mexico',
    cozumel.region = 'Caribbean';


MERGE (cococay:Destination {id: 'cococay'})
SET
    cococay.name = 'Perfect Day at CocoCay',
    cococay.country = 'Bahamas',
    cococay.region = 'Caribbean';


MERGE (stThomas:Destination {id: 'st-thomas'})
SET
    stThomas.name = 'St. Thomas',
    stThomas.country = 'U.S. Virgin Islands',
    stThomas.region = 'Caribbean';


MERGE (sanJuan:Destination {id: 'san-juan'})
SET
    sanJuan.name = 'San Juan',
    sanJuan.country = 'Puerto Rico',
    sanJuan.region = 'Caribbean';


MERGE (barcelona:Destination {id: 'barcelona'})
SET
    barcelona.name = 'Barcelona',
    barcelona.country = 'Spain',
    barcelona.region = 'Mediterranean';


MERGE (rome:Destination {id: 'rome'})
SET
    rome.name = 'Rome',
    rome.country = 'Italy',
    rome.region = 'Mediterranean';


MERGE (naples:Destination {id: 'naples'})
SET
    naples.name = 'Naples',
    naples.country = 'Italy',
    naples.region = 'Mediterranean';


MERGE (athens:Destination {id: 'athens'})
SET
    athens.name = 'Athens',
    athens.country = 'Greece',
    athens.region = 'Mediterranean';


// ============================================================
// SHIP -> DESTINATION
// ============================================================

// Oasis of the Seas
MATCH (ship:Ship {id: 'oasis-of-the-seas'})
MATCH (miami:Destination {id: 'miami'})
MATCH (nassau:Destination {id: 'nassau'})
MATCH (cococay:Destination {id: 'cococay'})
MATCH (stThomas:Destination {id: 'st-thomas'})
MERGE (ship)-[:SAILS_TO]->(miami)
MERGE (ship)-[:SAILS_TO]->(nassau)
MERGE (ship)-[:SAILS_TO]->(cococay)
MERGE (ship)-[:SAILS_TO]->(stThomas);


// Wonder of the Seas
MATCH (ship:Ship {id: 'wonder-of-the-seas'})
MATCH (miami:Destination {id: 'miami'})
MATCH (cococay:Destination {id: 'cococay'})
MATCH (nassau:Destination {id: 'nassau'})
MATCH (sanJuan:Destination {id: 'san-juan'})
MERGE (ship)-[:SAILS_TO]->(miami)
MERGE (ship)-[:SAILS_TO]->(cococay)
MERGE (ship)-[:SAILS_TO]->(nassau)
MERGE (ship)-[:SAILS_TO]->(sanJuan);


// Mardi Gras
MATCH (ship:Ship {id: 'mardi-gras'})
MATCH (miami:Destination {id: 'miami'})
MATCH (cozumel:Destination {id: 'cozumel'})
MATCH (nassau:Destination {id: 'nassau'})
MERGE (ship)-[:SAILS_TO]->(miami)
MERGE (ship)-[:SAILS_TO]->(cozumel)
MERGE (ship)-[:SAILS_TO]->(nassau);


// MSC Seascape
MATCH (ship:Ship {id: 'msc-seascape'})
MATCH (miami:Destination {id: 'miami'})
MATCH (cozumel:Destination {id: 'cozumel'})
MATCH (nassau:Destination {id: 'nassau'})
MERGE (ship)-[:SAILS_TO]->(miami)
MERGE (ship)-[:SAILS_TO]->(cozumel)
MERGE (ship)-[:SAILS_TO]->(nassau);


// Norwegian Prima
MATCH (ship:Ship {id: 'norwegian-prima'})
MATCH (barcelona:Destination {id: 'barcelona'})
MATCH (rome:Destination {id: 'rome'})
MATCH (naples:Destination {id: 'naples'})
MATCH (athens:Destination {id: 'athens'})
MERGE (ship)-[:SAILS_TO]->(barcelona)
MERGE (ship)-[:SAILS_TO]->(rome)
MERGE (ship)-[:SAILS_TO]->(naples)
MERGE (ship)-[:SAILS_TO]->(athens);


// Discovery Princess
MATCH (ship:Ship {id: 'discovery-princess'})
MATCH (sanJuan:Destination {id: 'san-juan'})
MATCH (stThomas:Destination {id: 'st-thomas'})
MATCH (barcelona:Destination {id: 'barcelona'})
MERGE (ship)-[:SAILS_TO]->(sanJuan)
MERGE (ship)-[:SAILS_TO]->(stThomas)
MERGE (ship)-[:SAILS_TO]->(barcelona);


// ============================================================
// DESTINATION CONNECTIVITY
//
// These relationships are used by FindRoutesAsync().
// ============================================================

MATCH (miami:Destination {id: 'miami'})
MATCH (nassau:Destination {id: 'nassau'})
MATCH (cozumel:Destination {id: 'cozumel'})
MATCH (cococay:Destination {id: 'cococay'})
MATCH (stThomas:Destination {id: 'st-thomas'})
MATCH (sanJuan:Destination {id: 'san-juan'})

MERGE (miami)-[:CONNECTED_TO]->(nassau)
MERGE (nassau)-[:CONNECTED_TO]->(miami)

MERGE (miami)-[:CONNECTED_TO]->(cozumel)
MERGE (cozumel)-[:CONNECTED_TO]->(miami)

MERGE (miami)-[:CONNECTED_TO]->(cococay)
MERGE (cococay)-[:CONNECTED_TO]->(miami)

MERGE (nassau)-[:CONNECTED_TO]->(cococay)
MERGE (cococay)-[:CONNECTED_TO]->(nassau)

MERGE (nassau)-[:CONNECTED_TO]->(stThomas)
MERGE (stThomas)-[:CONNECTED_TO]->(nassau)

MERGE (stThomas)-[:CONNECTED_TO]->(sanJuan)
MERGE (sanJuan)-[:CONNECTED_TO]->(stThomas)

MERGE (miami)-[:CONNECTED_TO]->(sanJuan)
MERGE (sanJuan)-[:CONNECTED_TO]->(miami);


MATCH (barcelona:Destination {id: 'barcelona'})
MATCH (rome:Destination {id: 'rome'})
MATCH (naples:Destination {id: 'naples'})
MATCH (athens:Destination {id: 'athens'})

MERGE (barcelona)-[:CONNECTED_TO]->(rome)
MERGE (rome)-[:CONNECTED_TO]->(barcelona)

MERGE (rome)-[:CONNECTED_TO]->(naples)
MERGE (naples)-[:CONNECTED_TO]->(rome)

MERGE (naples)-[:CONNECTED_TO]->(athens)
MERGE (athens)-[:CONNECTED_TO]->(naples)

MERGE (barcelona)-[:CONNECTED_TO]->(athens)
MERGE (athens)-[:CONNECTED_TO]->(barcelona);