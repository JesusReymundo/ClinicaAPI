using ClinicaAPI.Exceptions;
using ClinicaAPI.Services;
using ClinicaAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value?.Errors.Count > 0)
                .SelectMany(e => e.Value!.Errors.Select(err => new
                {
                    campo = e.Key,
                    mensaje = err.ErrorMessage
                }));

            return new BadRequestObjectResult(new
            {
                success = false,
                message = "Error de validación en los datos enviados",
                errores = errors
            });
        };
    });

builder.Services.AddSingleton<IPacienteService, PacienteService>();
builder.Services.AddSingleton<IMedicoService, MedicoService>();
builder.Services.AddSingleton<ICitaService, CitaService>();

builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title = "Clinica API",
        Version = "v1",
        Description = "API RESTful para la gestión de citas médicas de una clínica privada."
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Clinica API v1");
    c.RoutePrefix = string.Empty;
});

app.UseExceptionHandler();
app.UseHttpsRedirection();
app.MapControllers();

app.Run();
