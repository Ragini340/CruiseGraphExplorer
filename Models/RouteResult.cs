namespace CruiseGraphExplorer.Models
{
    public class RouteResult
    {
        public string StartDestination { get; set; } = string.Empty;

        public string EndDestination { get; set; } = string.Empty;

        public List<string> Path { get; set; } = new();

        public int Hops { get; set; }
    }
}