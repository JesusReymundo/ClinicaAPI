using ClinicaAPI.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ClinicaAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class AuthController : ControllerBase
{
    private readonly ClinicaDbContext _db;

    public AuthController(ClinicaDbContext db)
    {
        _db = db;
    }

    /// <summary>Autenticar usuario con username y password</summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Username) || string.IsNullOrWhiteSpace(req.Password))
            return BadRequest(new { success = false, message = "Usuario y contraseña son requeridos" });

        var usuario = await _db.Usuarios
            .FirstOrDefaultAsync(u => u.Username == req.Username);

        if (usuario == null || usuario.PasswordHash != req.Password || !usuario.Activo)
            return Unauthorized(new { success = false, message = "Usuario o contraseña incorrectos" });

        // Buscar si tiene perfil de médico
        var medico = await _db.Medicos
            .FirstOrDefaultAsync(m => m.IdUsuario == usuario.IdUsuario);

        // Buscar si tiene perfil de paciente
        var paciente = await _db.Pacientes
            .FirstOrDefaultAsync(p => p.IdUsuario == usuario.IdUsuario);

        // Mapear rol
        var role = usuario.IdRol switch
        {
            1 => "admin",
            2 => "doctor",
            3 => "paciente",
            _ => "paciente"
        };

        return Ok(new
        {
            success = true,
            data = new
            {
                id         = usuario.IdUsuario,
                username   = usuario.Username,
                role,
                nombre     = usuario.Nombres,
                apellido   = usuario.Apellidos,
                medicoId   = medico?.IdMedico,
                pacienteId = paciente?.IdPaciente
            }
        });
    }
}

public record LoginRequest(string Username, string Password);

