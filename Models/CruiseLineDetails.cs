namespace CruiseGraphExplorer.Models
{
    public class CruiseLineDetails
    {
        public CruiseLine CruiseLine { get; set; } = new();

        public List<Ship> Ships { get; set; } = new();

        public List<Destination> Destinations { get; set; } = new();
    }
}