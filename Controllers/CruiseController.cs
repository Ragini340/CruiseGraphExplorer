using CruiseGraphExplorer.Services;
using Microsoft.AspNetCore.Mvc;

namespace CruiseGraphExplorer.Controllers
{
    public class CruiseController : Controller
    {
        private readonly ICruiseGraphService _cruiseGraphService;
        private readonly ILogger<CruiseController> _logger;

        public CruiseController(ICruiseGraphService cruiseGraphService, ILogger<CruiseController> logger)
        {
            _cruiseGraphService = cruiseGraphService;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                var cruiseLines = await _cruiseGraphService.GetCruiseLinesAsync();

                return View(cruiseLines);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while loading cruise lines.");

                TempData["ErrorMessage"] = "Unable to load cruise information. Please try again later.";

                return View(new List<Models.CruiseLine>());
            }
        }

        [HttpGet]
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
            {
                return BadRequest("Cruise line ID is required.");
            }

            try
            {
                var cruiseLine = await _cruiseGraphService.GetCruiseLineDetailsAsync(id);

                if (cruiseLine == null)
                {
                    return NotFound();
                }

                return View(cruiseLine);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while loading cruise line details for {CruiseLineId}", id);

                TempData["ErrorMessage"] = "Unable to load cruise line details.";

                return RedirectToAction(nameof(Index));
            }
        }

        [HttpGet]
        public async Task<IActionResult> Routes(string startDestination, string endDestination)
        {
            if (string.IsNullOrWhiteSpace(startDestination) || string.IsNullOrWhiteSpace(endDestination))
            {
                return BadRequest("Start and end destinations are required.");
            }

            try
            {
                var routes = await _cruiseGraphService.FindRoutesAsync(startDestination, endDestination);

                return View(routes);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while finding routes from {StartDestination} to {EndDestination}", startDestination, endDestination);

                TempData["ErrorMessage"] = "Unable to find routes. Please try again later.";

                return View(new List<Models.RouteResult>());
            }
        }
    }
}