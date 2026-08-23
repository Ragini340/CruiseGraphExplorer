namespace CruiseGraphExplorer.Models
{
    public class Ship
    {
        public string Id { get; set; } = string.Empty;

        public string Name { get; set; } = string.Empty;

        public string CruiseLineId { get; set; } = string.Empty;

        public int Capacity { get; set; }

        public int YearBuilt { get; set; }
    }
}