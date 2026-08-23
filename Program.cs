using CruiseGraphExplorer.Configuration;
using CruiseGraphExplorer.Services;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// MVC
// ============================================================

builder.Services.AddControllersWithViews();


// ============================================================
// CognoDB Configuration
//
// Environment variables:
//
// COGNODB_URI
// COGNODB_USER
// COGNODB_PASSWORD
// ============================================================

builder.Services
    .AddOptions<CognoDbOptions>()
    .Configure<IConfiguration>((options, configuration) =>
    {
        options.Uri =
            Environment.GetEnvironmentVariable("COGNODB_URI")
            ?? string.Empty;

        options.Username =
            Environment.GetEnvironmentVariable("COGNODB_USER")
            ?? "cognodb";

        options.Password =
            Environment.GetEnvironmentVariable("COGNODB_PASSWORD")
            ?? string.Empty;
    });


// ============================================================
// Cruise Graph Service
// ============================================================

builder.Services.AddSingleton<ICruiseGraphService, CruiseGraphService>();


var app = builder.Build();


// ============================================================
// HTTP Request Pipeline
// ============================================================

if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();


// ============================================================
// Default MVC Route
// ============================================================
//
// /
//   ↓
// CruiseController
//   ↓
// Index()
//   ↓
// Views/Cruise/Index.cshtml
//

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Cruise}/{action=Index}/{id?}");


app.Run();