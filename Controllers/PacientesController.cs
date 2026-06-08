using ClinicaAPI.DTOs;
using ClinicaAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ClinicaAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class PacientesController : ControllerBase
{
    private readonly IPacienteService _pacienteService;

    public PacientesController(IPacienteService pacienteService)
    {
        _pacienteService = pacienteService;
    }

    /// <summary>Obtiene todos los pacientes registrados</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PacienteResponseDto>), StatusCodes.Status200OK)]
    public IActionResult ObtenerTodos()
    {
        var pacientes = _pacienteService.ObtenerTodos();
        return Ok(new { success = true, data = pacientes });
    }

    /// <summary>Obtiene un paciente por su ID</summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(PacienteResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult ObtenerPorId(int id)
    {
        var paciente = _pacienteService.ObtenerPorId(id);
        return Ok(new { success = true, data = paciente });
    }

    /// <summary>Registra un nuevo paciente</summary>
    [HttpPost]
    [ProducesResponseType(typeof(PacienteResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Crear([FromBody] PacienteCreateDto dto)
    {
        var paciente = _pacienteService.Crear(dto);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = paciente.Id },
            new { success = true, message = "Paciente registrado exitosamente", data = paciente });
    }

    /// <summary>Actualiza los datos de un paciente</summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(PacienteResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Actualizar(int id, [FromBody] PacienteUpdateDto dto)
    {
        var paciente = _pacienteService.Actualizar(id, dto);
        return Ok(new { success = true, message = "Paciente actualizado exitosamente", data = paciente });
    }

    /// <summary>Elimina un paciente por su ID</summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult Eliminar(int id)
    {
        _pacienteService.Eliminar(id);
        return Ok(new { success = true, message = $"Paciente con ID {id} eliminado exitosamente" });
    }
}
