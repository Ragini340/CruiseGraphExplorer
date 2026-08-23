using CruiseGraphExplorer.Configuration;
using CruiseGraphExplorer.Models;
using CruiseGraphExplorer.Services;
using Microsoft.Extensions.Options;
using Neo4j.Driver;

namespace CruiseGraphExplorer.Services
{
    public class CruiseGraphService : ICruiseGraphService
    {
        private readonly IDriver _driver;
        private readonly ILogger<CruiseGraphService> _logger;

        public CruiseGraphService(IOptions<CognoDbOptions> options, ILogger<CruiseGraphService> logger)
        {
            _logger = logger;

            var settings = options.Value;

            if (string.IsNullOrWhiteSpace(settings.Uri))
            {
                throw new InvalidOperationException("COGNODB_URI environment variable is not configured.");
            }

            if (string.IsNullOrWhiteSpace(settings.Username))
            {
                throw new InvalidOperationException("COGNODB_USER environment variable is not configured.");
            }

            if (string.IsNullOrWhiteSpace(settings.Password))
            {
                throw new InvalidOperationException("COGNODB_PASSWORD environment variable is not configured.");
            }

            _driver = GraphDatabase.Driver(settings.Uri, AuthTokens.Basic(settings.Username, settings.Password));
        }

        public async Task<List<CruiseLine>> GetCruiseLinesAsync()
        {
            const string query = """
            MATCH (c:CruiseLine)
            RETURN
                c.id AS id,
                c.name AS name,
                c.country AS country,
                c.website AS website
            ORDER BY c.name
            """;

            try
            {
                await using var session = _driver.AsyncSession();

                var result = await session.RunAsync(query);

                var records = await result.ToListAsync();

                return records
                    .Select(record => new CruiseLine
                    {
                        Id = record["id"].As<string>(),
                        Name = record["name"].As<string>(),
                        Country = record["country"].As<string>(),
                        Website = record["website"].As<string>()
                    })
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving cruise lines from CognoDB.");

                throw;
            }
        }

        public async Task<CruiseLineDetails?> GetCruiseLineDetailsAsync(
            string cruiseLineId)
        {
            const string query = """
            MATCH (c:CruiseLine {id: $cruiseLineId})
            OPTIONAL MATCH (c)-[:OPERATES]->(s:Ship)
            OPTIONAL MATCH (s)-[:SAILS_TO]->(d:Destination)
            RETURN
                c,
                collect(DISTINCT s) AS ships,
                collect(DISTINCT d) AS destinations
            """;

            try
            {
                await using var session = _driver.AsyncSession();

                var result = await session.RunAsync(
                    query,
                    new { cruiseLineId });

                var records = await result.ToListAsync();

                if (records.Count == 0)
                {
                    return null;
                }

                var record = records[0];

                var cruiseNode = record["c"].As<INode>();
                var cruiseLine = new CruiseLine
                {
                    Id = GetNodeProperty<string>(
                        cruiseNode,
                        "id"),

                    Name = GetNodeProperty<string>(
                        cruiseNode,
                        "name"),

                    Country = GetNodeProperty<string>(
                        cruiseNode,
                        "country"),

                    Website = GetNodeProperty<string>(
                        cruiseNode,
                        "website")
                };

                var ships = record["ships"]
                    .As<List<INode>>()
                    .Where(node => node != null)
                    .Select(node => new Ship
                    {
                        Id = GetNodeProperty<string>(
                            node,
                            "id"),

                        Name = GetNodeProperty<string>(
                            node,
                            "name"),

                        CruiseLineId = cruiseLineId,

                        Capacity = GetNodeProperty<int>(
                            node,
                            "capacity"),

                        YearBuilt = GetNodeProperty<int>(
                            node,
                            "yearBuilt")
                    })
                    .ToList();

                var destinations = record["destinations"]
                    .As<List<INode>>()
                    .Where(node => node != null)
                    .Select(node => new Destination
                    {
                        Id = GetNodeProperty<string>(
                            node,
                            "id"),

                        Name = GetNodeProperty<string>(
                            node,
                            "name"),

                        Country = GetNodeProperty<string>(
                            node,
                            "country"),

                        Region = GetNodeProperty<string>(
                            node,
                            "region")
                    })
                    .ToList();

                return new CruiseLineDetails
                {
                    CruiseLine = cruiseLine,
                    Ships = ships,
                    Destinations = destinations
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving cruise line details for {CruiseLineId}.",
                   cruiseLineId);

                throw;
            }
        }

        public async Task<List<RouteResult>> FindRoutesAsync(
            string startDestination,
            string endDestination)
        {
            const string query = """
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
            """;

            try
            {
                await using var session = _driver.AsyncSession();

                var result = await session.RunAsync(
                    query,
                    new
                    {
                        startDestination,
                        endDestination
                    });

                var records = await result.ToListAsync();

                return records
                    .Select(record => new RouteResult
                    {
                        StartDestination =
                            record["startId"].As<string>(),

                        EndDestination =
                            record["endId"].As<string>(),

                        Path =
                            record["path"].As<List<string>>(),

                        Hops =
                            record["hops"].As<int>()
                    })
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Error finding route from {StartDestination} to {EndDestination}.",
                    startDestination,
                    endDestination);

                throw;
            }
        }

        private static T GetNodeProperty<T>( INode node, string propertyName)
        {
            if (!node.Properties.TryGetValue(propertyName, out var value))
            {
                return default!;
            }

            return value.As<T>();
        }
    }
}