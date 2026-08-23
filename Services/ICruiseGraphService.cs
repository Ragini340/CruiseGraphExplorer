using CruiseGraphExplorer.Models;
using Microsoft.AspNetCore.Rewrite;

namespace CruiseGraphExplorer.Services
{
    public interface ICruiseGraphService
    {
        Task<List<CruiseLine>> GetCruiseLinesAsync();

        Task<CruiseLineDetails?> GetCruiseLineDetailsAsync(string cruiseLineId);

        Task<List<RouteResult>> FindRoutesAsync(string startDestination, string endDestination);
    }
}